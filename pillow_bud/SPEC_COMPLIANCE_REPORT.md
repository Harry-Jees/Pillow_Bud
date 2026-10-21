# Implementation and verification status

This report describes the current source tree. Implemented code, automated verification, manual device verification, and release readiness are separate statuses.

## Implemented areas

- Flutter app with chat, journal, mood insights, breathing, meditation, onboarding, profile, themes, and optional biometric lock.
- Optional local Qwen3 4B Instruct GGUF model download and inference through `llama_cpp` on supported native platforms.
- SQLite persistence, OS secure storage, authenticated encryption for new sensitive records, and compatibility reads for legacy unauthenticated records.
- Chat sessions/history, optional mood notes, a saved coping plan, and crisis phrase checks with India-focused support resources.
- PBv3 passphrase-protected portable backup export/import, with PBKDF2-HMAC-SHA256 key derivation, AES-CBC encryption, HMAC-SHA256 verification before decryption, and transactional restore.
- Legacy PBv2 import support for backups tied to the original installation key.
- Unit tests for selected encryption, backup validation, crisis-detection, date-streak, and widget behaviors.

## Known limitations

- The model is a large optional download (approximately 2.5 GB); memory use and inference quality vary by device.
- Model download requires internet access. Normal model inference is intended to run locally.
- Phrase-based crisis detection is not a clinical assessment and may miss risk or flag benign language.
- Legacy IV-only database records are not authenticated. Compatibility reads should not be mistaken for the security level of new records.
- Some chat/journal data is persisted in both SQLite and encrypted SharedPreferences; this duplicate path needs consolidation.
- PBv3 is a custom backup format and has not had an independent cryptographic review. PBv2 remains installation-bound.
- Web is not a supported target for local inference and native persistence.
- Release signing and native builds must be verified on their target environments.

## Verification status

The repository has new regression tests, including PBv3 wrong-passphrase, ciphertext-tampering, malformed-envelope checks, but test files are **not proof that the tests pass**. Flutter/Dart analysis, automated tests, and native builds have not been executed in the current editing environment.

Run from this directory:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Then follow [../docs/TESTING.md](../docs/TESTING.md) for manual device tests and native build checks. Record the SDK version and actual command results. Do not describe the branch as release-ready until those checks pass.
