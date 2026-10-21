import 'package:flutter/foundation.dart';
import 'package:pillow_bud/services/ai/local_llm_engine.dart';
import 'package:pillow_bud/services/ai/model_download_service.dart';
import 'package:pillow_bud/services/crisis_detector.dart';
import 'package:pillow_bud/services/emotion_detector.dart';
import 'package:pillow_bud/services/system_prompt_generator.dart';
import 'package:uuid/uuid.dart';

/// Intelligent Local Emotional Companion Chatbot Engine.
///
/// Strictly executes on the downloaded local GGUF model
/// (`unsloth/Qwen3-4B-Instruct-2507-GGUF`) using ChatML formatting
/// for peak quality, high-empathy responses with zero cloud fallback.
class LLMService {
  static const uuid = Uuid();

  final List<Map<String, String>> conversationHistory = [];

  /// Restores recent persisted turns so Bud retains context after app restart.
  void restoreConversationHistory(
    Iterable<Map<String, String>> turns,
  ) {
    conversationHistory
      ..clear()
      ..addAll(
        turns.where((turn) {
          final role = turn['role'];
          final content = turn['content'];
          return (role == 'user' || role == 'assistant') &&
              content != null &&
              content.trim().isNotEmpty;
        }).map((turn) => {
          'role': turn['role']!,
          'content': turn['content']!,
        }),
      );

    if (conversationHistory.length > 24) {
      conversationHistory.removeRange(0, conversationHistory.length - 24);
    }
  }

  /// Clears in-memory context when the user starts a fresh conversation.
  void clearConversationHistory() => conversationHistory.clear();

  /// Processes [userMessage] through the on-device model and returns
  /// Bud's response string.
  Future<String> getEmotionalBudResponse({
    required String userMessage,
    required String userName,
    required String personalityMode,
  }) async {
    // 1. Safety & Crisis Emergency Tier
    if (CrisisDetector.detectCrisis(userMessage)) {
      return CrisisDetector.getCrisisResourceMessage();
    }

    // 2. Guard: model must be downloaded
    final isDownloaded = await ModelDownloadService.isModelDownloaded();
    if (!isDownloaded) {
      return '⚠️ The AI model hasn\'t been downloaded yet.\n\n'
          'Go to **Profile & Settings → On-Device AI Model** and tap '
          '"Download Model (~2.5 GB)" to get started.';
    }

    // 3. Emotional Analysis & Intensity Scoring
    final analysis = EmotionDetector.analyze(userMessage);
    final detectedEmotion = analysis['emotion'] as String;
    final emotionIntensity = analysis['intensity'] as double;

    // 4. System Prompt Synthesis
    final systemPrompt = SystemPromptGenerator.generatePrompt(
      userName: userName,
      personalityMode: personalityMode,
      detectedEmotion: detectedEmotion,
      emotionIntensity: emotionIntensity,
      recentContext: _getRecentContext(),
    );

    // 5. Build Qwen ChatML Formatted Prompt
    final formattedPrompt = _buildChatMLPrompt(systemPrompt, userMessage);

    // 6. On-Device GGUF Local Model Execution
    String response = '';
    try {
      final engine = await LocalLLMEngine.getInstance();
      response = await engine.generate(formattedPrompt);
    } on UnsupportedError {
      return '⚠️ On-device AI is not supported on this platform.';
    } catch (error, stackTrace) {
      // Keep native/runtime details in diagnostic logs only. Calling
      // getInstance() again here could initialize a second engine just to
      // dispose it, so leave engine lifecycle management to its owner.
      debugPrint('LLMService: local inference failed: $error\\n$stackTrace');
      return 'The on-device model could not generate a reply. '
          'Please try again. If this keeps happening, verify the model download '
          'and make sure your device has enough free memory.';
    }

    response = _cleanModelOutput(response);

    if (response.isEmpty) {
      return 'I couldn\'t generate a response from the on-device model this time. '
          'Your message is still here—please try again. If this keeps happening, '
          'check that the downloaded model is complete and that your device has '
          'enough available memory.';
    }

    // 7. Store conversation turn for continuous contextual memory
    conversationHistory.add({'role': 'user', 'content': userMessage});
    conversationHistory.add({'role': 'assistant', 'content': response});

    if (conversationHistory.length > 24) {
      conversationHistory.removeRange(0, 2);
    }

    return response;
  }

