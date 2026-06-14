# Agent 4 — QA, Build/Deploy, and Spec Compliance TODO (Pillow Bud)

Source: `guidance/COMPLETE_ULTRA_DETAILED_MASTER_PROMPT.md`

## A. Compile correctness sweep
- [ ] Fix any build-breaking API mismatches discovered in repo:
  - `withValues(alpha: ...)` usage must compile (use `withOpacity` or implement extension once).
- [ ] Ensure all imports resolve.

## B. Run automated checks
- [ ] From `pillow_bud/`: run `flutter pub get`.
- [ ] Run `flutter analyze` until clean.
- [ ] Run `flutter test`.

## C. Tests to add (minimum viable)
- [ ] Unit tests:
  - `EmotionDetector`: emotion detection and intensity clamping
  - `CrisisDetector`: trigger detection for several phrases
- [ ] Widget tests:
  - Chat send button disabled when input empty
  - Typing indicator shown/hidden based on loading state
  - Journal empty state renders when no entries

## D. Spec compliance verification checklist
- [ ] Performance: app loads <2s (smoke test), chat mock responds quickly.
- [ ] Offline: after model download (or mock mode), no network calls.
- [ ] Privacy: no telemetry/analytics.
- [ ] Accessibility: touch targets >=48x48 dp, readable contrast.

## E. Fonts and assets
- [ ] Verify `pubspec.yaml` registers fonts in `assets/fonts/`.
- [ ] Ensure icons and launch images are correct for Android/iOS.

## F. Build for platform constraints
- [ ] Android:
  - min SDK 26, target SDK 34
  - correct package name
  - app icon in all mipmaps
- [ ] iOS:
  - iOS 15+ deployment target
  - bundle ID
  - AppIcon.appiconset has required sizes

## G. Output / deliverables
- [ ] Update CI-friendly scripts or documentation if present.
- [ ] Final pass: `flutter analyze`, `flutter test`, and at least `flutter run` on one emulator/device.
- [ ] Produce `SPEC_COMPLIANCE_REPORT.md` summarizing pass/fail for each master prompt verification item.

