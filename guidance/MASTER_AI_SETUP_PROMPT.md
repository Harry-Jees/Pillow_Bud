# PILLOW BUD — COMPLETE MASTER SETUP PROMPT FOR AI ASSISTANCE

**Use this prompt in:**
- VS Code with Copilot/Chat
- Claude (create new chat)
- Any AI coding assistant

Copy everything below and paste into your AI assistant.

---

## MASTER INSTRUCTION BLOCK

I need you to help me set up a complete Flutter mobile app called "Pillow Bud" with the following requirements:

### PROJECT OVERVIEW
- **Name:** Pillow Bud
- **Type:** Flutter mobile app (iOS + Android)
- **Purpose:** Emotionally intelligent AI companion app
- **AI Model:** Llama 3.2 1B (local, no cloud)
- **Database:** Local only (Isar)
- **Platforms:** Android 8.0+, iOS 15+

### CORE REQUIREMENTS

1. **Emotionally Intelligent AI System**
   - Detect user's emotional state from messages
   - Adapt responses based on emotion and intensity
   - 4 personality modes: gentle, curious, wise, balanced
   - State-specific response generation

2. **Full App Functionality**
   - Onboarding (5 screens)
   - Chat with emotional AI
   - Journal with mood tracking
   - Insights/analytics
   - Settings/profile
   - Crisis detection with helpline resources

3. **Configuration & Icons**
   - Proper Android configuration (build.gradle, AndroidManifest.xml, styles.xml)
   - iOS configuration (Info.plist)
   - App icon setup for both platforms
   - app launches from home screen icon

4. **State Management & Architecture**
   - Riverpod for state management
   - Proper separation of concerns
   - Services layer (LLM, emotion detection, crisis detection)
   - Providers for reactive updates

### FILES TO CREATE

**Core Files (App Logic):**
- lib/main.dart
- lib/config/constants.dart
- lib/config/ai_config.dart
- lib/theme/app_colors.dart
- lib/theme/app_theme.dart

**Models:**
- lib/models/chat_message.dart
- lib/models/journal_entry.dart
- lib/models/user_preference.dart

**Services (CRITICAL - AI Integration):**
- lib/services/emotion_detector.dart (detects 10+ emotions)
- lib/services/system_prompt_generator.dart (generates context-aware prompts)
- lib/services/llm_service.dart (main LLM integration)
- lib/services/crisis_detector.dart (safety)
- lib/services/storage_service.dart (local storage)
- lib/services/date_utils.dart (utilities)
- lib/services/personalization_service.dart (user customization)

**Providers (State Management):**
- lib/providers/app_state_provider.dart
- lib/providers/theme_provider.dart
- lib/providers/llm_provider.dart (emotion-aware response)

**Screens:**
- lib/screens/splash_screen.dart
- lib/screens/onboarding_screen.dart
- lib/screens/home_screen.dart
- lib/screens/chat_screen.dart (with emotion awareness)
- lib/screens/journal_screen.dart
- lib/screens/insights_screen.dart
- lib/screens/profile_screen.dart

**Widgets:**
- lib/widgets/buttons/primary_button.dart
- lib/widgets/buttons/secondary_button.dart
- lib/widgets/indicators/typing_indicator.dart

**Utilities:**
- lib/utils/extensions.dart
- pubspec.yaml
- .gitignore
- README.md
- LICENSE
- CONTRIBUTING.md

**Android Configuration:**
- android/app/build.gradle
- android/app/src/main/AndroidManifest.xml
- android/app/src/main/kotlin/com/pillow_bud/app/MainActivity.kt
- android/app/src/main/res/values/styles.xml
- android/app/src/main/res/values-night/styles.xml

**iOS Configuration:**
- ios/Runner/Info.plist

**Assets:**
- assets/fonts/ (Lora, DM Sans TTF files)
- assets/images/ (app icon PNG files)

### AI/EMOTION SYSTEM REQUIREMENTS

The AI system must:

1. **Emotion Detection**
   - Detect: overwhelmed, anxious, sad, lonely, stressed, confused, hopeful, calm, angry, uncertain
   - Calculate emotion intensity (0-1)
   - Use keyword matching and intensity markers

