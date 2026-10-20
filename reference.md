# Pillow Bud — Technical Reference

This document describes the implementation in the repository, not the older prototype specifications.

## Runtime flow

1. `lib/main.dart` initializes preferences, the SQLite database, model-download state, and notifications.
2. Riverpod providers expose theme and app state to the screens.
3. `LLMService` runs crisis phrase detection, emotion analysis, prompt generation, and local inference.
4. `LocalLLMEngine` loads the downloaded GGUF model using `llama_cpp`.
5. `DatabaseService` persists chat messages, journal entries, preferences, and mood logs.
6. `SecureKeyStorage` obtains the database encryption key from the OS secure-storage plugin.

## AI model

The downloader currently targets `Qwen3-4B-Instruct-2507-Q4_K_M.gguf` from the Unsloth Hugging Face repository. `AIConfig` should remain aligned with `ModelDownloadService`. Model download requires network access; inference is intended to run locally.

## Persistence and encryption

Chat and journal text is encrypted before database writes. New records use AES-CBC plus HMAC-SHA256 authentication with independent derived key material. Older records containing only an IV are supported for compatibility and are not authenticated. Newly written mood labels are encrypted; legacy mood labels may remain plaintext until migrated or rewritten.

`StorageService` stores ordinary preferences in SharedPreferences and encrypts serialized chat/journal payloads before saving them there. This duplicate persistence path should eventually be consolidated. Backup export Base64-encodes JSON and is **not encrypted**; it is installation-key-bound and cannot currently be restored on a different installation.

## Platform limits

Native builds are the intended target. The local model engine explicitly rejects Web. Platform-specific plugin support must be verified by building and testing on each target OS.

## Verification commands

Run from `pillow_bud/`:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

A successful static analysis or unit test run does not replace real-device verification, release-signing checks, or security review.
