import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:llama_cpp/llama_cpp.dart';
import 'package:pillow_bud/services/ai/model_download_service.dart';

/// On-device LLM inference engine backed by `llama_cpp`.
///
/// Uses [LlamaCpp.load] to initialise the model in an isolate and
/// [LlamaCpp.answer] to stream tokens back.
class LocalLLMEngine {
  static LocalLLMEngine? _instance;

  /// The underlying llama_cpp isolate-backed context (null for dummy/unloaded engine).
  final LlamaCpp? _llama;

  LocalLLMEngine._(this._llama);

  /// Dummy engine instance used when model is missing or fails to load.
  factory LocalLLMEngine.dummy() => LocalLLMEngine._(null);

  /// Returns the singleton, loading the model from disk on first call.
  static Future<LocalLLMEngine> getInstance() async {
    if (_instance != null) return _instance!;

    if (kIsWeb) {
      throw UnsupportedError('LocalLLMEngine is not supported on Web.');
    }

    final modelPath = await ModelDownloadService.getModelPath();
    if (!await File(modelPath).exists()) {
      throw Exception(
        'Model file not found at "$modelPath". '
        'Please download the model in Profile & Settings first.',
      );
    }

    debugPrint('LocalLLMEngine: loading model from $modelPath …');

    final llama = await LlamaCpp.load(
      modelPath,
      nCtx: 2048,
      nThread: Platform.isAndroid ? 2 : 4,
      verbose: kDebugMode,
    );

    debugPrint('LocalLLMEngine: model loaded ✓');
    _instance = LocalLLMEngine._(llama);
    return _instance!;
  }

  /// Generates a complete response for [prompt].
  Future<String> generate(String prompt) async {
    final llama = _llama;
    if (llama == null) return '';
    final buffer = StringBuffer();
    final stream = llama.answer(
      prompt,
      temperature: 0.7,
      topK: 40,
      topP: 0.9,
      penalizeNewline: false,
    );
    await for (final token in stream) {
      buffer.write(token);
    }
    return buffer.toString().trim();
  }

  /// Streams individual tokens for [prompt].
  Stream<String> generateStream(String prompt) async* {
    final llama = _llama;
    if (llama == null) return;
    final stream = llama.answer(
      prompt,
      temperature: 0.7,
      topK: 40,
      topP: 0.9,
      penalizeNewline: false,
    );
    await for (final token in stream) {
      yield token;
    }
  }

  /// Frees native resources and resets the singleton.
  Future<void> dispose() async {
    try {
      await _llama?.dispose();
      debugPrint('LocalLLMEngine: disposed.');
    } catch (e) {
      debugPrint('LocalLLMEngine.dispose error: $e');
    } finally {
      _instance = null;
    }
  }
}
