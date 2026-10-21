# Architecture and maintenance reference

## Application layout

The Flutter project lives in `pillow_bud/`. Run all Flutter and Dart commands from that directory.

- `lib/main.dart` — app initialization and root widget.
- `lib/screens/` — onboarding, home, chat, journal, insights, profile/settings, breathing, meditation, and splash screens.
- `lib/providers/` — Riverpod state and theme providers.
- `lib/models/` — chat, journal, and preference models.
- `lib/services/llm_service.dart` — crisis-first message handling, emotion analysis, prompt assembly, response cleanup, and conversation context.
- `lib/services/system_prompt_generator.dart` — Bud persona, response style, emotional-support approach, and safety boundaries.
- `lib/services/ai/` — local model download and GGUF inference.
- `lib/services/crisis_detector.dart` — phrase-based crisis marker detection and India support-resource copy.
- `lib/services/database/` — SQLite persistence and session/mood queries.
- `lib/services/encryption/` — secure master-key access and encrypted record operations.
- `lib/services/backup/` — PBv3 portable backup export/import and legacy PBv2 compatibility.
- `lib/services/storage_service.dart` — preferences and encrypted serialized chat/journal/coping-plan payloads.
- `lib/theme/` and `lib/widgets/` — theme, reusable UI, calm-moment tools, and visual components.
- `test/` — unit and service-level tests.

## AI request path

1. Chat input is checked by the crisis phrase detector.
2. If a trigger is detected, the service returns crisis-resource guidance instead of calling the model.
3. Otherwise, local emotion heuristics estimate an emotion and intensity.
4. The system prompt is assembled with the selected personality and support guidance.
5. The app checks for a valid downloaded GGUF file and loads Qwen3 4B Instruct through `llama_cpp` on supported native platforms.
6. Generation uses a bounded context and sampling settings configured in `LocalLLMEngine`; the response is cleaned before being displayed.
7. Conversation-history revisions guard against stale in-flight responses repopulating context after a reset or session switch.

The exact model download source and model filename are defined in `lib/services/ai/model_download_service.dart`. Model download requires internet access and sufficient storage. Native inference can fail because of memory, file, plugin, or platform limitations. Web is not supported.

## Persistence and encryption

- SQLite stores chat messages, journal entries, preferences, and mood logs.
- New sensitive record fields use AES-256-CBC plus HMAC-SHA256 authentication. The IV column stores the Base64 IV and authentication tag together.
- Legacy IV-only encrypted fields remain readable for compatibility; these records are not authenticated. Migration behavior must be preserved and tested before changing the format.
- New mood labels are encrypted. Legacy plaintext values may remain until rewritten or migrated.
- SharedPreferences also stores serialized chat and journal payloads encrypted with the initialized encryption service, as well as the coping plan. This duplicates some data stored in SQLite; consolidating to one authoritative repository is still outstanding.
- The master key must be obtained from OS secure storage. Failure should stop protected operations rather than silently use a hardcoded key.
- PBv3 exports the logical archive inside a passphrase-protected encrypted envelope. It derives separate encryption and MAC keys with PBKDF2-HMAC-SHA256, encrypts with AES-CBC, and verifies HMAC-SHA256 before decryption. Portable import re-encrypts records using the destination installation's key.
- Legacy PBv2 import remains installation-bound and depends on the original key. Do not remove it without a migration plan and compatibility tests.

These details describe the implementation, not a claim of independent security certification. See [SECURITY.md](../SECURITY.md).

## UI and accessibility

The UI uses Material 3 theming, a floating translucent mobile navigation treatment, animated screen transitions, and a splash-logo reveal with haptic feedback where supported. Reduced-motion settings should be respected. Check keyboard navigation, semantic labels, contrast, text scaling, and platform-specific behavior during manual testing.

## Verification

Follow [TESTING.md](TESTING.md) for commands and manual checks. At minimum, run:

```bash
cd pillow_bud
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Then build and smoke-test each supported native target using its platform toolchain. Never record a build or test as passed unless it was actually executed. Android release builds need a private signing setup that must not be committed.
