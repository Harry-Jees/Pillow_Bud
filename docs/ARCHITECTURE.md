# Architecture and maintenance notes

## Application structure

- `lib/main.dart`: initializes storage, database, model-download state, notifications, and the root widget.
- `lib/screens/`: onboarding, home, chat, journal, insights, profile, breathing, meditation, biometric lock, and supporting screens.
- `lib/providers/`: Riverpod state and theme providers.
- `lib/models/`: chat, journal, and user preference models.
- `lib/services/llm_service.dart`: crisis-first message handling, emotion analysis, prompt assembly, and local inference.
- `lib/services/ai/`: model download and native GGUF inference.
- `lib/services/database/`: SQLite persistence.
- `lib/services/encryption/`: secure key storage and encrypted record handling.
- `lib/services/backup/`: local export/import.
- `lib/theme/` and `lib/widgets/`: visual system and reusable components.

## AI flow

1. The user message is checked by the crisis phrase detector.
2. Emotion and intensity are estimated using local heuristics.
3. A personality-aware system prompt is assembled with recent in-memory conversation context.
4. The downloaded Qwen3 4B Instruct GGUF model is loaded through `llama_cpp` on supported native targets.
5. The result is cleaned and returned to the chat UI.

This is local inference, not a hosted model API. Model downloads contact Hugging Face and require network access. Model files are large and can fail due to storage, memory, or native runtime limitations.

## Data and encryption

- The master key must be read from OS secure storage. Failure is fatal for encryption; never replace it with a compiled-in default.
- New database text records use AES-256-CBC plus HMAC-SHA256 encrypt-then-MAC authentication. The IV field stores `base64(iv).hex(mac)`.
- Existing IV-only records are supported for compatibility but are unauthenticated. Add a carefully tested migration before removing this compatibility path.
- New mood labels are encrypted in database writes; legacy labels may remain plaintext until rewritten.
- `StorageService` currently persists some app state and serialized chat/journal content in SharedPreferences. That is a known privacy debt.
- Backup export is Base64-encoded JSON, not encryption. Do not store or share exports as though they were protected.

## Platform support

The native Flutter targets are the intended scope, subject to each plugin's supported platforms. The local inference engine explicitly rejects Web. Do not claim Web support without removing or isolating native-only dependencies and testing the complete app in a browser.

## Local verification

Run commands from `pillow_bud/`:

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
```

Build and smoke-test each target separately. Release Android signing requires a private `android/key.properties` file and an upload keystore that must never be committed.
