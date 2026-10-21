# Maintenance execution plan

This plan tracks implementation separately from verification.

## Source work

- [x] Require OS secure storage for the record-encryption master key; no embedded fallback.
- [x] Authenticate new sensitive database records with HMAC-SHA256 while retaining legacy compatibility reads.
- [x] Make database initialization failures visible.
- [x] Align model configuration and documentation with local Qwen3 GGUF inference.
- [x] Add chat session isolation, coping-plan storage, mood notes, and crisis-detection regression coverage.
- [x] Implement passphrase-protected portable PBv3 backups with archive authentication and transactional restore.
- [x] Update root/app README, architecture, testing, security, contribution, community, and maintenance documents.

## Verification still required

- [ ] Run formatter, `flutter analyze`, and all tests with a compatible Flutter SDK.
- [ ] Run PBv3 round-trip, wrong-passphrase, tampering, malformed/truncated file, and clean-install restore tests.
- [ ] Run database migration and legacy PBv2 compatibility tests.
- [ ] Evaluate local model quality, streaming, memory behavior, and model-download failure paths on real devices.
- [ ] Verify UI, accessibility, reduced motion, haptics, and persistence on representative devices.
- [ ] Build and smoke-test each claimed native target with its actual platform toolchain.
- [ ] Independently review the custom backup cryptography and plan migration away from unauthenticated legacy records.
- [ ] Consolidate duplicate chat/journal persistence paths.

## Current status

The source and documentation have been reviewed through GitHub file inspection and targeted edits, but the Flutter/Dart toolchain is unavailable in the current editing environment. No analyzer, test suite, or native build is claimed to have passed. See [docs/TESTING.md](docs/TESTING.md) for the required verification matrix. Do not merge until results are recorded and the main-only commits have been reconciled.
