/// AI Configuration - Llama 3.2 1B with emotional intelligence
class AIConfig {
  // Model Info
  static const String modelName = 'Llama 3.2 1B';
  static const String modelSize = '~700 MB';
  static const String modelFormat = 'GGUF';
  static const int contextWindow = 8192;

  // Model Download URL (from Hugging Face)
  // Replace with actual model URL when available
  static const String modelDownloadUrl =
      'https://huggingface.co/models/meta-llama/Llama-3.2-1B-Instruct-GGUF/resolve/main/llama-3.2-1b-instruct-q4_k_m.gguf';

  // Local storage paths
  static const String modelStorageKey = 'llama_model_path';

  // Generation Parameters
  static const int maxTokens = 300;
  static const double temperature = 0.8; // Warm and creative
  static const double topP = 0.95;
  static const double topK = 40;
  static const int repeatPenalty = 1;

  // Response timing (milliseconds)
  static const int thinkingDelay = 120; // Keep the interface feeling responsive
  static const int streamingDelay = 50; // Delay between tokens

  // Safety & Content Filtering
  static const bool enableSafetyFilter = true;
  static const int maxResponseLength = 500;
  static const int minResponseLength = 20;

  // Emotional States Supported
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

  // Bud Personality Modes
  static const Map<String, String> personalityModes = {
    'gentle': 'Soft, validating, focused on listening',
    'curious': 'Asks exploratory questions, helps think deeper',
    'wise': 'Reflective, thoughtful, offers gentle perspective',
    'balanced': 'Mix of all three approaches',
  };
}
