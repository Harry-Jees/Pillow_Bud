import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Wraps `speech_to_text` for Pillow Bud voice input.
///
/// Usage:
///   await VoiceInputService.initialize();
///   VoiceInputService.start(onResult: (text) => controller.text = text);
///   VoiceInputService.stop();
class VoiceInputService {
  static final SpeechToText _stt = SpeechToText();
  static bool _initialized = false;

  static final ValueNotifier<bool> isListeningNotifier = ValueNotifier(false);
  static final ValueNotifier<double> soundLevelNotifier = ValueNotifier(0.0);
  static final ValueNotifier<String> partialTextNotifier = ValueNotifier('');

  /// Initializes and requests microphone permission.
  /// Returns true if speech recognition is available.
  static Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = await _stt.initialize(
      onError: (error) {
        debugPrint('VoiceInputService error: ${error.errorMsg}');
        isListeningNotifier.value = false;
      },
      onStatus: (status) {
        debugPrint('VoiceInputService status: $status');
        if (status == 'done' || status == 'notListening') {
          isListeningNotifier.value = false;
        }
      },
    );
    return _initialized;
  }

  /// Starts listening. [onResult] is called with the final transcribed string.
  static Future<void> start({required void Function(String text) onResult}) async {
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) return;
    }
    if (_stt.isListening) return;

    isListeningNotifier.value = true;
    partialTextNotifier.value = '';

    await _stt.listen(
      onResult: (result) {
        partialTextNotifier.value = result.recognizedWords;
        if (result.finalResult) {
          isListeningNotifier.value = false;
          if (result.recognizedWords.trim().isNotEmpty) {
            onResult(result.recognizedWords.trim());
          }
        }
      },
      onSoundLevelChange: (level) {
        soundLevelNotifier.value = level.clamp(0.0, 10.0) / 10.0;
      },
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  /// Stops the current listening session.
  static Future<void> stop() async {
    await _stt.stop();
    isListeningNotifier.value = false;
  }

  /// Cancels the session without emitting a result.
  static Future<void> cancel() async {
    await _stt.cancel();
    isListeningNotifier.value = false;
    partialTextNotifier.value = '';
  }

  static bool get isListening => _stt.isListening;
}
