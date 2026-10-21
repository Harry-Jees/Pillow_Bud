import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
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
  group('PBv3 portable backup envelope', () {
    late String validArchive;

    setUpAll(() async {
      const passphrase = 'correct-horse-battery-staple';
      const salt = <int>[
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
      ];
      const iv = <int>[
        16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1,
      ];
      final payload = jsonEncode({
        'version': 3,
        'exported_at': '2026-10-21T00:00:00.000',
        'chat_messages': <dynamic>[],
        'journal_entries': <dynamic>[],
        'mood_logs': <dynamic>[],
      });
      final keyMaterial = _deriveTestKey(passphrase, salt, 64, 120000);
      final cipher = Encrypter(AES(
        Key(Uint8List.fromList(keyMaterial.sublist(0, 32))),
        mode: AESMode.cbc,
      ));
      final encrypted = cipher.encrypt(payload, iv: IV(Uint8List.fromList(iv))).bytes;
      final authenticated = <int>[
        ...utf8.encode('PBv3'),
        ...salt,
        ...iv,
        ...encrypted,
      ];
      final mac = Hmac(sha256, keyMaterial.sublist(32, 64))
          .convert(authenticated)
          .bytes;
      final envelope = jsonEncode({
        'version': 3,
        'kdf': 'PBKDF2-HMAC-SHA256',
        'iterations': 120000,
        'salt': base64Encode(salt),
        'iv': base64Encode(iv),
        'ciphertext': base64Encode(encrypted),
        'mac': base64Encode(mac),
      });
      validArchive = 'PBv3:${base64Encode(utf8.encode(envelope))}';
    });

    test('rejects an incorrect passphrase before database access', () async {
      final file = await _writeTempBackup(validArchive);
      try {
        await expectLater(
          BackupService.importData(file, passphrase: 'wrong-passphrase'),
          throwsA(isA<FormatException>()),
        );
      } finally {
        if (await file.exists()) await file.delete();
      }
    });

    test('rejects a modified ciphertext before database access', () async {
      final decodedEnvelope = jsonDecode(
        utf8.decode(base64Decode(validArchive.substring('PBv3:'.length))),
      ) as Map<String, dynamic>;
      final cipherBytes = base64Decode(decodedEnvelope['ciphertext'] as String);
      cipherBytes[0] ^= 1;
      decodedEnvelope['ciphertext'] = base64Encode(cipherBytes);
      final changed = 'PBv3:${base64Encode(utf8.encode(jsonEncode(decodedEnvelope)))}';
      final file = await _writeTempBackup(changed);
      try {
        await expectLater(
          BackupService.importData(
            file,
            passphrase: 'correct-horse-battery-staple',
          ),
          throwsA(isA<FormatException>()),
        );
      } finally {
        if (await file.exists()) await file.delete();
      }
    });

    test('rejects truncated or malformed PBv3 envelopes', () async {
      final file = await _writeTempBackup('PBv3:not-base64-json');
      try {
        await expectLater(
          BackupService.importData(file, passphrase: 'any-test-passphrase'),
          throwsA(isA<FormatException>()),
        );
      } finally {
        if (await file.exists()) await file.delete();
      }
    });
  });
}

Future<File> _writeTempBackup(String contents) async {
  final file = File(
    '${Directory.systemTemp.path}/pillow_bud_test_${DateTime.now().microsecondsSinceEpoch}.pillowbak',
  );
  await file.writeAsString(contents);
  return file;
}

List<int> _deriveTestKey(
  String passphrase,
  List<int> salt,
  int length,
  int iterations,
) {
  final hmac = Hmac(sha256, utf8.encode(passphrase));
  final output = <int>[];
  var blockIndex = 1;
  while (output.length < length) {
    final blockInput = <int>[
      ...salt,
      (blockIndex >> 24) & 255,
      (blockIndex >> 16) & 255,
      (blockIndex >> 8) & 255,
      blockIndex & 255,
    ];
    var u = hmac.convert(blockInput).bytes;
    final accumulator = List<int>.from(u);
    for (var round = 1; round < iterations; round++) {
      u = hmac.convert(u).bytes;
      for (var i = 0; i < accumulator.length; i++) {
        accumulator[i] ^= u[i];
      }
    }
    output.addAll(accumulator);
    blockIndex++;
  }
  return output.sublist(0, length);
}