2. **System Prompt Generation**
   - Generate context-aware prompts based on:
     * User's detected emotion
     * Emotion intensity
     * Selected personality mode
     * Recent conversation history
   - Ensure empathy, safety, and authenticity

3. **Personality Modes**
   - **Gentle:** Validation-focused, minimal questions
   - **Curious:** Exploratory questions, help thinking
   - **Wise:** Reflective, perspective-giving
   - **Balanced:** Mix of all three (default)

4. **State-Specific Responses**
   - Each emotion type has specific guidance for Bud
   - Responses validated for emotional appropriateness
   - No toxic positivity, only authentic empathy

5. **Crisis Safety**
   - Detect 15+ crisis trigger phrases
   - Show helpline resources immediately
   - Compassionate, non-judgmental intervention

6. **Conversation Continuity**
   - Track conversation history (max 10 exchanges to save context)
   - Provide recent context to LLM
   - Avoid repetitive responses

### DESIGN SPECIFICATIONS

**Colors:**
- Primary (Lavender): #C4A8F8
- Secondary (Teal): #89C4F8
- Tertiary (Sage): #A8D8A8
- Dark BG: #1A1225
- Text (Dark mode): #F0E8FF

**Fonts:**
- Display: Lora (serif) - 28px, weight 600
- Body: DM Sans (sans) - 14px, weight 400
- Line height: 1.6 for body, 1.4 for headlines

**Styling:**
- Soft rounded corners (14-20px)
- No shadows (flat, modern)
- Asymmetric chat bubbles (4px sender side, 16px others)
- Smooth animations (200-300ms)
- Dark mode by default

### FUNCTIONALITY REQUIREMENTS

**Chat Screen:**
- Messages update in real-time
- Show "Bud is thinking..." with animated dots
- Crisis detection triggers helpline popup
- Emotion indicator in header
- Typing animation for responses

**Onboarding:**
- Page 1: Welcome
- Page 2: Enter name
- Page 3: Select personality
- Page 4: Disclaimer
- Page 5: Ready (shows emotion detector working)

**Home Screen:**
- Greeting with user name
- Mood picker (5 emojis)
- Bud preview card
- Quick access to chat

**Journal:**
- Create entries with mood emoji
- List all entries
- Today/Yesterday/Date labels

**Insights:**
- Weekly mood chart (bar graph)
- Streak counter
- Mood statistics

**Profile:**
- User info
- App info
- Crisis resources
- Settings

### TECHNICAL SPECIFICATIONS

**State Management:**
- Use Riverpod for all state
- Providers for: user data, chat, journal, mood, emotion, responses
- FutureProvider for async LLM responses

**Database:**
- Isar for local storage (encrypted by default)
- Collections: ChatSession, ChatMessage, JournalEntry, MoodLog
- No cloud, all local

**AI Integration:**
- flutter_gemma for model inference (when available)
- Mock responses for Phase 1
- Ready for Llama 3.2 1B
- Streaming token support
- System prompt customization

**App Configuration:**
- Android: minSdk 26, targetSdk 34
- iOS: iOS 15.0 minimum
- App icon in correct sizes
- Proper manifest configuration

### OUTPUT REQUIREMENTS

For each file, I need:
1. Complete, copy-paste ready code
2. All necessary imports
3. All dependencies declared in pubspec.yaml
4. Comments explaining critical sections
5. Error handling where needed
6. No placeholder code (everything functional)

### SPECIAL INSTRUCTIONS FOR AI SYSTEM

When generating code:

1. **Emotion Detection:** Use keyword-based + intensity marker approach. Be generous with detection to catch subtle emotions.

2. **System Prompts:** Generate specific, personalized prompts for each emotional state. Never generic.

3. **Mock Responses:** Create varied, contextual responses that feel like a real AI, not random.

4. **Error Handling:** Include try-catch blocks for all async operations.

5. **Comments:** Add brief comments explaining why, not what (code shows what).

6. **Type Safety:** Use strict typing, no dynamic types.

7. **Null Safety:** Use null-safe Dart (no null checks where not needed).

8. **Performance:** Consider memory usage for storing message history.

