# Pillow Bud Flutter application

This directory contains the Flutter app source and platform projects.

## Prerequisites

- Flutter SDK compatible with the Dart SDK constraint in `pubspec.yaml`
- Android Studio / Android SDK for Android builds
- Xcode for iOS and macOS builds
- The relevant desktop toolchain for Windows or Linux

## Setup

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Local AI

The app currently downloads the Qwen3 4B Instruct quantized GGUF model through `ModelDownloadService` and runs it through `llama_cpp` on supported native platforms. The model is large and requires additional storage and memory. Model download is not needed to compile the app, but AI chat requires a valid downloaded model.

## Platform support

Native platforms are the intended target. Web support is not guaranteed because local inference, file access, secure storage, and database services rely on platform-specific APIs.

## Security notes

- Secure key storage is required for encrypted database records; encryption must fail closed if the OS secure store is unavailable.
- Existing records written by older versions may use unauthenticated encryption.
- The current backup export is Base64-encoded rather than encrypted. Treat exported files as sensitive.
- Release Android builds require a private signing configuration in `android/key.properties`.

See the repository root README and `../docs/ARCHITECTURE.md` for the project overview.
