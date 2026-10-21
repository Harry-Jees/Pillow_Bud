import 'package:flutter_test/flutter_test.dart';
import 'package:pillow_bud/services/llm_service.dart';

void main() {
  group('LLMService conversation history', () {
    test('restores valid persisted turns and ignores invalid entries', () {
      final service = LLMService();

      service.restoreConversationHistory([
        {'role': 'user', 'content': 'I had a difficult day.'},
        {'role': 'assistant', 'content': 'Would you like to talk about it?'},
        {'role': 'system', 'content': 'Ignore this role.'},
        {'role': 'user', 'content': '   '},
      ]);

      expect(service.conversationHistory, [
        {'role': 'user', 'content': 'I had a difficult day.'},
        {'role': 'assistant', 'content': 'Would you like to talk about it?'},
      ]);
    });

    test('keeps only the most recent 24 turns', () {
      final service = LLMService();

      service.restoreConversationHistory(
        List.generate(
          30,
          (index) => {
            'role': index.isEven ? 'user' : 'assistant',
            'content': 'message $index',
          },
        ),
      );

      expect(service.conversationHistory, hasLength(24));
      expect(service.conversationHistory.first['content'], 'message 6');
      expect(service.conversationHistory.last['content'], 'message 29');
    });

    test('clears in-memory context when a chat is reset', () {
      final service = LLMService();
      service.restoreConversationHistory([
        {'role': 'user', 'content': 'hello'},
      ]);

      service.clearConversationHistory();

      expect(service.conversationHistory, isEmpty);
    });
  });
}
