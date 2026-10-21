# Testing and release verification

Run commands from `pillow_bud/` with a Flutter SDK compatible with `pubspec.yaml`. Record the SDK version, OS, device, exact command, and actual result in the pull request or release notes.

## Automated checks

```bash
flutter --version
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

If formatting reports changes, run `dart format lib test` and inspect the resulting diff before committing. Do not report tests as passing unless the commands completed successfully.

## Focused test areas

| Area | Required coverage |
|---|---|
| Encryption | Round-trip, random IVs, ciphertext/tag tampering, legacy record compatibility, secure-key-store failure |
| Backups | PBv3 export/import round-trip, wrong passphrase, modified MAC/ciphertext, truncated/malformed archives, malformed rows, no partial restore, cross-install import, PBv2 compatibility |
| Database | Fresh schema, upgrades from previous schema versions, encrypted mood fields, corrupted records, session separation |
| Model download | Valid GGUF header, truncated file, interrupted/resumed range requests, cancellation, disk/storage failures, invalid response |
| Local inference | Missing/corrupt model, native load failure, empty generation, generation serialization, real device response quality |
| Crisis detection | Explicit and indirect risk phrases, punctuation/case, standalone denial, ordinary phrases and false-positive examples |
| Chat state | Streaming, new session, switching sessions mid-stream, clear history, restoring persisted context, stale-response isolation |
| UI/accessibility | Splash and haptic behavior, reduced motion, text scaling, contrast, semantics, keyboard/focus, touch targets, small screens |
| Restore refresh | After importing, verify chat, journal, mood history, and model conversation context reflect restored data |

## Manual device smoke tests

1. Complete onboarding and restart the app to verify persisted settings.
2. Download the model on a stable connection; interrupt and resume it; verify incomplete files are not marked ready.
3. Send several practical and emotional messages. Confirm replies are relevant, concise, nonjudgmental, and not repetitive. Repeat on a low-memory device if possible.
4. Stream a reply, start a new conversation, and switch sessions while generation is active. Confirm messages never leak into another session.
5. Create journal entries, mood notes, and a coping plan; restart; verify data persistence and expected encryption boundaries.
6. Export PBv3, import it on the same installation, and test wrong passphrase and modified/truncated copies. Then restore into a clean installation and verify data and session relationships.
7. Attempt PBv2 import only with a known legacy fixture and the original installation key.
8. Exercise crisis detector test phrases and inspect the UI copy. Do not use real personal crisis disclosures as test fixtures.
9. Test lock/unlock, app background/resume, notifications, voice input, and export cancellation where supported.
10. Build and launch each target on its actual supported platform. Confirm startup, database initialization, model handling, navigation, and clean shutdown.

## Build matrix

These are commands to run on the appropriate host; they are not a claim that the builds have passed.

- Android APK: `flutter build apk --release` (requires valid private release signing configuration).
- Android app bundle: `flutter build appbundle --release` (same signing requirement).
- Windows: `flutter build windows --release` on Windows with Visual Studio build tools.
- Linux: `flutter build linux --release` on Linux with required native build dependencies.
- macOS: `flutter build macos --release` on macOS with Xcode.
- iOS: `flutter build ios --release` on macOS with Xcode and a valid signing setup.

Web is not a supported target.

## Current verification rule

A code review, test file, or configured build target is not equivalent to a successful run. If the Flutter SDK, platform SDK, signing credentials, or physical device is unavailable, mark that check **not run** and state what is missing. Do not trigger a workflow rerun just to make a status look green; use the repository's approved verification process.
