# Agent 2 — State Management & Persistence TODO (Riverpod + Isar) TODO (Pillow Bud)

Source: `guidance/COMPLETE_ULTRA_DETAILED_MASTER_PROMPT.md`

## A. Single source of truth
- [ ] Ensure Riverpod state is the source of truth for:
  - user data (name, personality, onboarding completion)
  - chat messages + chat sessions
  - journal entries
  - computed UI state (selected mood, current emotion, intensity)
- [ ] Remove local in-memory lists from screens where they conflict:
  - `ChatScreen`: eliminate `_ChatScreenState.messages` or ensure it mirrors provider state.
  - `JournalScreen`: eliminate local `entries` list or ensure it mirrors provider state.

## B. Isar persistence (required by spec)
- [ ] Implement Isar schema/collections matching spec:
  - `ChatSessionIsar`
  - `ChatMessageIsar`
  - `JournalEntryIsar`
  - `MoodLogIsar` (if mood history used)
  - `UserPreferencesIsar`
- [ ] Implement repository/services under `lib/services/`:
  - load/save CRUD for chat sessions/messages
  - load/save CRUD for journal entries
  - load preferences on app start
- [ ] Add Riverpod providers to load initial data asynchronously and expose state updates.

## C. Wire onboarding + preferences
- [ ] Ensure onboarding completion writes to the canonical store (Isar and/or SharedPreferences).
- [ ] Ensure app launch reads onboarding completion and routes to Home vs Onboarding.
- [ ] Ensure personality mode changes in settings (where implemented) persist immediately.

## D. Ensure LLMService continuity
- [ ] Provide chat history to `LLMService` from persisted chat session/messages (not memory-only).
- [ ] Save Bud responses and emotions/metadata to Isar after generation.

## E. Error handling
- [ ] Add graceful handling for:
  - database not initialized
  - empty state loads
  - migration or schema mismatch (basic approach)

## F. Output / deliverables
- [ ] Updated/added providers under `lib/providers/`.
- [ ] Updated/added Isar services under `lib/services/`.
- [ ] Updated screens to read/write through providers.
- [ ] Run: `flutter analyze`, `flutter test`, then `flutter run`.

