import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillow_bud/providers/app_state_provider.dart';
import 'package:pillow_bud/services/llm_service.dart';

// LLM Service Provider
final llmServiceProvider = Provider<LLMService>((ref) {
  return LLMService();
});

// Current emotion state
final currentEmotionProvider = StateProvider<String>((ref) => 'neutral');

final emotionIntensityProvider = StateProvider<double>((ref) => 0.5);

// Buddy personality (defined before budResponseProvider)
final buddyPersonalityProvider = StateProvider<String>((ref) => 'balanced');

// Bud response (with emotion awareness)
final budResponseProvider = FutureProvider.family<String, String>(
  (ref, userMessage) async {
    final llmService = ref.watch(llmServiceProvider);
    final userName = ref.watch(userNameProvider);
    final personalityMode = ref.watch(buddyPersonalityProvider);

    final response = await llmService.getEmotionalBudResponse(
      userMessage: userMessage,
      userName: userName,
      personalityMode: personalityMode,
    );

    return response;
  },
);

// UI-related
final isLoadingResponseProvider = StateProvider<bool>((ref) => false);
