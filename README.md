# Pillow Bud

Pillow Bud is a Flutter emotional-wellness companion with chat, journaling, mood tracking, breathing and meditation exercises, personalization, optional biometric locking, and crisis-resource guidance.

> **Important:** Pillow Bud is not a medical service, therapist, or emergency response service. It can make mistakes and should not be relied on for crisis intervention.

## Repository layout

- `pillow_bud/` — the actual Flutter application.
- `docs/ARCHITECTURE.md` — implementation overview and known platform limits.
- `SECURITY.md` — how to report security issues.
- `CONTRIBUTING.md` and `CODE_OF_CONDUCT.md` — community guidance.

The root is documentation-only. Run Flutter commands from `pillow_bud/`.

## Features

- Conversational companion powered by an optional downloaded local GGUF model (currently Qwen3 4B Instruct).
- Journaling, mood history, and insights.
- Guided breathing and meditation screens.
- Personality and theme preferences.
- Optional biometric app lock and voice input.
- Local notifications and data export/import.
- Crisis phrase detection with support-resource messaging.

## Requirements

Install a compatible Flutter SDK and platform toolchains. The project targets Flutter-supported Android, iOS, Windows, macOS, and Linux builds where all required plugins are supported. Web is not considered supported because local inference and several services rely on native APIs.

## Run locally

```bash
cd pillow_bud
flutter pub get
flutter analyze
flutter test
flutter run
```

The local model is a separate, large download. Download it only from the in-app model settings. Confirm sufficient free storage before starting.

## Android release signing

Release builds must use a private upload keystore configured in `pillow_bud/android/key.properties`. See the official [Flutter Android release guide](https://docs.flutter.dev/deployment/android). Never commit the keystore or its passwords.

## Privacy and security

- Chat and journal content is encrypted before database persistence.
- New database records use AES-CBC with HMAC-SHA256 authentication; older records remain readable for migration and are not authenticated.
- Mood labels are encrypted in newly written database records.
- Preferences and some app state still use platform preferences; do not treat every stored value or exported backup as encrypted.
- Exported backups are currently Base64-encoded, **not encrypted**. Treat them as sensitive and do not share them.
- Local inference does not require a hosted AI endpoint, but downloading the model requires a network connection.

Read [SECURITY.md](SECURITY.md) and [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) before making security or persistence changes.

## Community

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## License

Apache-2.0. See [LICENSE](LICENSE).
