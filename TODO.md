# Pillow Bud Guidance Implementation TODO

## 1. Guidance Intake

- [x] Read all files in `guidance/`
  - [x] `APP_CONFIGURATION_AND_ICON.md`
  - [x] `COMPLETE_AI_LLM_INTEGRATION.md`
  - [x] `FINAL_COMPLETE_SUMMARY.md`
  - [x] `MASTER_AI_SETUP_PROMPT.md`
  - [x] `QUICK_ACTION_CHECKLIST.md`
  - [x] `QUICK_REFERENCE_VISUAL_GUIDE.md`
  - [x] `WHAT_YOU_HAVE_AND_WHAT_TO_DO.md`
- [x] Extract actionable implementation work
  - [x] Platform app configuration
  - [x] App icon generation and placement
  - [x] Emotion-aware AI mock integration
  - [x] Personalization storage
  - [x] Dependency setup
  - [x] Verification commands

## 2. Flutter Project Foundation

- [x] Generate missing Flutter platform folders
  - [x] `android/`
  - [x] `ios/`
  - [x] `test/`
- [x] Preserve and format existing Pillow Bud app source
- [x] Refresh dependencies
  - [x] Add AI/download/markdown/UUID packages
  - [x] Resolve `background_downloader` to current working constraint `^9.5.4`
  - [x] Run `flutter pub get`

## 3. AI and Emotional Intelligence

- [x] Add AI model configuration
  - [x] `lib/config/ai_config.dart`
  - [x] Llama 3.2 1B metadata and generation settings
  - [x] Personality mode definitions
- [x] Add emotion detection
  - [x] `lib/services/emotion_detector.dart`
  - [x] Primary emotion detection
  - [x] Intensity scoring
  - [x] Emotion-specific response guidance
- [x] Add system prompt generation
  - [x] `lib/services/system_prompt_generator.dart`
  - [x] Base safety/personality prompt
  - [x] Emotion-aware prompt sections
  - [x] Crisis-aware boundaries
- [x] Replace LLM service with emotion-aware service
  - [x] `lib/services/llm_service.dart`
  - [x] Crisis detection path
  - [x] Mock emotional response generation
  - [x] Conversation history context
- [x] Replace LLM providers
  - [x] `lib/providers/llm_provider.dart`
  - [x] Emotion state providers
  - [x] Personality mode provider
- [x] Add personalization storage
  - [x] `lib/services/personalization_service.dart`
  - [x] Emotion frequency storage
  - [x] Preferred response style storage
  - [x] Response feedback storage
- [x] Update chat experience
  - [x] `lib/screens/chat_screen.dart`
  - [x] Emotion-aware Bud responses
  - [x] Crisis resource response handling
  - [x] Typing/loading state

## 4. App Identity and Platform Configuration

- [x] Configure Android
  - [x] Set namespace/application ID to `com.pillow_bud.app`
  - [x] Set label to `Pillow Bud`
  - [x] Add internet/network permissions
  - [x] Configure launcher and round icons
  - [x] Move `MainActivity` to `com/pillow_bud/app`
  - [x] Update dark launch theme styles
- [x] Configure iOS
  - [x] Set bundle display/name values to `Pillow Bud`
  - [x] Set bundle identifiers to `com.pillow_bud.app`
  - [x] Add privacy tracking keys from guidance

## 5. App Icons and Assets

- [x] Generate Pillow Bud launcher artwork
  - [x] 1024x1024 source at `assets/images/app_icon.png`
- [x] Generate Android launcher icons
  - [x] `mipmap-mdpi`
  - [x] `mipmap-hdpi`
  - [x] `mipmap-xhdpi`
  - [x] `mipmap-xxhdpi`
  - [x] `mipmap-xxxhdpi`
  - [x] Round icon variants
- [x] Generate iOS app icon set
  - [x] 20, 29, 40, 60, 76, 83.5, and 1024 point variants
- [x] Keep required font assets
  - [x] Lora
  - [x] DM Sans

## 6. Code Quality and Verification

- [x] Format Dart code
- [x] Run static analysis
  - [x] `flutter analyze`
  - [x] Result: no issues found
- [x] Run automated tests
  - [x] `flutter test`
  - [x] Result: all tests passed
- [ ] Android APK build
  - [x] Added Android platform files
  - [x] Found and configured local JDK at `D:\Java\jdk17`
  - [x] Moved Gradle cache to `D:\gradle-cache` because C: has 0 bytes free
  - [ ] Build still needs a successful local Gradle run; latest attempt timed out before producing an APK
- [ ] Device verification
  - [ ] `flutter run` on a connected phone
  - [ ] Confirm icon appears on home screen
  - [ ] Confirm tap launches app
  - [ ] Confirm onboarding, chat, journal, and navigation on device

## 7. Release and Sharing

- [ ] Create or connect GitHub repository
- [ ] Commit and push code
- [ ] Build release APK after Android build environment is stable
- [ ] Create `v1.0.0` GitHub release
- [ ] Attach APK to release if desired

## 8. Later AI Upgrade Path

- [ ] Replace mock AI response generation with real local Llama runtime
  - [ ] Evaluate current `flutter_gemma`
  - [ ] Decide model download/storage strategy
  - [ ] Add resumable model download UI
  - [ ] Add offline model availability checks
