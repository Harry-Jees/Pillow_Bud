# MASTER UPDATES — Pillow Bud Improvement Roadmap

> Planning document for the `MASTER-UPDATES` branch. This is a proposal and verification plan, not a claim that the listed work has been implemented or that the app is bug-free.
>
> **Baseline:** `main` at the time this branch was created. Keep `main` stable; implement and validate work in small, reviewable changes on this branch.

## Product direction

Pillow Bud should be a calm, trustworthy, local-first emotional companion. The product should combine supportive conversation, journaling, mood reflection, breathing/meditation, and user-controlled privacy without presenting itself as a therapist, diagnosing conditions, or promising emergency intervention.

### Principles

1. **Safety before novelty:** prevent data loss, avoid misleading crisis claims, and make failures recoverable.
2. **Privacy that can be explained:** clearly distinguish on-device processing, internet-required model downloads, OS-secure key storage, and backup-file protection.
3. **Low-friction care:** common actions should be obvious, quick, accessible, and non-judgmental.
4. **Honest offline behavior:** explain which features work offline, when the model is required, and what requires permissions or network access.
5. **Incremental delivery:** tests and a reviewed pull request for each coherent phase; no unrelated UI redesign bundled with security migrations.

## Current architecture baseline

The repository currently contains a Flutter app under `pillow_bud/`, with Riverpod state, Material UI, SQLite persistence, OS secure storage, record encryption, local notifications, speech input, and a local `llama_cpp` inference path using a downloaded Qwen3 4B GGUF model. Bundled visual assets include `assets/images/`, `assets/images/app_icon.png`, and the Lora / DM Sans font families.

Known verification limitations and follow-ups from source review:
- Flutter formatting, static analysis, automated tests, and per-platform native builds have not yet been confirmed passing.
- A file-size threshold does not prove that a model is authentic or valid GGUF; add trusted integrity verification.
- Legacy IV-only encrypted records are unauthenticated and need a safe migration plan.
- Backup export is Base64-encoded, not file-encrypted, and current import is installation-key-bound.
- Backup import can skip individual rows; partial restoration must be reported clearly and safely.
- Model download, cancellation/resume, memory pressure, inference failures, and platform support need integration/device testing.
- Crisis phrase matching is heuristic and must not be treated as a complete safety system.
- Chat, journal, preferences, and mood data persistence paths should be audited for consistency and duplicate sources of truth.

These are review findings and test gaps, not proof that every path currently fails.

---

# Workstream A — UI/UX and visual system

## A1. Audit before changing visuals

- [ ] Capture the current onboarding, home, chat, journal, insights, breathing, meditation, profile/settings, biometric lock, model-download and backup flows.
- [ ] Inventory all files under `pillow_bud/assets/images/` and map each asset to its intended use; reuse repository-owned artwork and avoid unrelated remote imagery.
- [ ] Check bundled Lora and DM Sans fonts are used consistently and all declared asset paths resolve.
- [ ] Record current navigation, loading/empty/error states, overflow, tap targets, text scaling, contrast, and dark/light theme behavior.
- [ ] Preserve recognizable existing branding unless an explicit redesign is approved.

## A2. Design system

- [ ] Define shared semantic color tokens for surfaces, text, accent, borders, success, warning and danger; ensure danger/safety messages never rely on color alone.
- [ ] Standardize typography: Lora for selected expressive headings; DM Sans for controls, body text, labels and data.
- [ ] Define spacing, corner radii, elevation, icon sizes, animation durations and touch-target minimums.
- [ ] Consolidate repeated buttons, cards, text fields, chips, dialogs, empty states and loading indicators into reusable widgets.
- [ ] Use the existing app icon and bundled imagery consistently. Replace the chat's emoji avatar with a branded asset only if the repository contains a suitable, legible asset; do not invent a new mascot treatment without reviewing the inventory.
- [ ] Use Material icons / Cupertino icons already supplied by Flutter dependencies where appropriate; avoid introducing a large icon pack for a handful of icons.
- [ ] Verify light and dark themes have deliberate semantic mappings rather than ad-hoc per-screen colors.

## A3. Navigation and onboarding

- [ ] Make the primary destinations and the active location clear, with consistent back behavior.
- [ ] Keep onboarding short and skippable where possible; explain local model size, storage needs, network use for download, and privacy in plain language.
- [ ] Ask for notification, microphone, and biometric permissions at the moment the feature is requested, not all at startup.
- [ ] Add a clear model readiness state: not downloaded, downloading, paused, failed, ready, and unavailable on this device.
- [ ] Provide recovery paths for skipped setup and denied permissions.

