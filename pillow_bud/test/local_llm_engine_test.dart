import 'package:flutter_test/flutter_test.dart';
import 'package:pillow_bud/services/ai/local_llm_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalLLMEngine fallback behavior', () {
    test('dummy engine returns an empty response without a native model', () async {
      final engine = LocalLLMEngine.dummy();
      expect(await engine.generate('hello'), isEmpty);
      await engine.dispose();
    });

    test('dummy engine stream completes without emitting tokens', () async {
      final engine = LocalLLMEngine.dummy();
      expect(await engine.generateStream('hello').toList(), isEmpty);
      await engine.dispose();
    });
  });
}