  /// Streams individual tokens for a real-time typing effect
  Stream<String> streamEmotionalBudResponse({
    required String userMessage,
    required String userName,
    required String personalityMode,
  }) async* {
    if (CrisisDetector.detectCrisis(userMessage)) {
      yield CrisisDetector.getCrisisResourceMessage();
      return;
    }

    final isDownloaded = await ModelDownloadService.isModelDownloaded();
    if (!isDownloaded) {
      yield '⚠️ Model not downloaded. Go to Profile & Settings to download it.';
      return;
    }

    final analysis = EmotionDetector.analyze(userMessage);
    final detectedEmotion = analysis['emotion'] as String;
    final emotionIntensity = analysis['intensity'] as double;

    final systemPrompt = SystemPromptGenerator.generatePrompt(
      userName: userName,
      personalityMode: personalityMode,
      detectedEmotion: detectedEmotion,
      emotionIntensity: emotionIntensity,
      recentContext: _getRecentContext(),
    );

    final formattedPrompt = _buildChatMLPrompt(systemPrompt, userMessage);

    try {
      final engine = await LocalLLMEngine.getInstance();
      final buffer = StringBuffer();

      await for (final token in engine.generateStream(formattedPrompt)) {
        if (token.contains('<|im_end|>') || token.contains('<|endoftext|>')) {
          final cleaned = token.replaceAll('<|im_end|>', '').replaceAll('<|endoftext|>', '');
          buffer.write(cleaned);
          if (cleaned.isNotEmpty) yield cleaned;
          break;
        }
        buffer.write(token);
        yield token;
      }

      final full = _cleanModelOutput(buffer.toString());
      if (full.isNotEmpty) {
        conversationHistory.add({'role': 'user', 'content': userMessage});
        conversationHistory.add({'role': 'assistant', 'content': full});
        if (conversationHistory.length > 24) {
          conversationHistory.removeRange(0, 2);
        }
      }
    } catch (error) {
      debugPrint('LLMService.streamEmotionalBudResponse error: $error');
      yield '\nI couldn\'t generate a reply from the on-device model. '
          'Please try again, and check that the model is downloaded correctly '
          'if the problem continues.';
    }
  }

  /// Formats system prompt, history, and user turn into ChatML standard:
  /// `<|im_start|>system ... <|im_end|>`
  /// `<|im_start|>user ... <|im_end|>`
  /// `<|im_start|>assistant`
  String _buildChatMLPrompt(String systemPrompt, String userMessage) {
    final sb = StringBuffer();
    sb.writeln('<|im_start|>system');
    sb.writeln(systemPrompt);
    sb.writeln('<|im_end|>');

    // Include up to 4 recent context turns in ChatML format
    final historyToInclude = conversationHistory.length > 8
        ? conversationHistory.sublist(conversationHistory.length - 8)
        : conversationHistory;

    for (final turn in historyToInclude) {
      final role = turn['role'] ?? 'user';
      final content = turn['content'] ?? '';
      sb.writeln('<|im_start|>$role');
      sb.writeln(content);
      sb.writeln('<|im_end|>');
    }

    sb.writeln('<|im_start|>user');
    sb.writeln(userMessage);
    sb.writeln('<|im_end|>');
    sb.write('<|im_start|>assistant\n');

    return sb.toString();
  }

  /// Strips ChatML stop tags and trailing artifacts from raw output
  String _cleanModelOutput(String raw) {
    var text = raw;
    text = text.replaceAll('<|im_end|>', '');
    text = text.replaceAll('<|endoftext|>', '');
    text = text.replaceAll('<|im_start|>', '');
    if (text.startsWith('assistant\n')) {
      text = text.substring(10);
    }
    return text.trim();
  }

  String _getRecentContext() {
    if (conversationHistory.isEmpty) return 'No recent conversation.';
    final recent = conversationHistory.length > 6
        ? conversationHistory.sublist(conversationHistory.length - 6)
        : conversationHistory;
    return recent.map((m) {
      final role = m['role'] == 'user' ? 'User' : 'Bud';
      return '$role: ${m['content']}';
    }).join('\n');
  }
}