## A4. Chat experience

- [ ] Improve first-run empty state with a few gentle conversation starters that do not presume a diagnosis or emotional state.
- [ ] Distinguish sending, generating, stopped, failed and retryable messages.
- [ ] Prevent duplicate sends, preserve drafts on failure, and ensure the send button / keyboard submission behave consistently.
- [ ] Add cancel-generation behavior if the inference library can safely support it; do not simulate cancellation if native work continues.
- [ ] Make Start Fresh confirmation clear about what is cleared (active conversation context vs saved history) and ensure asynchronous history loads cannot restore stale messages.
- [ ] Ensure failed assistant responses are represented consistently in UI and persistence, without storing misleading fabricated responses.
- [ ] Improve long-message readability, markdown rendering, selectable text, copy action and screen-reader announcements.
- [ ] Keep typing/loading indicators subtle and respect reduced-motion preferences.

## A5. Journal, mood, insights

- [ ] Provide clear empty states and fast entry flows for journal and mood logs.
- [ ] Explain mood scales and emotion labels; never imply that heuristic estimates are clinical measurements.
- [ ] Show weekly/monthly trends only when enough data exists; explain what data the insight uses.
- [ ] Give users control over deletion, editing and retention of journal entries and mood logs.
- [ ] Use charts with text summaries and accessible labels so trends are not color-only.
- [ ] Avoid streaks, guilt-inducing copy, or engagement mechanics that punish missed days.

## A6. Breathing, meditation and voice

- [ ] Ensure breathing timers are pauseable, closable and usable without animation; provide a text or haptic alternative where supported.
- [ ] Prevent notification audio / voice input from unexpectedly continuing after leaving a screen.
- [ ] Make microphone listening state explicit, show partial transcript clearly, and provide a reliable stop/cancel path.
- [ ] Explain that speech recognition availability and processing behavior can depend on the OS/platform; do not promise offline speech recognition without platform testing.
- [ ] Provide safe defaults for notification reminders and clear controls to disable them.

## A7. Settings, privacy, model and backups

- [ ] Group settings by account/profile, appearance, reminders, privacy/security, AI model and data management.
- [ ] Show model version, download size, storage estimate, download progress, pause/resume/cancel, retry and delete actions.
- [ ] Show actionable errors without raw stack traces, native exceptions or sensitive content.
- [ ] Label backup export honestly: unencrypted archive vs encrypted portable backup, with a confirmation before sharing sensitive data.
- [ ] Show backup version, timestamp, validation result, counts and partial-import warnings before or after restore.
- [ ] Explain biometric lock behavior and session timeout; never imply biometrics encrypt the database unless they actually gate key access.
- [ ] Ensure destructive actions use specific confirmation copy and report the result.

## A8. Accessibility, motion and responsiveness

- [ ] Test TalkBack, keyboard-only navigation on desktop, focus order, semantics labels and logical reading order.
- [ ] Support system text scaling without clipped buttons, overflowing cards or hidden input controls.
- [ ] Check text/background contrast and status visibility in both themes.
- [ ] Respect reduced-motion / disabled-animation settings and keep transitions short and non-essential.
- [ ] Test narrow phones, large phones, tablets and desktop windows; use adaptive layouts rather than fixed-width assumptions.
- [ ] Ensure tap targets are comfortable and controls are not distinguished by color alone.

---

# Workstream B — Security, data integrity and privacy

## B1. Key storage and cryptography

- [ ] Audit key generation, encoding, key length, cache lifecycle and behavior on every supported platform.
- [ ] Confirm key storage failures stop sensitive writes safely and never fall back to a hardcoded key.
- [ ] Document the current authenticated-encryption format and ensure MAC verification happens before plaintext is accepted.
- [ ] Add tampering tests for ciphertext, IV, MAC, malformed Base64, empty values and wrong keys.
- [ ] Design a versioned migration for legacy unauthenticated records. Preserve originals until each record is decrypted, validated and re-encrypted successfully; report records that cannot be recovered.
- [ ] Verify database encryption-at-rest claims accurately. Record-level encryption is not equivalent to an encrypted SQLite database file.
- [ ] Audit logs for message contents, keys, prompts, journal data and personally sensitive data; do not log any of them.

## B2. Database and persistence

