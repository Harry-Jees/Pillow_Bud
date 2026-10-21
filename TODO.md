# Pillow Bud maintenance backlog

This checklist distinguishes implementation work from verification work. A feature is not considered release-ready merely because code or a test file exists.

## Security and data integrity

- [x] Remove the hardcoded master-key fallback; protected operations require OS secure storage.
- [x] Authenticate newly written database records with HMAC-SHA256.
- [x] Encrypt newly written mood labels and serialized preference payloads.
- [x] Fail visibly when database initialization fails.
- [x] Implement passphrase-protected portable PBv3 backup export/import with archive authentication and PBv2 compatibility.
- [ ] Run PBv3 round-trip, wrong-passphrase, tampering, truncated-file, and cross-install restore tests on the actual Flutter toolchain.
- [ ] Independently review the custom backup format and key derivation parameters.
- [ ] Consolidate duplicate chat/journal persistence into one authoritative repository layer.
- [ ] Plan and test migration of legacy unauthenticated IV-only records before removing compatibility reads.
- [ ] Test database schema upgrades from real prior-version databases.
- [ ] Review secure-key-store failure, app-lock lifecycle, and sensitive logging on real devices.

## AI quality and safety

- [x] Align prompt/model documentation with local Qwen3 GGUF inference.
- [x] Bound conversation context and guard against stale history after reset/session switching.
- [x] Add phrase-boundary checks and basic crisis-detector regression tests.
- [ ] Run crisis detector tests and review false-positive/false-negative coverage.
- [ ] Evaluate real model responses across distress, grief, anxiety, practical questions, ambiguity, and adversarial prompts.
- [ ] Test model download resume, interrupted downloads, storage exhaustion, low-memory failures, and user-facing errors on device.
- [ ] Make clear in product copy that keyword detection and AI responses are not clinical or emergency services.

## UI, accessibility, and platforms

- [x] Add liquid-glass-style floating mobile navigation and splash logo reveal with haptic feedback where supported.
- [x] Add reduced-motion handling to key animations.
- [ ] Manually verify layout, touch targets, semantics, keyboard use, text scaling, contrast, and reduced-motion behavior.
- [ ] Verify chat streaming, session switching, history restore, and clear-chat behavior on device.
- [ ] Build and smoke-test Android and each claimed desktop target using the actual platform toolchain.
- [ ] Verify iOS/macOS plugin support and signing on Apple toolchains before claiming release readiness.
- [ ] Verify release signing configuration without committing secrets.

## Quality and maintenance

- [ ] Run `flutter pub get`, `dart format`, `flutter analyze`, and `flutter test` from `pillow_bud/`.
- [ ] Add coverage for model-download failure paths, database migration, mood/coping-plan persistence, and backup round trips.
- [ ] Track the lockfile for reproducible app builds where appropriate.
- [ ] Review documentation whenever implementation, supported platforms, model files, or data formats change.
- [ ] Record actual test/build outcomes; never mark checks complete without running them.
