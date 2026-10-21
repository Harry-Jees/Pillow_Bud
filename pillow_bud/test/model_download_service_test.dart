import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pillow_bud/services/ai/model_download_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ModelDownloadService Tests', () {
    test('Model storage path resolves to GGUF format filename', () async {
      final path = await ModelDownloadService.getModelPath();
      expect(path.endsWith('.gguf'), isTrue);
    });

    test('A valid model must be at least 1 GiB', () {
      expect(
        ModelDownloadService.minimumValidModelBytes,
        greaterThanOrEqualTo(1024 * 1024 * 1024),
      );
      expect(
        ModelDownloadService.modelFileName.endsWith('.gguf'),
        isTrue,
      );
    });

    test('GGUF validation accepts the expected container signature', () async {
      final directory = await Directory.systemTemp.createTemp('pillow_bud_gguf_');
      try {
        final file = File('${directory.path}/valid.gguf');
        await file.writeAsBytes([0x47, 0x47, 0x55, 0x46, 0x00]);
        expect(await ModelDownloadService.hasGgufMagic(file), isTrue);
      } finally {
        await directory.delete(recursive: true);
      }
    });

    test('GGUF validation rejects short or unrelated files', () async {
      final directory = await Directory.systemTemp.createTemp('pillow_bud_gguf_');
      try {
        final shortFile = File('${directory.path}/short.gguf');
        await shortFile.writeAsBytes([0x47, 0x47, 0x55]);
        final unrelatedFile = File('${directory.path}/html.gguf');
        await unrelatedFile.writeAsString('<html>not a model</html>');
        expect(await ModelDownloadService.hasGgufMagic(shortFile), isFalse);
        expect(await ModelDownloadService.hasGgufMagic(unrelatedFile), isFalse);
      } finally {
        await directory.delete(recursive: true);
      }
    });

    test('Initial download status is a valid state', () {
      expect(
        ModelDownloadService.statusNotifier.value,
        isA<ModelDownloadStatus>(),
      );
      expect(
        ModelDownloadService.progressNotifier.value,
        inInclusiveRange(0.0, 1.0),
      );
    });

    test('Cancel download resets progress safely', () async {
      await ModelDownloadService.cancelDownload();
      expect(ModelDownloadService.statusNotifier.value, equals(ModelDownloadStatus.notDownloaded));
      expect(ModelDownloadService.progressNotifier.value, equals(0.0));
    });
  });
}