- [ ] Document the canonical source of truth for chat history, journal entries, mood logs and preferences.
- [ ] Audit duplicate SharedPreferences and SQLite storage paths; plan a tested consolidation rather than deleting a path blindly.
- [ ] Add schema migration tests from every supported prior schema.
- [ ] Test transactions, concurrent writes, app termination during writes, corrupted database recovery and duplicate imports.
- [ ] Add explicit retention/deletion semantics for conversations, journals, moods, cached model files and temporary exports.
- [ ] Ensure reset/delete operations cover persisted and in-memory state consistently.
- [ ] Test that migration failures are visible and do not silently replace user data with empty state.

## B3. Backup and restore

- [ ] Specify a versioned backup format with strict schema validation, size limits and safe handling of malformed input.
- [ ] Design portable, passphrase-protected backup encryption using a vetted authenticated-encryption construction and a suitable password-based key derivation function.
- [ ] Keep a clearly labelled legacy import path for old formats; never pretend Base64 is encryption.
- [ ] Avoid tying future portable backups solely to the original installation's master key.
- [ ] Validate all rows and relationships before mutating the live database; prefer a transaction or staged restore with rollback.
- [ ] Report imported, skipped and failed record counts and reasons without exposing private record contents.
- [ ] Test wrong password, corrupted archive, oversized input, duplicate restore, older/newer versions, empty backup, interrupted restore and restore after reinstall/new device.
- [ ] Ensure temporary backup files are cleaned up when safe and explain the OS share-sheet copy behavior.

## B4. Privacy documentation and permissions

- [ ] Create a data-flow inventory: what stays on device, what reaches OS services, what network requests occur, and when model download contacts Hugging Face.
- [ ] Explain that inference is local only when the local model is installed and supported; do not imply every feature works offline.
- [ ] Audit Android, Apple and desktop permission declarations against actual usage.
- [ ] Review data deletion, diagnostic logs, crash reporting (if any), third-party package behavior and privacy policy claims.
- [ ] Keep security reporting instructions and supported-version policy current.

---

# Workstream C — AI quality, safety and reliability

## C1. Model download and verification

- [ ] Verify HTTP status handling for full responses and byte-range responses, including servers that ignore Range, redirect, return malformed Content-Range, or disconnect.
- [ ] Add a trusted expected SHA-256 checksum or another verified publisher integrity mechanism for the exact model artifact; do not invent a checksum.
- [ ] Validate GGUF metadata / file identity after download, not just the byte count.
- [ ] Ensure temporary partial downloads are not mistaken for usable model files.
- [ ] Handle insufficient disk space, permission errors, app suspension, network loss, cancellation and concurrent download attempts.
- [ ] Ensure pause/resume and cancel state transitions remain correct when requests complete or fail concurrently.
- [ ] Show clear disk and memory requirements before download and make the model location recoverable.
- [ ] Verify license, redistribution terms and attribution for the exact model artifact before bundling or redistributing it.

## C2. Local inference lifecycle

- [ ] Test model loading, failed initialization, repeated initialization, dispose/reload, concurrent calls and app background/foreground transitions.
- [ ] Check memory pressure, low-RAM devices, long prompts, empty model output, malformed output and native exceptions.
- [ ] Ensure inference errors are not silently converted to empty assistant messages.
- [ ] Define safe timeouts and retry behavior where the native API supports them; avoid retries that multiply memory use.
- [ ] Measure cold-start latency, tokens per second, peak RAM, battery impact and storage use on representative devices.
- [ ] Evaluate whether model context size, thread count and generation parameters should vary by device capability.
- [ ] Keep model configuration and UI claims synchronized with the model actually downloaded.

## C3. Conversation quality and memory

- [ ] Add golden tests for prompt composition, personality modes, conversation-history trimming and invalid history records.
- [ ] Test prompt-injection attempts in user journal/context content and prevent stored content from overriding system safety rules.
- [ ] Keep remembered context bounded, transparent and user-editable.
- [ ] Make clear which memories are temporary conversation context and which are persisted.
- [ ] Evaluate responses for warmth, relevance, overlong replies, repetitive phrases, hallucinated certainty and inappropriate advice.
- [ ] Test multilingual inputs and common misspellings for the intended user population.
- [ ] Do not present emotion detection as objective truth; phrase it as a tentative signal and let the user correct it.

## C4. Crisis and wellbeing safety

