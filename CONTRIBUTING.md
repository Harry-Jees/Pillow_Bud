# Contributing to Pillow Bud

Thank you for helping improve Pillow Bud. Contributions should protect privacy, support accessibility, and avoid overstating the app's mental-health or security capabilities.

## Before starting

1. Search existing issues and pull requests to avoid duplicate work.
2. For substantial changes, open an issue first to agree on the problem and scope.
3. Create a focused branch from the intended base.
4. Keep changes small and avoid unrelated visual or dependency changes.
5. Never include private conversations, journal entries, credentials, signing keys, keystores, local model files, generated builds, or personal data.

## Development setup

Install a compatible Flutter SDK and the platform toolchain required for your target. From the application directory:

```bash
cd pillow_bud
flutter pub get
dart format lib test
flutter analyze
flutter test
```

Consult [docs/TESTING.md](docs/TESTING.md) for manual tests and platform build commands. In your PR, list exactly which checks ran and their results. If a command could not run, say why; do not describe unexecuted checks as passing.

## Engineering standards

- Follow idiomatic Dart, Flutter conventions, and the existing architecture.
- Prefer small, testable services, explicit state transitions, and actionable user-facing errors.
- Do not log private user content, encryption keys, authentication material, or backup contents.
- Do not add cloud processing for private conversations without explicit product approval, privacy analysis, and clear user disclosure.
- Changes to encryption, backup formats, schemas, migrations, or key handling must include compatibility and tampering tests.
- Changes to crisis detection must test both high-risk language and ordinary phrases that could cause false positives. Do not imply that keyword detection can assess risk reliably.
- AI prompt changes should preserve non-clinical boundaries, user autonomy, and clear escalation to real-world support when appropriate.
- Preserve keyboard/screen-reader support, text scaling, contrast, reduced motion, and platform conventions.
- Keep documentation, manifests, dependency declarations, and actual implementation aligned.

## Pull request checklist

Include:
- the problem and expected behavior;
- the implementation and important trade-offs;
- tests/builds run, with actual outcomes;
- data migration or backup compatibility impact;
- platform coverage and known limitations;
- screenshots or a short recording for meaningful UI changes, without exposing private data.

Keep each PR focused and respond constructively to review. By participating, you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).
