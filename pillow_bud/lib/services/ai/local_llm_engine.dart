import 'dart:async';
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
  static Future<LocalLLMEngine>? _loading;

  /// The underlying llama_cpp isolate-backed context (null for dummy/unloaded engine).
  final LlamaCpp? _llama;
  Future<void> _generationTail = Future<void>.value();
  bool _disposed = false;

  LocalLLMEngine._(this._llama);

  /// Dummy engine instance used when model is missing or fails to load.
  factory LocalLLMEngine.dummy() => LocalLLMEngine._(null);

  /// Returns the singleton, loading the model from disk on first call.
  ///
  /// Concurrent callers share one in-flight load so a rapid double-submit
  /// cannot initialize multiple native model contexts and exhaust device RAM.
  static Future<LocalLLMEngine> getInstance() {
    final instance = _instance;
    if (instance != null) return Future.value(instance);

    final inFlight = _loading;
    if (inFlight != null) return inFlight;

    final load = _loadInstance();
    _loading = load;
    return load.whenComplete(() {
      if (identical(_loading, load)) _loading = null;
    });
  }

  static Future<LocalLLMEngine> _loadInstance() async {
    if (kIsWeb) {
      throw UnsupportedError('LocalLLMEngine is not supported on Web.');
    }

    final modelPath = await ModelDownloadService.getModelPath();
    final modelFile = File(modelPath);
    if (!await modelFile.exists() ||
        await modelFile.length() < ModelDownloadService.minimumValidModelBytes ||
        !await ModelDownloadService.hasGgufMagic(modelFile)) {
      throw Exception(
        'The local model is missing or invalid. '
        'Please download it again in Profile & Settings.',
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
    final engine = LocalLLMEngine._(llama);
    _instance = engine;
    return engine;
  }

  /// Generates a complete response for [prompt].
  Future<String> generate(String prompt) {
    return _withGenerationLock(() async {
      if (_disposed) return '';
      final llama = _llama;
      if (llama == null) return '';
      final buffer = StringBuffer();
      final stream = llama.answer(
        prompt,
        temperature: 0.7,
        topK: 20,
        topP: 0.8,
        penalizeNewline: false,
      );
      await for (final token in stream) {
        buffer.write(token);
      }
      return buffer.toString().trim();
    });
  }

  /// Streams individual tokens for [prompt].
  ///
  /// Inference is serialized per engine because llama.cpp contexts are not
  /// safe to use for overlapping generation requests.
  Stream<String> generateStream(String prompt) async* {
    final previous = _generationTail;
    final release = Completer<void>();
    _generationTail = release.future;
    await previous;

    try {
      if (_disposed) return;
      final llama = _llama;
      if (llama == null) return;
      final stream = llama.answer(
        prompt,
        temperature: 0.7,
        topK: 20,
        topP: 0.8,
        penalizeNewline: false,
      );
      await for (final token in stream) {
        yield token;
      }
    } finally {
      release.complete();
    }
  }

  Future<T> _withGenerationLock<T>(Future<T> Function() operation) async {
    final previous = _generationTail;
    final release = Completer<void>();
    _generationTail = release.future;
    await previous;
    try {
      return await operation();
    } finally {
      release.complete();
    }
  }

  /// Frees native resources and resets the singleton.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    try {
      // Queue disposal behind current inference. Queued/new requests observe
      // _disposed and return without touching the native context.
      await _withGenerationLock(() async {
        await _llama?.dispose();
      });
      debugPrint('LocalLLMEngine: disposed.');
    } catch (e) {
      debugPrint('LocalLLMEngine.dispose error: $e');
    } finally {
      if (identical(_instance, this)) _instance = null;
    }
  }
}
