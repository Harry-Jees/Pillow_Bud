# Contributing to Pillow Bud

Thanks for helping improve Pillow Bud. Changes should protect user privacy, preserve accessibility, and avoid overstating mental-health or security capabilities.

## Before opening a pull request

1. Open an issue or describe the bug/feature in the PR.
2. Create a focused branch.
3. Keep changes scoped and avoid unrelated UI changes.
4. Add or update tests for behavior changes, especially encryption, persistence, AI safety, and migrations.
5. Run from `pillow_bud/`:

   ```bash
   flutter pub get
   dart format lib test
   flutter analyze
   flutter test
   ```

6. State which commands actually ran and include their results. Do not report checks as passing if they were not executed.

## Engineering guidelines

- Follow Dart style and Flutter conventions.
- Prefer small, testable services and explicit error handling.
- Never log private user content, keys, tokens, or backup contents.
- Never add secrets, signing keys, keystores, personal data, or generated build artifacts.
- Do not introduce cloud processing for private conversations without explicit product approval and clear disclosure.
- Changes to encryption or database schema require compatibility and migration tests.
- Treat crisis handling as a safety-critical path; avoid presenting the app as a therapist or emergency service.

## Pull requests

Explain the motivation, implementation, tests, migration impact, and known limitations. Keep documentation aligned with actual code.