- [ ] Threat-model crisis detection, false negatives, false positives, indirect statements, slang, spelling variants and multilingual expressions.
- [ ] Build a reviewed test suite and have qualified reviewers assess crisis handling.
- [ ] Provide region-appropriate support resources with a maintenance/update process; do not hardcode unverified or stale contacts.
- [ ] Make clear that Pillow Bud is not a therapist, diagnosis tool or emergency service.
- [ ] Ensure a crisis response does not depend exclusively on the model's generated text or a simple keyword list.
- [ ] Avoid storing sensitive crisis content longer than necessary and never use it for analytics without explicit informed consent.

---

# Workstream D — Engineering quality and maintainability

## D1. Baseline validation

- [ ] From `pillow_bud/`, run `flutter pub get`, `dart format --set-exit-if-changed lib test`, `flutter analyze` and `flutter test`.
- [ ] Fix all analyzer errors and test failures; review warnings instead of blindly suppressing them.
- [ ] Check imports, dead code, duplicate helpers, unused dependencies and inconsistent naming.
- [ ] Verify dependency constraints and native plugin compatibility against the actual Flutter/Dart toolchain.
- [ ] Keep lockfiles committed and update dependencies in small, reviewed batches.

## D2. Test architecture

- [ ] Unit tests: encryption, migrations, backup parser, model download range parser, prompt builder, history reducer, crisis matching and state transitions.
- [ ] Integration tests: database lifecycle, encrypted persistence, import/export, model download with mocked HTTP, and app restart recovery.
- [ ] Widget tests: onboarding, chat loading/error/empty states, journal entry, settings, permission denial and destructive confirmations.
- [ ] Add deterministic test seams for HTTP, filesystem, secure storage, database and native inference instead of relying on live services in unit tests.
- [ ] Add regression tests for each fixed bug before merging the corresponding fix.
- [ ] Ensure tests use fake keys and fixtures only; never commit real user data or production secrets.

## D3. Architecture and state

- [ ] Keep UI widgets thin and move business rules into testable services/controllers.
- [ ] Establish clear ownership and disposal of Riverpod state, notifiers, streams, controllers and native model resources.
- [ ] Avoid repeated singleton initialization and make concurrent model loading safe.
- [ ] Use typed results/errors for recoverable operations; keep low-level exceptions inside the service boundary.
- [ ] Ensure async callbacks check widget lifecycle before updating UI.
- [ ] Separate platform-specific code behind explicit interfaces and report unsupported-platform behavior honestly.

## D4. CI and release readiness

- [ ] Add or verify CI for formatting, analysis and tests on pull requests; do not automatically rerun workflows merely to check status.
- [ ] Build each claimed platform in a compatible CI environment and maintain a release support matrix.
- [ ] Verify release signing and secrets handling; never commit keystores, passwords, API keys or generated private files.
- [ ] Add dependency and secret scanning where practical.
- [ ] Provide reproducible release steps, versioning, changelog, rollback guidance and artifact checksums.
- [ ] Smoke-test install, launch, first-run, chat, persistence, model download, backup and upgrade on release candidates.

---

# Workstream E — Performance and product differentiation

- [ ] Profile startup and first-screen rendering before optimizing.
- [ ] Measure database query performance and avoid unnecessary full-history loads.
- [ ] Paginate long chat history and avoid building oversized lists eagerly.
- [ ] Avoid expensive rebuilds and animations during token generation.
- [ ] Use caching only with clear invalidation and privacy implications.
- [ ] Track opt-in, privacy-preserving local performance diagnostics; do not upload journal or conversation content.
- [ ] Offer small/large model choices only after benchmarking actual supported model variants.
- [ ] Add a weekly reflection summary only when data is sufficient and explain which entries inform it.
- [ ] Offer gentle, optional wellbeing routines without streak pressure or gamification that creates guilt.
- [ ] Make user-controlled memory, portable encrypted backup and honest offline status core differentiators.

## Competitive benchmark checklist

Compare features by verified behavior, not marketing claims. Review current versions of:
- **Wysa:** guided self-care and structured wellbeing exercises.
- **Finch:** low-friction routines, gentle progression and a companion identity.
- **Daylio:** fast mood tracking, trends and export/recovery expectations.
- **Local AI companion tools:** offline capability, model selection, resource use and data control.

For each comparison, record: platform availability, offline boundaries, privacy/data handling, backup portability, accessibility, safety disclaimers, onboarding friction, model performance and subscription/monetization. Re-check official product documentation before publishing comparisons; avoid claiming clinical efficacy without evidence.

---

# Delivery sequence and acceptance gates

## Phase 0 — Establish the truth (P0)

