# 🛏️ Pillow Bud - Production Ready Master TODO

## 🟢 Phase 1: Core Design System & Branding
- [ ] Verify Typography: Headlines (Lora), Body (DM Sans).
- [ ] Apply Palette: Primary (#C4A8F8), Dark BG (#1A1225), Card (#2D1F4A).
- [ ] Refactor Colors: Replace all `withValues` with `withOpacity` for compatibility.
- [ ] Splash Screen: 2s duration, fade-in animation, 80x80 logo container.

## 🟣 Phase 2: Emotional Intelligence (Bud's Brain)
- [ ] **EmotionDetector**: Support all 10 emotions (Overwhelmed to Uncertain).
- [ ] **Intensity Logic**: Implement 0.0-1.0 clamping based on intensity markers.
- [ ] **SystemPromptGenerator**: Logic for 4 personality modes (Gentle, Curious, Wise, Balanced).
- [ ] **Crisis Detection**: Implementation of 15+ trigger phrases and helpline popups.

## 🔵 Phase 3: Screen Parity (UI Specs)
- [ ] Onboarding: 5-page sequential PageView (swipe disabled).
- [ ] Home: Mood picker + Bud preview card.
- [ ] Chat: Asymmetric bubbles + header emotion subtitle.
- [ ] Journal: Entry cards with date labels (Today/Yesterday).
- [ ] Insights: Actual local data visualization for streaks and patterns.
- [ ] Profile: Crisis resources with phone dialer integration.

## 🟡 Phase 4: State & Data (Riverpod + Isar)
- [ ] Isar Schema: Collections for ChatSession, ChatMessage, JournalEntry, UserPreference.
- [ ] Repository Layer: CRUD services for messages and journal entries.
- [ ] Onboarding Guard: Persistence logic to skip onboarding once completed.
- [ ] Mock to Real LLM: Bridge logic for Phase 2 Llama integration.

## 🔴 Phase 5: Production & QA
- [ ] Accessibility Audit: 48dp touch targets, WCAG AA contrast.
- [ ] Offline Verification: Ensure app functionality with zero internet.
- [ ] Build Config: Android minSDK 26, targetSDK 34; iOS 15.0+.
- [ ] Asset Audit: Register all Lora and DM Sans variants in `pubspec.yaml`.

## ✅ Completed Tasks
- [x] File structure consolidation.
- [x] Dependency alignment in pubspec.yaml.
- [x] Master prompt requirements analysis.
