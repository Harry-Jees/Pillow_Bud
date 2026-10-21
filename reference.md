# Pillow Bud — Technical Reference

This document describes the current implementation, not the older prototype specifications.

## Runtime flow

1. `lib/main.dart` initializes app services, preferences, SQLite, model-download state, and notifications.
2. Riverpod providers expose theme and app state to the screens.
3. `LLMService` checks selected crisis phrases, estimates emotion, creates the system prompt, and requests local inference.
4. `LocalLLMEngine` loads the downloaded GGUF model using `llama_cpp` on supported native platforms.
5. `DatabaseService` persists chat messages, journal entries, preferences, and mood logs.
6. `SecureKeyStorage` obtains the record-encryption master key from the operating system's secure credential store.

## AI model

The downloader targets `Qwen3-4B-Instruct-2507-Q4_K_M.gguf` from the Unsloth Hugging Face repository. Keep `AIConfig` and `ModelDownloadService` aligned when changing model configuration. Downloading requires internet access; inference is intended to run locally. The model is large and may not run well on every device.

## Persistence and encryption

Chat and journal text is encrypted before database writes. New records use AES-CBC with HMAC-SHA256 authentication. Older records containing only an IV are supported for compatibility and are not authenticated; migration must be preserved and tested. Newly written mood labels are encrypted, while older plaintext metadata may remain until migrated or rewritten.

`StorageService` also encrypts serialized chat/journal payloads and the coping plan before storing them in SharedPreferences. This duplicates some data already held in SQLite and should eventually be consolidated.

### Backup formats

- **PBv3:** the complete logical archive is protected by a passphrase-derived key. PBKDF2-HMAC-SHA256 with 120,000 iterations derives separate encryption and MAC keys; AES-CBC encrypts the archive and HMAC-SHA256 is verified before decryption. Import re-encrypts sensitive records using the destination installation's key and restores tables transactionally.
- **PBv2:** legacy, installation-bound backup. It requires the original installation key and is not portable.

PBv3 is a custom format and has not received independent cryptographic review. Keep backups and passphrases private and maintain another copy of important data until restore testing is complete.

## Platform limits

Native builds are intended. The local model engine explicitly rejects Web. Verify plugin compatibility by building and testing on each target OS; target configuration alone does not prove support.

## Verification

Run from `pillow_bud/`:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

A successful test run does not replace real-device verification, release-signing checks, backup restore testing, or security review.
