import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum ModelDownloadStatus {
  notDownloaded,
  downloading,
  paused,
  downloaded,
  failed,
}

class ModelDownloadService {
  /// A 4B Q4_K_M model is measured in gigabytes. Reject tiny/truncated files.
  static const int minimumValidModelBytes = 1024 * 1024 * 1024;

  static const String modelFileName = 'Qwen3-4B-Instruct-2507-Q4_K_M.gguf';
  static const String defaultModelUrl =
      'https://huggingface.co/unsloth/Qwen3-4B-Instruct-2507-GGUF/resolve/main/Qwen3-4B-Instruct-2507-Q4_K_M.gguf';

  static final Dio _dio = Dio();
  static CancelToken? _cancelToken;

  static final ValueNotifier<ModelDownloadStatus> statusNotifier =
      ValueNotifier(ModelDownloadStatus.notDownloaded);
  static final ValueNotifier<double> progressNotifier = ValueNotifier(0.0);
  static final ValueNotifier<String> statusMessageNotifier =
      ValueNotifier('Model ready to download');

  static Future<String> getModelPath() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final modelDir = Directory(p.join(dir.path, 'models'));
      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }
      return p.join(modelDir.path, modelFileName);
    } catch (_) {
      final tempDir = Directory(
        p.join(Directory.systemTemp.path, 'pillow_bud_models'),
      );
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }
      return p.join(tempDir.path, modelFileName);
    }
  }

  static Future<String> getTempPath() async {
    return '${await getModelPath()}.download';
  }

  /// Checks the GGUF container signature, not just the file extension or size.
  /// Full model identity/checksum verification remains a release-hardening task.
  static Future<bool> hasGgufMagic(File file) async {
    RandomAccessFile? handle;
    try {
      if (!await file.exists() || await file.length() < 4) return false;
      handle = await file.open(mode: FileMode.read);
      final header = await handle.read(4);
      return header.length == 4 &&
          header[0] == 0x47 && // G
          header[1] == 0x47 && // G
          header[2] == 0x55 && // U
          header[3] == 0x46; // F
    } catch (_) {
      return false;
    } finally {
      await handle?.close();
    }
  }

  /// Checks the final model file and reports partial downloads as resumable.
  static Future<bool> isModelDownloaded() async {
    try {
      final path = await getModelPath();
      final file = File(path);
      if (await file.exists()) {
        final length = await file.length();
        if (length >= minimumValidModelBytes && await hasGgufMagic(file)) {
          statusNotifier.value = ModelDownloadStatus.downloaded;
          progressNotifier.value = 1.0;
          statusMessageNotifier.value = 'Qwen3 4B Instruct (Local GGUF Ready)';
          return true;
        }

        // Reject truncated or non-GGUF files left at the final path.
        await file.delete();
      }

      final tempFile = File(await getTempPath());
      if (await tempFile.exists()) {
        final tempLength = await tempFile.length();
        if (tempLength > 0) {
          statusNotifier.value = ModelDownloadStatus.paused;
          final mb = (tempLength / (1024 * 1024)).toStringAsFixed(1);
          statusMessageNotifier.value = 'Download paused ($mb MB downloaded)';
          return false;
        }
      }
    } catch (error) {
      debugPrint('Error checking model path: $error');
    }

    statusNotifier.value = ModelDownloadStatus.notDownloaded;
    progressNotifier.value = 0.0;
    return false;
  }

  /// Starts or resumes a download. A partial response is appended only when
  /// the server confirms that its byte range starts at the saved file length.
  static Future<void> startDownload({
    String? url,
    VoidCallback? onComplete,
    Function(String error)? onError,
  }) async {
    final targetUrl = url ?? defaultModelUrl;
    final savePath = await getModelPath();
    final tempFile = File(await getTempPath());
    var existingLength = await tempFile.exists() ? await tempFile.length() : 0;

    final headers = <String, String>{};
    if (existingLength > 0) {
      headers['Range'] = 'bytes=$existingLength-';
    }

    _cancelToken = CancelToken();
    statusNotifier.value = ModelDownloadStatus.downloading;
    statusMessageNotifier.value = existingLength > 0
        ? 'Resuming download from '
            '${(existingLength / (1024 * 1024)).toStringAsFixed(1)} MB...'
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

      final statusCode = response.statusCode;
      if (statusCode != 200 && statusCode != 206) {
        throw StateError('Unexpected model download HTTP status: $statusCode');
      }

      final isPartial = statusCode == 206;
      final contentRange = response.headers.value('content-range');
      var expectedTotalBytes = 0;
      int? expectedResponseBytes;

      if (isPartial) {
        // Validate the complete range before appending any bytes.
        final match = contentRange == null
            ? null
            : RegExp(r'^bytes (\d+)-(\d+)/(\d+)$').firstMatch(contentRange);
        final start = int.tryParse(match?.group(1) ?? '');
        final end = int.tryParse(match?.group(2) ?? '');
        final total = int.tryParse(match?.group(3) ?? '');
        if (existingLength == 0 ||
            start != existingLength ||
            end == null ||
            total == null ||
            start == null ||
            end < start ||
            total <= end) {
          throw StateError(
            'The server returned an invalid byte range; download cannot be resumed safely.',
          );
        }
        expectedTotalBytes = total;
        expectedResponseBytes = end - start + 1;
      } else {
        // Some servers ignore Range. In that case restart the temporary file.
        existingLength = 0;
        final lengthHeader = response.headers.value('content-length');
        expectedTotalBytes = int.tryParse(lengthHeader ?? '') ?? 0;
        expectedResponseBytes =
            expectedTotalBytes > 0 ? expectedTotalBytes : null;
      }

      final contentLengthHeader = response.headers.value('content-length');
      final responseBytes = int.tryParse(contentLengthHeader ?? '');
      if (expectedResponseBytes != null &&
          responseBytes != null &&
          responseBytes != expectedResponseBytes) {
        throw StateError('The server response length does not match its byte range.');
      }
      final totalBytes = expectedTotalBytes > 0
          ? expectedTotalBytes
          : existingLength + (responseBytes ?? 0);

      sink = tempFile.openWrite(
        mode: isPartial ? FileMode.append : FileMode.write,
      );

      var receivedNow = 0;
      final stream = response.data?.stream;
      if (stream == null) {
        throw StateError('The model server returned an empty response.');
      }

      await for (final chunk in stream) {
        sink.add(chunk);
        receivedNow += chunk.length;
        final currentTotalReceived = existingLength + receivedNow;

        if (totalBytes > 0) {
          final progress =
              (currentTotalReceived / totalBytes).clamp(0.0, 1.0).toDouble();
          progressNotifier.value = progress;
          final currentMB =
              (currentTotalReceived / (1024 * 1024)).toStringAsFixed(1);
          final totalMB = (totalBytes / (1024 * 1024)).toStringAsFixed(1);
          statusMessageNotifier.value =
              'Downloading model: $currentMB MB / $totalMB MB '
              '(${(progress * 100).toStringAsFixed(0)}%)';
        } else {
          final currentMB =
              (currentTotalReceived / (1024 * 1024)).toStringAsFixed(1);
          statusMessageNotifier.value = 'Downloading: $currentMB MB';
        }
      }

      await sink.flush();
      await sink.close();
      sink = null;

      if (expectedResponseBytes != null && receivedNow != expectedResponseBytes) {
        throw StateError(
          'The model server sent $receivedNow bytes; '
          'expected $expectedResponseBytes bytes for this response.',
        );
      }

      final downloadedBytes = await tempFile.length();
      if (downloadedBytes < minimumValidModelBytes ||
          (totalBytes > 0 && downloadedBytes != totalBytes)) {
        final expectedSize = totalBytes > 0
            ? '$totalBytes bytes'
            : 'at least $minimumValidModelBytes bytes';
        throw StateError(
          'Downloaded model is incomplete or has an unexpected size '
          '($downloadedBytes bytes; expected $expectedSize). '
          'The partial file was kept so the download can be resumed.',
        );
      }

      if (!await hasGgufMagic(tempFile)) {
        // This is a completed but invalid payload, not a resumable partial.
        // Remove it so the next attempt starts with a clean download.
        await tempFile.delete();
        throw StateError(
          'The downloaded file is not a valid GGUF container. '
          'The invalid file was removed; please download the model again.',
        );
      }

      final destination = File(savePath);
      if (await destination.exists()) {
        await destination.delete();
      }
      await tempFile.rename(savePath);

      statusNotifier.value = ModelDownloadStatus.downloaded;
      progressNotifier.value = 1.0;
      statusMessageNotifier.value = 'Model ready (Local GGUF)';
      onComplete?.call();
    } catch (error) {
      await sink?.close();
      if (error is DioException && CancelToken.isCancel(error)) {
        statusNotifier.value = ModelDownloadStatus.paused;
        final currentLength =
            await tempFile.exists() ? await tempFile.length() : 0;
        final currentMB =
            (currentLength / (1024 * 1024)).toStringAsFixed(1);
        statusMessageNotifier.value =
            'Download paused ($currentMB MB saved). Tap Resume to continue.';
      } else {
        debugPrint('Download error: $error');
        statusNotifier.value = ModelDownloadStatus.failed;
        statusMessageNotifier.value = 'Download error – tap to retry.';
        onError?.call(error.toString());
      }
    }
  }

  static void pauseDownload() {
    _cancelToken?.cancel('Paused by user');
    statusNotifier.value = ModelDownloadStatus.paused;
  }

  static Future<void> resumeDownload({
    VoidCallback? onComplete,
    Function(String error)? onError,
  }) async {
    await startDownload(onComplete: onComplete, onError: onError);
  }

  static Future<void> cancelDownload() async {
    _cancelToken?.cancel('Cancelled by user');
    try {
      final tempFile = File(await getTempPath());
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (_) {}

    statusNotifier.value = ModelDownloadStatus.notDownloaded;
    progressNotifier.value = 0.0;
    statusMessageNotifier.value = 'Download cancelled';
  }

  static Future<void> deleteModel() async {
    try {
      final modelFile = File(await getModelPath());
      if (await modelFile.exists()) {
        await modelFile.delete();
      }

      final tempFile = File(await getTempPath());
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      statusNotifier.value = ModelDownloadStatus.notDownloaded;
      progressNotifier.value = 0.0;
      statusMessageNotifier.value = 'Model removed. Tap to download.';
    } catch (error) {
      debugPrint('Error deleting model: $error');
    }
  }
}
