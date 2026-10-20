import 'package:flutter/foundation.dart';
import 'package:pillow_bud/services/encryption/secure_key_storage.dart';

enum AIProviderType {
  onDeviceNeural, // 100% Offline On-Device Neural Engine
  nvidiaBuild,    // NVIDIA Build / NIM API
  huggingFace,    // Hugging Face Inference API / Hub
}

class AIProviderConfig {
  static const String _hfKeyStorageKey = 'hf_api_token';
  static const String _nvidiaKeyStorageKey = 'nvidia_api_key';
  static const String _activeProviderKey = 'active_ai_provider';
  static const String _activeModelKey = 'active_ai_model';

  static AIProviderType activeProvider = AIProviderType.onDeviceNeural;
  static String activeModel = 'unsloth/Qwen3-4B-Instruct-2507-GGUF';
  static String? huggingFaceToken;
  static String? nvidiaApiKey;

  static final ValueNotifier<AIProviderType> providerNotifier =
      ValueNotifier(AIProviderType.onDeviceNeural);
  static final ValueNotifier<String> modelNotifier =
      ValueNotifier('unsloth/Qwen3-4B-Instruct-2507-GGUF');

  /// Popular vetted models supported out-of-the-box
  static const List<Map<String, String>> popularModels = [
    {
      'id': 'unsloth/Qwen3-4B-Instruct-2507-GGUF',
      'name': 'Qwen3 4B Instruct GGUF (Unsloth Recommended)',
      'provider': 'huggingface',
      'hf_repo': 'unsloth/Qwen3-4B-Instruct-2507-GGUF',
    },
    {
      'id': 'meta/llama-3.2-1b-instruct',
      'name': 'Llama 3.2 1B Instruct (Ultra Lightweight & Fast)',
      'provider': 'nvidia',
      'hf_repo': 'meta-llama/Llama-3.2-1B-Instruct',
    },
    {
      'id': 'meta/llama-3.2-3b-instruct',
      'name': 'Llama 3.2 3B Instruct (High Empathy & Reasoning)',
      'provider': 'nvidia',
      'hf_repo': 'meta-llama/Llama-3.2-3B-Instruct',
    },
    {
      'id': 'mistralai/mistral-7b-instruct-v0.3',
      'name': 'Mistral 7B Instruct v0.3 (Deep Conversational Nuance)',
      'provider': 'nvidia',
      'hf_repo': 'mistralai/Mistral-7B-Instruct-v0.3',
    },
    {
      'id': 'HuggingFaceTB/SmolLM2-1.7B-Instruct',
      'name': 'SmolLM2 1.7B Instruct (Hugging Face Lightweight)',
      'provider': 'huggingface',
      'hf_repo': 'HuggingFaceTB/SmolLM2-1.7B-Instruct',
    },
    {
      'id': 'Qwen/Qwen2.5-0.5B-Instruct',
      'name': 'Qwen 2.5 0.5B Instruct (Ultra Fast Minimalist)',
      'provider': 'huggingface',
      'hf_repo': 'Qwen/Qwen2.5-0.5B-Instruct',
    },
  ];

  /// Loads saved AI keys and provider settings securely
  static Future<void> loadSettings() async {
    try {
      huggingFaceToken = await SecureKeyStorage.read(_hfKeyStorageKey);
      nvidiaApiKey = await SecureKeyStorage.read(_nvidiaKeyStorageKey);
      
      final savedProvider = await SecureKeyStorage.read(_activeProviderKey);
      if (savedProvider != null) {
        if (savedProvider == 'nvidiaBuild') {
          activeProvider = AIProviderType.nvidiaBuild;
        } else if (savedProvider == 'huggingFace') {
          activeProvider = AIProviderType.huggingFace;
        } else {
          activeProvider = AIProviderType.onDeviceNeural;
        }
      }

      final savedModel = await SecureKeyStorage.read(_activeModelKey);
      if (savedModel != null && savedModel.isNotEmpty) {
        activeModel = savedModel;
      }

      providerNotifier.value = activeProvider;
      modelNotifier.value = activeModel;
    } catch (e) {
      debugPrint('Error loading AI provider settings: $e');
    }
  }

  /// Updates the active AI Provider and persists it
  static Future<void> setProvider(AIProviderType provider) async {
    activeProvider = provider;
    providerNotifier.value = provider;
    await SecureKeyStorage.write(
      _activeProviderKey,
      provider.name,
    );
  }

  /// Sets and securely persists the Hugging Face User Access Token
  static Future<void> setHuggingFaceToken(String token) async {
    huggingFaceToken = token.trim();
    await SecureKeyStorage.write(
      _hfKeyStorageKey,
      token.trim(),
    );
  }

  /// Sets and securely persists the NVIDIA Build NIM API Key
  static Future<void> setNvidiaApiKey(String key) async {
    nvidiaApiKey = key.trim();
    await SecureKeyStorage.write(
      _nvidiaKeyStorageKey,
      key.trim(),
    );
  }

  /// Sets active model ID
  static Future<void> setActiveModel(String modelId) async {
    activeModel = modelId;
    modelNotifier.value = modelId;
    await SecureKeyStorage.write(
      _activeModelKey,
      modelId,
    );
  }
}
