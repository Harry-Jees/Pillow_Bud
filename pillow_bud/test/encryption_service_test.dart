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

    test('Legacy IV-only records remain readable for migration', () async {
      const plainText = 'legacy journal entry';
      final encrypted = await EncryptionService.encrypt(plainText);
      final legacyIv = encrypted['iv']!.split('.').first;

      expect(
        await EncryptionService.decrypt(
          ciphertext: encrypted['ciphertext']!,
          ivBase64: legacyIv,
        ),
        equals(plainText),
      );
    });

    test('Tampered authentication tag is rejected', () async {
      final encrypted = await EncryptionService.encrypt('private journal');
      final separator = encrypted['iv']!.indexOf('.');
      final iv = encrypted['iv']!.substring(0, separator);
      final mac = encrypted['iv']!.substring(separator + 1);
      final replacement = mac.startsWith('0') ? '1' : '0';
      final tamperedIv = '$iv.$replacement${mac.substring(1)}';

      await expectLater(
        EncryptionService.decrypt(
          ciphertext: encrypted['ciphertext']!,
          ivBase64: tamperedIv,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('Empty strings round-trip without key access', () async {
      // Reset the injected test key to prove empty values do not need secure storage.
      EncryptionService.reset();
      SecureKeyStorage.resetCache();

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
