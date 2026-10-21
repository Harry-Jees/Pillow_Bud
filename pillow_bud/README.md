# Pillow Bud — Flutter application

This directory contains the Flutter app source, native platform projects, assets, and tests. The repository root contains the project overview and community policies.

## Prerequisites

- Flutter SDK compatible with the Dart constraint in `pubspec.yaml`
- Android Studio and Android SDK for Android builds
- Xcode for iOS and macOS builds
- Visual Studio build tools for Windows
- Required C/C++ build tooling and GTK development libraries for Linux

Exact plugin support and system requirements vary by Flutter and dependency version. Web is not supported because the app depends on native local inference and storage/database APIs.

## Setup and verification

Run from this directory:

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

## Local AI model

The app downloads a Qwen3 4B Instruct quantized GGUF model through `ModelDownloadService` and runs it through `llama_cpp` on supported native platforms. The model is large and needs additional storage and memory. Downloading requires internet access; chatting requires a valid model file. A successful model download does not guarantee that inference will work on every device.

## Data and backups

Sensitive SQLite fields use authenticated encryption for new records; legacy records may remain unauthenticated until migrated. Chat and journal payloads are also stored encrypted in SharedPreferences, which duplicates some persistence. PBv3 backups are passphrase-protected and portable in design; PBv2 is a legacy same-installation format. Backup round trips and cross-install restore must be tested before relying on them as the only copy of important data.

## Release notes

Android release signing requires a private configuration in `android/key.properties` and a private keystore. Never commit either. Build commands and manual checks are documented in `../docs/TESTING.md`.

See the root [README](../README.md), [architecture reference](../docs/ARCHITECTURE.md), and [security policy](../SECURITY.md).
