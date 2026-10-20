import 'package:flutter_test/flutter_test.dart';
import 'package:pillow_bud/services/encryption/encryption_service.dart';
import 'package:pillow_bud/services/encryption/secure_key_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Encryption & Security Tests', () {
    setUp(() {
      SecureKeyStorage.resetCache();
      EncryptionService.reset();
    });

    test('SecureKeyStorage generates and retrieves 256-bit key', () async {
      final key = await SecureKeyStorage.getOrCreateMasterKey();
      expect(key, isNotEmpty);
      expect(key.length, greaterThanOrEqualTo(32));

      // Subsequent call should return cached / identical key
      final key2 = await SecureKeyStorage.getOrCreateMasterKey();
      expect(key2, equals(key));
    });

    test('EncryptionService encrypts and decrypts text accurately', () async {
      const plainText = 'I felt overwhelmed at work today, but talking to Bud helped.';
      final encrypted = await EncryptionService.encrypt(plainText);

      expect(encrypted['ciphertext'], isNotEmpty);
      expect(encrypted['iv'], isNotEmpty);
      // Ciphertext should not contain plaintext
      expect(encrypted['ciphertext']!.contains('overwhelmed'), isFalse);

      final decrypted = await EncryptionService.decrypt(
        ciphertext: encrypted['ciphertext']!,
        ivBase64: encrypted['iv']!,
      );

      expect(decrypted, equals(plainText));
    });

    test('Two encryptions of same text yield distinct ciphertexts due to random IVs', () async {
      const plainText = 'Same thought repeated twice';
      final enc1 = await EncryptionService.encrypt(plainText);
      final enc2 = await EncryptionService.encrypt(plainText);

      expect(enc1['iv'], isNot(equals(enc2['iv'])));
      expect(enc1['ciphertext'], isNot(equals(enc2['ciphertext'])));

      final dec1 = await EncryptionService.decrypt(
        ciphertext: enc1['ciphertext']!,
        ivBase64: enc1['iv']!,
      );
      final dec2 = await EncryptionService.decrypt(
        ciphertext: enc2['ciphertext']!,
        ivBase64: enc2['iv']!,
      );

      expect(dec1, equals(plainText));
      expect(dec2, equals(plainText));
    });

    test('Handles empty strings gracefully', () async {
      final res = await EncryptionService.encrypt('');
      expect(res['ciphertext'], isEmpty);
      expect(res['iv'], isEmpty);

      final dec = await EncryptionService.decrypt(ciphertext: '', ivBase64: '');
      expect(dec, isEmpty);
    });
  });
}
