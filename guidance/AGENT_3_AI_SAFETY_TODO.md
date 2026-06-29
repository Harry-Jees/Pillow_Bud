# Agent 3 — AI/ML, Safety, and Business Rules TODO (Pillow Bud)

Source: `guidance/COMPLETE_ULTRA_DETAILED_MASTER_PROMPT.md`

## A. Emotion detection correctness
- [x] Ensure all 10 emotions covered with keyword matching (case-insensitive).
- [x] Fix intensity marker detection to better match phrases:
  - handle punctuation and contractions (`can't`, `can't cope`)
  - normalize whitespace
  - consider regex boundaries
- [x] Ensure intensity output is clamped 0.0–1.0 and default neutral behavior matches spec.
- [ ] Add unit tests for:
  - each emotion keyword
  - a few intensity marker phrases

## B. Crisis safety behavior (required)
- [x] Ensure `CrisisDetector` has >=15 triggers and matches spec list.
- [ ] Implement crisis flow in Chat:
  - compassionate message
  - popup with at least 3 India resources (iCall, Vandrevala, AASRA)
  - add actions:
    - Close and continue chat
    - Call (phone dialer)
- [ ] Avoid false reassurance; do not minimize severe signals.

## C. LLMService alignment
- [ ] Replace mock in-memory `conversationHistory` with persisted chat session history (from Isar via providers/services).
- [x] Integrate emotion-specific guidance rules from master prompt:
  - ensure detected emotion + intensity used when generating prompt
  - ensure personality mode modifies tone
- [x] Enforce response quality constraints:
  - under 200 words
  - avoid diagnosis and therapy prescriptions
  - include question/space to continue

## D. System prompt generation
- [x] Verify `SystemPromptGenerator.generatePrompt` is consistent with master prompt (base template + personality modifications + emotion-specific guidance).
- [ ] Add tests for prompt content sections (no corporate language, not a therapist, etc.).

## E. Output / deliverables
- [x] Updated: `lib/services/emotion_detector.dart`, `lib/services/crisis_detector.dart`, `lib/services/llm_service.dart`, `lib/services/system_prompt_generator.dart`.
- [ ] Add tests under `pillow_bud/test/`.
- [ ] Ensure Chat behavior matches safety rules.
- [ ] Run `flutter test` + `flutter analyze`.

