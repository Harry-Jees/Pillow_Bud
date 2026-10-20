import 'package:flutter_test/flutter_test.dart';
import 'package:pillow_bud/services/encryption/encryption_service.dart';
import 'package:pillow_bud/services/encryption/secure_key_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Encryption & Security Tests', () {
    setUp(() {
      SecureKeyStorage.resetCache();
      SecureKeyStorage.setMasterKeyForTesting(
        'test-only-key-material-for-pillow-bud-2026',
      );
      EncryptionService.reset();
    });

    test('Encrypts and decrypts text accurately', () async {
      const plainText = 'I felt overwhelmed at work today, but talking to Bud helped.';
      final encrypted = await EncryptionService.encrypt(plainText);
      expect(encrypted['ciphertext'], isNotEmpty);
      expect(encrypted['iv'], contains('.'));
      expect(encrypted['ciphertext']!.contains('overwhelmed'), isFalse);
      expect(
        await EncryptionService.decrypt(
          ciphertext: encrypted['ciphertext']!,
          ivBase64: encrypted['iv']!,
        ),
        equals(plainText),
      );
    });

    test('Random IVs produce distinct ciphertexts', () async {
      const plainText = 'Same thought repeated twice';
      final first = await EncryptionService.encrypt(plainText);
      final second = await EncryptionService.encrypt(plainText);
      expect(first['iv'], isNot(equals(second['iv'])));
      expect(first['ciphertext'], isNot(equals(second['ciphertext'])));
      expect(
        await EncryptionService.decrypt(
          ciphertext: first['ciphertext']!,
          ivBase64: first['iv']!,
        ),
        equals(plainText),
      );
    });

    test('Tampered ciphertext fails authentication', () async {
      final encrypted = await EncryptionService.encrypt('private note');
      final original = encrypted['ciphertext']!;
      final tampered = '${original.substring(0, original.length - 2)}AA';
      await expectLater(
        EncryptionService.decrypt(
          ciphertext: tampered,
          ivBase64: encrypted['iv']!,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('Empty strings round-trip without key access', () async {
      final encrypted = await EncryptionService.encrypt('');
      expect(encrypted['ciphertext'], isEmpty);
      expect(encrypted['iv'], isEmpty);
      expect(
        await EncryptionService.decrypt(ciphertext: '', ivBase64: ''),
        isEmpty,
      );
    });
  });
}