- [ ] Inventory repository assets, platform targets, dependencies and current screens.
- [ ] Run the baseline Flutter commands and record the exact toolchain and results.
- [ ] Create reproducible tests for current behavior before changing core flows.
- [ ] Produce a defect list with severity, reproduction steps, expected behavior and owner.
- **Exit gate:** baseline status is documented; no assumption that untested code is healthy.

## Phase 1 — Prevent data loss and security regressions (P0)

- [ ] Add model identity/integrity verification.
- [ ] Specify and test safe legacy-record migration.
- [ ] Harden backup validation and make partial restores explicit.
- [ ] Add database, secure-storage, cancellation and recovery tests.
- **Exit gate:** destructive/migration flows have regression tests and recoverable failure behavior.

## Phase 2 — Stabilize AI runtime and safety (P0/P1)

- [ ] Test model loading/download lifecycle and resource limits.
- [ ] Add inference lifecycle tests and reliable retry/error states.
- [ ] Review crisis flow with qualified input and maintainable resources.
- **Exit gate:** supported-device test matrix is documented; no untested claims of universal offline support.

## Phase 3 — UI foundations and accessibility (P1)

- [ ] Complete screen and asset audit.
- [ ] Standardize tokens, typography, reusable widgets, responsive layout and accessibility.
- [ ] Fix loading, empty, permission-denied and error states across screens.
- **Exit gate:** core screens pass visual, accessibility and responsive smoke tests without regressions.

## Phase 4 — Core experience improvements (P1)

- [ ] Refine onboarding, chat, journal, mood, breathing, meditation and settings flows.
- [ ] Improve drafts, retry/cancel semantics, history behavior and model readiness UX.
- [ ] Make privacy, backup and deletion flows understandable.
- **Exit gate:** user journeys work from fresh install through restore and recovery.

## Phase 5 — Differentiation and performance (P2)

- [ ] Add transparent user-controlled memory management.
- [ ] Add interpretable mood trends and optional guided routines.
- [ ] Benchmark model choices, startup, memory and battery on representative devices.
- **Exit gate:** features are measured, optional, accessible and do not weaken privacy or safety.

## Phase 6 — Release hardening (P0 release gate)

- [ ] Formatting, analyzer and all automated tests pass.
- [ ] Supported native builds and smoke tests pass.
- [ ] Privacy/security docs match actual behavior.
- [ ] Accessibility and performance regressions are reviewed.
- [ ] Release artifacts, signing, checksums and rollback instructions are verified.
- **Exit gate:** publish a release readiness report with evidence and remaining known limitations.

## Definition of done for each task

- A clear problem statement and acceptance criteria.
- A regression test or documented reason a test cannot be automated.
- No secrets or real personal data in source, fixtures, logs or screenshots.
- Formatting, analysis and relevant tests pass.
- UI changes use existing brand assets and shared tokens where appropriate.
- Privacy, accessibility, failure and recovery behavior are reviewed.
- Documentation is updated to reflect the shipped implementation.
- Changes are committed to `MASTER-UPDATES` and merged through a reviewed PR only after validation.

## Guardrails

- Do not label the app bug-free until test and platform evidence supports the claim.
- Do not replace existing brand assets or redesign the entire UI without inspecting the actual asset inventory and current screens first.
- Do not remove legacy data paths until migration and rollback behavior are tested.
- Do not run unnecessary workflow reruns. Prefer reading existing statuses and running checks locally or through a deliberate CI change.
- Do not merge unfinished work into `main` merely to keep momentum.


---

## Build progress — 2026-10-21

Implementation has started on `MASTER-UPDATES`. This section records completed code changes separately from the larger roadmap.

### Completed in the first implementation pass

- [x] Model acceptance now checks the four-byte `GGUF` container signature as well as the existing minimum-size check.
- [x] Startup validation rejects and removes a final-path file that is truncated or does not have the GGUF signature.
- [x] Completed downloads are checked for the GGUF signature before being promoted to the final model path. Invalid completed payloads are removed so a retry does not resume from bad bytes.
- [x] Added unit tests for valid GGUF magic, short files, and unrelated/HTML-like payloads.
- [x] Backup restore now counts skipped chat, journal, and mood records; the UI tells the user when restoration was partial instead of reporting only successful rows.

### Still outstanding / not claimed complete

- [ ] Run `dart format`, `flutter analyze`, and `flutter test` in a Flutter-enabled environment.
- [ ] Add full model identity/checksum verification; GGUF magic is a container check, not proof that the file is the expected Qwen model.
- [ ] Make backup imports transactional or otherwise guarantee a clearly defined partial-failure/recovery contract.
- [ ] Audit and migrate unauthenticated legacy encrypted records without risking existing user data.
- [ ] Complete screen/asset inventory before broad UI redesign.
- [ ] Test native builds and download edge cases on supported platforms.

