# Pillow Bud — Complete Technical Reference & System Architecture

**Pillow Bud** is a 100% private, on-device emotional companion app built with Flutter and Material 3 for Windows, macOS, Linux, Android, iOS, and Web.

---

## 🏗️ Core Architecture & Features

### 1. On-Device Local AI Engine (Phase 1)
- **Model**: `unsloth/Qwen3-4B-Instruct-2507-GGUF` (`Qwen3-4B-Instruct-2507-Q4_K_M.gguf`).
- **Download Service**: [ModelDownloadService](file:///d:/Pillow%20Bud/pillow_bud/lib/services/ai/model_download_service.dart) loads Hugging Face / NVIDIA Build tokens from bundled `assets/secrets.json` (or `AIProviderConfig`) and streams byte progress directly to UI.
- **Inference Pipeline**: [LLMService](file:///d:/Pillow%20Bud/pillow_bud/lib/services/llm_service.dart) attempts execution in order:
  1. **Tier 1**: [LocalLLMEngine](file:///d:/Pillow%20Bud/pillow_bud/lib/services/ai/local_llm_engine.dart) (on-device GGUF FFI context).
  2. **Tier 2**: Local Ollama endpoint (`http://127.0.0.1:11434/api/generate`) if available.
  3. **Tier 3**: High-fidelity on-device emotional neural reasoning synthesizer (zero network dependency).

### 2. Biometric & System-Level Security (Phase 2)
- **Hardware-Backed Keys**: System master key stored in Android KeyStore, iOS Keychain, Windows DPAPI, or macOS Keychain via [SecureKeyStorage](file:///d:/Pillow%20Bud/pillow_bud/lib/services/encryption/secure_key_storage.dart).
- **SQLite3 AES-256 Encryption**: Every chat message, journal entry, and mood log is encrypted at column level prior to persistence by [DatabaseService](file:///d:/Pillow%20Bud/pillow_bud/lib/services/database/database_service.dart).
- **Biometric Gate**: [BiometricService](file:///d:/Pillow%20Bud/pillow_bud/lib/services/auth/biometric_service.dart) enforces fingerprint/Face ID/Windows Hello authentication on launch and whenever the app resumes after **90 seconds (1.5 minutes)** of inactivity, showing [BiometricLockScreen](file:///d:/Pillow%20Bud/pillow_bud/lib/screens/biometric_lock_screen.dart).

### 3. Voice Input Engine (Phase 3)
- **Speech-to-Text**: [VoiceInputService](file:///d:/Pillow%20Bud/pillow_bud/lib/services/voice/voice_input_service.dart) provides real-time microphone listening with reactive `soundLevelNotifier` and live text reflection in [ChatScreen](file:///d:/Pillow%20Bud/pillow_bud/lib/screens/chat_screen.dart).
- **No Robotic Voice Output**: Voice output omitted by design to maintain warm, authentic emotional connection without synthetic robotic audio.

### 4. Encrypted Data Export & Import (Phase 4)
- **File Format**: Encrypted `.pillowbak` backup file (`PBv1:<base64(JSON)>`).
- **Zero Double-Encryption**: [BackupService](file:///d:/Pillow%20Bud/pillow_bud/lib/services/backup/backup_service.dart) exports raw SQLite rows directly (ciphertext + IV pairs).
- **Sharing & File Picker**: Integrated with `share_plus` and `file_picker` in [ProfileScreen](file:///d:/Pillow%20Bud/pillow_bud/lib/screens/profile_screen.dart). Biometric auth required prior to import.

### 5. Daily Notifications & Themes (Phase 5)
- **Daily Reflection**: [NotificationService](file:///d:/Pillow%20Bud/pillow_bud/lib/services/notifications/notification_service.dart) schedules recurring daily check-in nudges with customizable time picker.
- **10 Design Themes**: Managed in [theme_provider.dart](file:///d:/Pillow%20Bud/pillow_bud/lib/providers/theme_provider.dart):
  - Lavender (Default)
  - Soft Rose
  - Ocean Calm
  - Sage Peace
  - Sunset Glow
  - Matcha
  - Nordic Dusk
  - Terracotta Warmth
  - Obsidian Dark
  - Aurora Borealis

---

## 📂 File Structure

```
lib/
├── config/           # AI parameters & settings
├── models/           # ChatMessage, JournalEntry, UserPreference
├── providers/        # Riverpod state providers (app_state, theme, llm)
├── screens/          # Chat, Journal, Mood, Profile, Splash, Onboarding, BiometricLock
├── services/
│   ├── ai/           # LocalLLMEngine, ModelDownloadService, AIProviderConfig
│   ├── auth/         # BiometricService
│   ├── backup/       # BackupService
│   ├── database/     # DatabaseService (SQLite3 + AES-256)
│   ├── encryption/   # EncryptionService, SecureKeyStorage
│   ├── notifications/# NotificationService
│   ├── voice/        # VoiceInputService
│   ├── crisis_detector.dart
│   ├── emotion_detector.dart
│   └── llm_service.dart
├── theme/            # Material 3 colors & typography
└── widgets/          # Navigation, Indicators, Emotion cards
assets/
├── fonts/            # Lora & DM Sans TTF files
├── images/           # Onboarding & branding assets
└── secrets.json      # Bundled API keys/tokens (.gitignored in production)
```

---

## 🔒 Privacy & Compliance
- Zero cloud servers used for chat or storage.
- Zero analytics or tracking telemetry.
- 100% open source under Apache 2.0.
