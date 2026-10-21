import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillow_bud/services/backup/backup_service.dart';
import 'package:pillow_bud/services/encryption/secure_key_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testKey = 'test-only-key-material-for-pillow-bud-2026';

  setUp(() {
    SecureKeyStorage.resetCache();
    SecureKeyStorage.setMasterKeyForTesting(testKey);
  });

  tearDown(() {
    SecureKeyStorage.resetCache();
  });

  test('does not report a restore as successful when the database is unavailable', () async {
    final fingerprint = sha256.convert(utf8.encode(testKey)).toString();
    final payload = jsonEncode({
      'version': 2,
      'key_fingerprint': fingerprint,
      'chat_messages': <dynamic>[],
      'journal_entries': <dynamic>[],
      'mood_logs': <dynamic>[],
    });
    final file = await File(
      '${Directory.systemTemp.path}/pillow_bud_no_db_${DateTime.now().microsecondsSinceEpoch}.pillowbak',
    ).create();
    try {
      await file.writeAsString('PBv2:${base64Encode(utf8.encode(payload))}');
      await expectLater(
        BackupService.importData(file, passphrase: 'test-passphrase'),
        throwsA(isA<StateError>()),
      );
    } finally {
      if (await file.exists()) await file.delete();
    }
  });

  test('rejects malformed table structure before attempting restore', () async {
    final fingerprint = sha256.convert(utf8.encode(testKey)).toString();
    final payload = jsonEncode({
      'version': 2,
      'key_fingerprint': fingerprint,
      'chat_messages': 'not-a-list',
      'journal_entries': <dynamic>[],
      'mood_logs': <dynamic>[],
    });
    final file = await File(
      '${Directory.systemTemp.path}/pillow_bud_bad_backup_${DateTime.now().microsecondsSinceEpoch}.pillowbak',
    ).create();
    try {
      await file.writeAsString('PBv2:${base64Encode(utf8.encode(payload))}');
      await expectLater(
        BackupService.importData(file, passphrase: 'test-passphrase'),
        throwsA(isA<FormatException>()),
      );
    } finally {
      if (await file.exists()) await file.delete();
    }
  });

  test('rejects malformed records before attempting restore', () async {
    final fingerprint = sha256.convert(utf8.encode(testKey)).toString();
    final payload = jsonEncode({
      'version': 2,
      'key_fingerprint': fingerprint,
      'chat_messages': <dynamic>[{'id': 'valid-shape'}, 'invalid-row'],
      'journal_entries': <dynamic>[],
      'mood_logs': <dynamic>[],
    });
    final file = await File(
      '${Directory.systemTemp.path}/pillow_bud_bad_backup_${DateTime.now().microsecondsSinceEpoch}.pillowbak',
    ).create();
    try {
      await file.writeAsString('PBv2:${base64Encode(utf8.encode(payload))}');
      await expectLater(
        BackupService.importData(file, passphrase: 'test-passphrase'),
        throwsA(isA<FormatException>()),
      );
    } finally {
      if (await file.exists()) await file.delete();
    }
  });
}
