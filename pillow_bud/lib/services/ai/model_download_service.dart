import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pillow_bud/services/ai/local_llm_engine.dart';

enum ModelDownloadStatus {
  notDownloaded,
  downloading,
  paused,
  downloaded,
  failed,
}

class ModelDownloadService {
  // A Q4_K_M 4B model is measured in gigabytes; tiny/truncated files must not
  // be treated as a usable model.
  static const int minimumValidModelBytes = 1024 * 1024 * 1024;

  static const String modelFileName = 'Qwen3-4B-Instruct-2507-Q4_K_M.gguf';
  static const String defaultModelUrl =
      'https://huggingface.co/unsloth/Qwen3-4B-Instruct-2507-GGUF/resolve/main/Qwen3-4B-Instruct-2507-Q4_K_M.gguf';

  static final Dio _dio = Dio();
  static CancelToken? _cancelToken;

  static ValueNotifier<ModelDownloadStatus> statusNotifier =
      ValueNotifier(ModelDownloadStatus.notDownloaded);
  static ValueNotifier<double> progressNotifier = ValueNotifier(0.0);
  static ValueNotifier<String> statusMessageNotifier =
      ValueNotifier('Model ready to download');

  /// Gets the full local path to the AI model file on the device
  static Future<String> getModelPath() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final modelDir = Directory(p.join(dir.path, 'models'));
      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }
      return p.join(modelDir.path, modelFileName);
    } catch (e) {
      final tempDir = Directory(
          p.join(Directory.systemTemp.path, 'pillow_bud_models'));
      if (!tempDir.existsSync()) {
        tempDir.createSync(recursive: true);
      }
      return p.join(tempDir.path, modelFileName);
    }
  }

  /// Gets the temporary path for partial downloads
  static Future<String> getTempPath() async {
    final savePath = await getModelPath();
    return '$savePath.download';
  }

  /// Checks if the model file is downloaded and verified on disk
  static Future<bool> isModelDownloaded() async {
    try {
      final path = await getModelPath();
      final file = File(path);
      final exists = await file.exists();
      if (exists) {
        final length = await file.length();
        if (length >= minimumValidModelBytes) {
          statusNotifier.value = ModelDownloadStatus.downloaded;
          progressNotifier.value = 1.0;
          statusMessageNotifier.value = 'Qwen3 4B Instruct (Local GGUF Ready)';
          // Hot-load local engine for development persistence
          LocalLLMEngine.getInstance().catchError((e) {
            debugPrint('LocalLLMEngine hot load warning: $e');
            return LocalLLMEngine.dummy();
          });
          return true;
        }
      }

      // Check if partial download exists
      final tempPath = await getTempPath();
      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        final tempLength = await tempFile.length();
        if (tempLength > 0) {
          statusNotifier.value = ModelDownloadStatus.paused;
          final mb = (tempLength / (1024 * 1024)).toStringAsFixed(1);
          statusMessageNotifier.value = 'Download paused ($mb MB downloaded)';
          return false;
        }
      }
    } catch (e) {
      debugPrint('Error checking model path: $e');
    }
    statusNotifier.value = ModelDownloadStatus.notDownloaded;
    progressNotifier.value = 0.0;
    return false;
  }

  /// Starts or resumes downloading the model with HTTP Range support.
  static Future<void> startDownload({
    String? url,
    VoidCallback? onComplete,
    Function(String error)? onError,
  }) async {
    final targetUrl = url ?? defaultModelUrl;
    final savePath = await getModelPath();
    final tempPath = await getTempPath();
    final tempFile = File(tempPath);

    int existingLength = 0;
    if (await tempFile.exists()) {
      existingLength = await tempFile.length();
    }

    final headers = <String, String>{};

    if (existingLength > 0) {
      headers['Range'] = 'bytes=$existingLength-';
    }

    _cancelToken = CancelToken();
    statusNotifier.value = ModelDownloadStatus.downloading;
    statusMessageNotifier.value = existingLength > 0
        ? 'Resuming download from ${(existingLength / (1024 * 1024)).toStringAsFixed(1)} MB...'
        : 'Connecting to repository...';

    IOSink? sink;
    try {
      final response = await _dio.get<ResponseBody>(
        targetUrl,
        cancelToken: _cancelToken,
        options: Options(
          headers: headers,
          responseType: ResponseType.stream,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 400,
        ),
      );

      final isPartial = response.statusCode == 206;
      final contentLengthHeader = response.headers.value('content-length');
      final totalContentBytes = contentLengthHeader != null
          ? int.tryParse(contentLengthHeader) ?? 0
          : 0;

      final totalBytes = isPartial
          ? existingLength + totalContentBytes
          : totalContentBytes;

      if (!isPartial) {
        existingLength = 0;
        sink = tempFile.openWrite(mode: FileMode.write);
      } else {
        sink = tempFile.openWrite(mode: FileMode.append);
      }

      int receivedNow = 0;
      final stream = response.data!.stream;

      await for (final chunk in stream) {
        sink.add(chunk);
        receivedNow += chunk.length;
        final currentTotalReceived = existingLength + receivedNow;

        if (totalBytes > 0) {
          final progress = (currentTotalReceived / totalBytes).clamp(0.0, 1.0);
          progressNotifier.value = progress;
          final currentMB = (currentTotalReceived / (1024 * 1024)).toStringAsFixed(1);
          final totalMB = (totalBytes / (1024 * 1024)).toStringAsFixed(1);
          statusMessageNotifier.value =
              'Downloading model: $currentMB MB / $totalMB MB (${(progress * 100).toStringAsFixed(0)}%)';
        } else {
          final currentMB = (currentTotalReceived / (1024 * 1024)).toStringAsFixed(1);
          statusMessageNotifier.value = 'Downloading: $currentMB MB';
        }
      }

      await sink.flush();
      await sink.close();
      sink = null;

      if (await tempFile.exists()) {
        await tempFile.rename(savePath);
      }

      statusNotifier.value = ModelDownloadStatus.downloaded;
      progressNotifier.value = 1.0;
      statusMessageNotifier.value = 'Model ready (Local GGUF)';
      onComplete?.call();
    } catch (e) {
      await sink?.close();
      if (e is DioException && CancelToken.isCancel(e)) {
        statusNotifier.value = ModelDownloadStatus.paused;
        final currentLen = await tempFile.exists() ? await tempFile.length() : 0;
        final currentMB = (currentLen / (1024 * 1024)).toStringAsFixed(1);
        statusMessageNotifier.value = 'Download paused ($currentMB MB saved). Tap Resume to continue.';
      } else {
        debugPrint('Download error: $e');
        statusNotifier.value = ModelDownloadStatus.failed;
        statusMessageNotifier.value = 'Download error – tap to retry.';
        onError?.call(e.toString());
      }
    }
  }

  /// Pauses the ongoing model download
  static void pauseDownload() {
    _cancelToken?.cancel('Paused by user');
    statusNotifier.value = ModelDownloadStatus.paused;
  }

  /// Resumes a paused download
  static Future<void> resumeDownload({
    VoidCallback? onComplete,
    Function(String error)? onError,
  }) async {
    await startDownload(onComplete: onComplete, onError: onError);
  }

  /// Cancels the ongoing or paused model download and clears temp files
  static Future<void> cancelDownload() async {
    _cancelToken?.cancel('Cancelled by user');
    try {
      final tempPath = await getTempPath();
      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (_) {}

    statusNotifier.value = ModelDownloadStatus.notDownloaded;
    progressNotifier.value = 0.0;
    statusMessageNotifier.value = 'Download cancelled';
  }

  /// Deletes the downloaded model to reclaim disk space
  static Future<void> deleteModel() async {
    try {
      final path = await getModelPath();
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }

      final tempPath = await getTempPath();
      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      statusNotifier.value = ModelDownloadStatus.notDownloaded;
      progressNotifier.value = 0.0;
      statusMessageNotifier.value = 'Model removed. Tap to download.';
    } catch (e) {
      debugPrint('Error deleting model: $e');
    }
  }
}