9. **Testing:** Code should work immediately without additional setup (except fonts).

10. **Documentation:** Include docstrings for all public methods.

---

## EXECUTION PLAN

Generate files in this order:

### Phase 1: Configuration
1. pubspec.yaml (with all dependencies)
2. lib/config/constants.dart
3. lib/config/ai_config.dart

### Phase 2: Theme & Styling
4. lib/theme/app_colors.dart
5. lib/theme/app_theme.dart

### Phase 3: Models
6. lib/models/chat_message.dart
7. lib/models/journal_entry.dart
8. lib/models/user_preference.dart

### Phase 4: Services (CRITICAL)
9. lib/services/emotion_detector.dart
10. lib/services/system_prompt_generator.dart
11. lib/services/llm_service.dart (integrates above)
12. lib/services/crisis_detector.dart
13. lib/services/storage_service.dart
14. lib/services/date_utils.dart
15. lib/services/personalization_service.dart

### Phase 5: State Management
16. lib/providers/app_state_provider.dart
17. lib/providers/theme_provider.dart
18. lib/providers/llm_provider.dart

### Phase 6: Screens
19. lib/screens/splash_screen.dart
20. lib/screens/onboarding_screen.dart
21. lib/screens/home_screen.dart
22. lib/screens/chat_screen.dart (uses emotion system)
23. lib/screens/journal_screen.dart
24. lib/screens/insights_screen.dart
25. lib/screens/profile_screen.dart

### Phase 7: Widgets
26. lib/widgets/buttons/primary_button.dart
27. lib/widgets/buttons/secondary_button.dart
28. lib/widgets/indicators/typing_indicator.dart

### Phase 8: Utilities & Main
29. lib/utils/extensions.dart
30. lib/main.dart

### Phase 9: Configuration Files
31. android/app/build.gradle
32. android/app/src/main/AndroidManifest.xml
33. android/app/src/main/kotlin/com/pillow_bud/app/MainActivity.kt
34. android/app/src/main/res/values/styles.xml
35. android/app/src/main/res/values-night/styles.xml
36. ios/Runner/Info.plist

### Phase 10: Supporting Files
37. .gitignore
38. README.md
39. LICENSE
40. CONTRIBUTING.md

---

## CRITICAL REQUIREMENTS

**DO NOT:**
- Use placeholder code
- Include TODOs in core functionality
- Skip error handling
- Use generic responses
- Forget imports
- Create unused files

**DO:**
- Make everything work immediately
- Include detailed emotion responses
- Add proper null safety
- Comment complex logic
- Test imports mentally
- Make code readable

**EMOTION SYSTEM MUST:**
- Detect emotions accurately
- Generate context-specific prompts
- Provide empathetic responses
- Include safety checks
- Track conversation history
- Support personality customization

---

## FILE-BY-FILE DELIVERY FORMAT

For each file, provide:

```
### FILE: path/to/file.dart

**Purpose:** What this file does

**Key Features:**
- Feature 1
- Feature 2
- Feature 3

**CODE:**
[Complete, ready-to-use code]

**Integration Notes:**
- How it connects to other files
- What it depends on
- What depends on it
```

---

## VALIDATION CHECKLIST

After generating all files, verify:

- [ ] All files present
- [ ] All imports correct
- [ ] pubspec.yaml complete
- [ ] No circular dependencies
- [ ] Emotion detection works
- [ ] System prompts generate
- [ ] Chat screen integrated
- [ ] Crisis detection active
- [ ] Android config complete
- [ ] iOS config complete
- [ ] App icon sizes defined
- [ ] Dark/light theme ready
- [ ] Riverpod providers setup
- [ ] All screens navigable
- [ ] Journal functional
- [ ] Insights screen works

---

## START GENERATION

You're ready. Begin with Phase 1 and proceed through all phases.

For each file, output the complete code that:
1. Works immediately
2. Integrates with other files
3. Includes all necessary imports
4. Has proper error handling
5. Is production-ready

Generate the complete Pillow Bud app with emotionally intelligent AI system.

---

**END OF MASTER INSTRUCTION BLOCK**

(Copy everything above and paste into your AI assistant's chat)