No workflow reruns were triggered for this implementation pass. Code has been committed to this branch only; `main` remains unchanged until validation and review.


### Build progress — Phase 2 follow-up

- [x] Preflight-validates all backup table fields and record shapes before inserting any rows, so malformed archive structure is rejected before a restore begins.
- [x] Added regression tests for malformed table payloads and malformed record entries.
- [ ] Run the new tests and existing suite in a Flutter-enabled environment; remote edits alone do not prove compilation or test success.
- [ ] Transactional restore and full rollback semantics remain future work; per-row database conflicts can still produce a reported partial restore.


### Phase 2 follow-up — legacy encrypted-field migration

- Added migration-on-read for legacy chat and journal ciphertext that uses IV-only metadata: records are decrypted with the existing compatibility path, then rewritten with the authenticated IV-plus-HMAC format.
- Legacy plaintext mood metadata in chat, journal, and mood-log rows is encrypted when read and saved back to SQLite. Legacy mood-log notes are also upgraded from IV-only to authenticated records.
- Authenticated records continue to be verified by the encryption service before being returned. Records missing required IV metadata fail closed instead of being guessed as plaintext, except the explicitly identified legacy mood-label columns.
- Added encryption regression coverage for IV-only legacy compatibility and authentication-tag tampering.
- Remaining verification: run dart format, flutter analyze, and flutter test in a Flutter-enabled environment; review migration behavior against representative v1/v2 database fixtures before release.


### Phase 2 follow-up — atomic backup restoration

- Replaced per-row best-effort backup writes with a single SQLite transaction spanning chat messages, journal entries, and mood logs. Any schema/constraint failure now rolls back the entire import rather than leaving a partial restore.
- Restore now fails explicitly when the database has not been initialized; it can no longer silently report success after no-op writes.
- Added a regression test for unavailable-database restore and exposed the metadata-encryption helper used by legacy backup export.
- Updated restore feedback to report the committed record counts; failures are surfaced through the existing error snackbar.
- Verification is still pending in a Flutter-enabled environment. Do not treat source-level changes as a passing test/analyzer result.


### Phase 3 — local inference reliability

- Added single-flight model initialization so concurrent requests share one in-progress native model load instead of risking duplicate model contexts and avoidable memory pressure.
- Serialized generation and streaming requests through one per-engine queue to prevent overlapping use of a llama.cpp context; disposal now waits for in-flight generation to finish.
- Revalidates model size and GGUF container signature at the inference boundary, not only in the download UI, and reports invalid models through the existing recoverable error path.
- Added lightweight tests for dummy-engine response and stream behavior.
- Remaining high-priority verification: run formatter/analyzer/test suite in a Flutter-enabled environment, then add native-backed concurrency tests on supported desktop/Android targets. These source changes are not yet runtime-verified.


### Phase 3 follow-up — chat request lifecycle

- Removed one-off chat generation from the non-auto-disposed `FutureProvider.family` cache. Repeating the same message now invokes the local model again instead of potentially reusing a stale cached response.
- Chat submission now locks before the first asynchronous persistence step, preventing rapid duplicate sends from overlapping and corrupting the global loading indicator.
- Added mounted checks around asynchronous generation results and reset loading state when the screen is disposed, avoiding updates to a closed screen.
- The chat screen restores recent persisted turns into the LLM service on history load; this behavior was verified during the source audit and retained.

- Follow-up audit: chat submission now waits for persisted-history loading before forming a prompt, locks repeated submissions synchronously, logs persistence failures, and saves the fallback response when generation fails. The service call bypasses cached `FutureProvider.family` results so identical user text is generated anew.

## Latest implementation log — 2026-10-21

- [x] Serialize model download starts through a shared in-flight future. Concurrent taps/screens now await the active transfer rather than opening competing writers against the same temporary download file and cancellation token.
- [x] Preserve the existing HTTP range validation, response-byte count checks, minimum-size check, and GGUF magic check before promoting a completed download.
- [ ] Add deterministic transfer tests using an injectable HTTP client or local test server; current tests cover path/state and GGUF signature checks but do not exercise concurrent/resumed transfers.
- [ ] Verify pause → settle → resume and cancel → immediate restart behavior on a real Flutter runtime. Flutter/Dart SDKs are unavailable in the current editing environment, so analyzer, formatter, and tests remain unverified.
