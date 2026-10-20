import 'package:flutter_test/flutter_test.dart';
import 'package:pillow_bud/services/ai/model_download_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ModelDownloadService Tests', () {
    test('Model storage path resolves to GGUF format filename', () async {
      final path = await ModelDownloadService.getModelPath();
      expect(path.endsWith('.gguf'), isTrue);
    });

    test('Initial download status is notDownloaded or valid state', () {
      expect(ModelDownloadService.statusNotifier.value, isA<ModelDownloadStatus>());
      expect(ModelDownloadService.progressNotifier.value, inInclusiveRange(0.0, 1.0));
    });

    test('Cancel download resets progress safely', () async {
      await ModelDownloadService.cancelDownload();
      expect(ModelDownloadService.statusNotifier.value, equals(ModelDownloadStatus.notDownloaded));
      expect(ModelDownloadService.progressNotifier.value, equals(0.0));
    });
  });
}
