# Agent 1 — UI/UX Implementation & Readability TODO (Pillow Bud)

Source: `guidance/COMPLETE_ULTRA_DETAILED_MASTER_PROMPT.md`

## A. Spec-aligned UI parity (highest priority)
- [ ] SplashScreen: ensure exact 2s auto-transition; verify logo box sizing (80x80), border radius 20px, fade-in ~0.5s.
- [ ] Onboarding (5 screens): verify sequential flow (swipe disabled), correct copy/typography, button sizes (300x50), disabled state rules.
- [ ] HomeScreen: greeting, mood picker row (5 buttons), Bud preview card, CTA button, and bottom navigation (5 tabs) match spec.
- [ ] ChatScreen: asymmetric bubbles, header emotion subtitle, typing indicator animation, input area styling, send button disabled state.
- [ ] JournalScreen: entry cards, empty state text, FAB position and look, new entry dialog layout (text area, mood row, cancel/save).
- [ ] InsightsScreen: implement actual streak + weekly chart from local data (no hardcoded placeholders).
- [ ] ProfileScreen: avatar gradient + first letter, member since text, crisis resource cards, about/settings/feedback buttons.

## B. Global readability fixes
- [ ] Remove/replace all `withValues(alpha: X)` usage in UI widgets.
  - Prefer: `color.withOpacity(X)` or `Colors.white.withOpacity(X)`.
  - If an extension is required, implement it once in `lib/utils/extensions.dart` and use consistently.
- [ ] Replace any raw `TextStyle(...)` duplicates with theme-driven styles in `lib/theme/app_theme.dart` where appropriate.
- [ ] Extract repeated UI (chat bubbles, emotion banner, message row) into reusable widgets under `lib/widgets/`.

## C. Chat typing indicator
- [ ] Use the existing `TypingIndicator` widget (`lib/widgets/indicators/typing_indicator.dart`) instead of the static “3 dots” placeholder.
- [ ] Ensure it appears only while Bud is generating.

## D. Output / deliverables
- [ ] Updated UI files:
  - `lib/screens/splash_screen.dart`
  - `lib/screens/onboarding_screen.dart`
  - `lib/screens/home_screen.dart`
  - `lib/screens/chat_screen.dart`
  - `lib/screens/journal_screen.dart`
  - `lib/screens/insights_screen.dart`
  - `lib/screens/profile_screen.dart`
- [ ] Updated widgets if needed:
  - `lib/widgets/indicators/typing_indicator.dart`
  - any new bubble widgets under `lib/widgets/`
- [ ] After completion, run `flutter test` + `flutter analyze` and ensure UI compiles.

