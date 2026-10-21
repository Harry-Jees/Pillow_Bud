# Pillow Bud

Pillow Bud is a Flutter emotional-wellness companion for private reflection, journaling, mood check-ins, and small grounding exercises. Its conversational companion runs a downloaded local GGUF model on supported native platforms.

> **Important:** Pillow Bud is not a medical service, therapist, diagnostic tool, or emergency response service. AI output and crisis phrase detection can be wrong. Do not rely on the app for urgent help.

## What it includes

- Local AI chat with a configurable companion personality and emotion-aware response guidance.
- Conversation history and separate chat sessions.
- Private journal entries, mood check-ins, optional mood notes, and mood insights.
- Guided breathing, grounding, and a personal coping-step plan.
- Optional biometric/app lock, voice input, reminders, and theme preferences.
- Model download management with file checks and user-visible failure handling.
- Local data export/import, including passphrase-protected portable PBv3 backups and legacy PBv2 import support.

## Repository layout

- `pillow_bud/` — Flutter application, platform projects, assets, and tests.
- `docs/ARCHITECTURE.md` — application flow, storage design, and known limitations.
- `docs/TESTING.md` — verification commands and manual test matrix.
- `TODO.md` — consolidated maintenance backlog.
- `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, and `SECURITY.md` — contributor and community policies.

The repository root is documentation-oriented. Run Flutter commands from `pillow_bud/`.

## Requirements and setup

Install a Flutter SDK compatible with `pillow_bud/pubspec.yaml`, plus the platform-specific toolchain for the target you want to build.

```bash
cd pillow_bud
flutter pub get
flutter analyze
flutter test
flutter run
```

The local model is a large separate download (approximately 2.5 GB as presented in the app). Download it from the in-app model settings and ensure enough free storage and memory are available. Model download requires internet access; inference is intended to run locally after the model is installed.

## Platform support

The intended native targets are Android, iOS, Windows, macOS, and Linux, subject to plugin and toolchain compatibility. Web is **not supported**: local inference and several storage/database services rely on native APIs. Do not interpret target configuration as proof that a platform build or release has passed; see [the testing matrix](docs/TESTING.md).

Android release signing requires a private upload keystore and `pillow_bud/android/key.properties`. Follow the official [Flutter Android deployment guide](https://docs.flutter.dev/deployment/android). Never commit signing keys or passwords.

## Privacy and security notes

- New encrypted database records use AES-256-CBC with HMAC-SHA256 authentication. Older IV-only records remain readable for migration compatibility and are not authenticated.
- The OS secure-storage master key is required; encryption must not fall back to a hardcoded key.
- Chat and journal data is also persisted in encrypted form through SharedPreferences, in addition to SQLite. Consolidating these duplicate persistence paths remains maintenance work.
- PBv3 backups encrypt the archive with a passphrase-derived key and authenticate it before decryption. PBv2 backups are legacy, installation-bound files.
- The backup format and the application have not been represented as independently security-audited. Protect passphrases and backup files, and keep a separate copy of important data.
- Model downloads need a network connection. Normal local inference is not a hosted AI API call.

Read [SECURITY.md](SECURITY.md) and [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) before changing security, AI safety, or persistence code.

## Community

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before opening a pull request.

## License

Apache-2.0. See [LICENSE](LICENSE).
