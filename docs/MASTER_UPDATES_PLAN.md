# MASTER UPDATES — Pillow Bud status and roadmap

**Last reconciled:** 2026-10-21  
**Working branch:** `MASTER-UPDATES`

This file replaces the original proposal checklist with a status summary that reflects the current source tree. A checked implementation item means code is present; it does **not** mean the feature has passed runtime testing or is release-ready. The canonical ongoing backlog is [../TODO.md](../TODO.md), and the verification procedure is [TESTING.md](TESTING.md).

## Product direction

Pillow Bud is a calm, local-first emotional-wellness companion. It should help with supportive conversation, journaling, mood reflection, breathing, and grounding without claiming to diagnose conditions, replace professional care, or provide emergency intervention.

## Implemented in source — runtime verification pending

### UI and accessibility

- Material 3 theme and shared semantic colors/typography.
- Floating translucent mobile navigation, animated tab transitions, and desktop navigation rail.
- Splash logo reveal with settle animation and light haptic feedback where supported.
- Reduced-motion handling in key animation paths.
- Calm-moment sheet with breathing, grounding, and saved coping steps.

### AI and conversation state

- Local Qwen3 4B Instruct GGUF inference through `llama_cpp` on supported native targets.
- Emotion-aware system prompt with restrained, supportive response guidance and non-clinical boundaries.
- Context size limits, serialized native generation, recoverable model errors, and stale-response protection after chat reset/session changes.
- Conversation history and separate sessions backed by SQLite.
- Model download checks for file size, GGUF signature, and transfer byte/range behavior.

### Personal data and backups

- OS secure-storage master key; no hardcoded fallback.
- Authenticated encryption for newly written database records; legacy IV-only records remain readable for compatibility.
- Encrypted preference payloads for chat/journal data and coping plan.
- Optional mood check-in notes and mood insights from persisted records.
- PBv3 passphrase-protected portable backup envelope using PBKDF2-HMAC-SHA256, AES-CBC, and HMAC-SHA256 verification before decryption.
- PBv2 import compatibility for legacy same-installation backups.
- Backup structure validation and transactional row restore.

### Crisis support

- Phrase-boundary matching and normalization for punctuation/case.
- Basic tests for explicit and indirect crisis phrases, standalone denials, and selected ordinary-language false positives.
- India-focused resources including Tele-MANAS, Vandrevala Foundation, AASRA, and emergency number 112.

## Not yet verified

The editing environment does not have a usable Flutter/Dart toolchain or target devices. Therefore, the following are **not claimed as passing**:

- `dart format`, `flutter analyze`, and the full `flutter test` suite;
- actual model generation quality, memory use, streaming, and native plugin behavior;
- PBv3 round-trip, wrong-passphrase, tamper, truncation, and cross-install restore tests;
- UI rendering, haptics, reduced motion, accessibility, and persistence on real devices;
- Android, Windows, Linux, macOS, or iOS release builds and signing.

See [TESTING.md](TESTING.md) for the exact verification matrix.

## Highest-priority next steps

1. Run formatter, analyzer, and all tests with a compatible Flutter SDK.
2. Add and run complete PBv3 tests: export/import round-trip, wrong passphrase, altered MAC/ciphertext, malformed/truncated archive, no partial restore, and clean-install portability.
3. Test crisis detection for false positives and false negatives; phrase detection must remain a limited safety layer, not a risk assessment.
4. Evaluate real local-model responses for practical questions, distress, grief, anxiety, ambiguity, repetition, and unsafe/adversarial prompts.
5. Test session switching during active streaming, clearing history, persisted context restore, and model download pause/resume/cancel races.
6. Smoke-test each claimed native target with the real platform toolchain and verify accessibility and reduced-motion behavior.
7. Consolidate duplicate chat/journal persistence paths and plan a safe migration for legacy unauthenticated records.
8. Reconcile the two main-only commits with this branch before proposing a merge. Do not force-reset or merge without review.

## Maintainer rule

Report implementation, automated verification, manual device verification, and release readiness as separate statuses. Never mark a check complete merely because a test file or target configuration exists. Do not manually rerun CI workflows solely to change a status badge.
