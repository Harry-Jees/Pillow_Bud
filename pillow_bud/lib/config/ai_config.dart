/// Configuration for the local Qwen3 4B Instruct GGUF model.
class AIConfig {
  static const String modelName = 'Qwen3 4B Instruct';
  static const String modelSize = '~2.5 GB (quantized GGUF)';
  static const String modelFormat = 'GGUF';
  static const int contextWindow = 2048;

  // Kept aligned with ModelDownloadService.defaultModelUrl.
  static const String modelDownloadUrl =
      'https://huggingface.co/unsloth/Qwen3-4B-Instruct-2507-GGUF/resolve/main/Qwen3-4B-Instruct-2507-Q4_K_M.gguf';

  static const String modelStorageKey = 'qwen3_model_path';

  static const int maxTokens = 300;
  static const double temperature = 0.7;
  static const double topP = 0.9;
  static const int topK = 40;
  static const double repeatPenalty = 1.0;

  static const int thinkingDelay = 120;
  static const int streamingDelay = 50;

  static const bool enableSafetyFilter = true;
  static const int maxResponseLength = 500;
  static const int minResponseLength = 20;

  static const List<String> emotionalStates = [
    'overwhelmed',
    'anxious',
    'sad',
    'lonely',
    'stressed',
    'confused',
    'hopeful',
    'calm',
    'angry',
    'uncertain',
  ];

  static const Map<String, String> personalityModes = {
    'gentle': 'Soft, validating, focused on listening',
    'curious': 'Asks exploratory questions, helps think deeper',
    'wise': 'Reflective, thoughtful, offers gentle perspective',
    'balanced': 'Mix of all three approaches',
  };
}
