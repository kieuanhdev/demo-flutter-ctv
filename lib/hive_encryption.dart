import 'dart:convert';
import 'package:demo/core/logger/app_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

final _log = AppLogger.get('HiveEncryption');

class HiveEncryption {
  static const String _keyStorageName = 'hive_encryption_key_v1';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<HiveAesCipher> buildCipher() async {
    _log.d('Building AES cipher...');
    final keyBytes = await _loadOrCreateKey();
    return HiveAesCipher(keyBytes);
  }

  static Future<void> openEncryptedStringBox(
    String boxName, {
    required HiveAesCipher cipher,
  }) async {
    _log.d('Opening encrypted box "$boxName"...');
    try {
      await Hive.openBox<String>(boxName, encryptionCipher: cipher);
      _log.i('Box "$boxName" opened (encrypted)');
      return;
    } catch (e) {
      _log.w('Box "$boxName" failed to open encrypted — migrating: $e');
    }

    Map<dynamic, String> backupEntries = <dynamic, String>{};
    Box<String>? plainBox;
    try {
      plainBox = await Hive.openBox<String>(boxName);
      backupEntries = Map<dynamic, String>.from(plainBox.toMap());
      _log.d('Backed up ${backupEntries.length} entries from plain box');
    } catch (e) {
      _log.e('Failed to read plain box "$boxName"', error: e);
      backupEntries = <dynamic, String>{};
    } finally {
      if (plainBox != null && plainBox.isOpen) {
        await plainBox.close();
      }
      await Hive.deleteBoxFromDisk(boxName);
    }

    final encryptedBox = await Hive.openBox<String>(
      boxName,
      encryptionCipher: cipher,
    );

    if (backupEntries.isNotEmpty) {
      await encryptedBox.putAll(backupEntries);
      _log.i(
        'Migrated ${backupEntries.length} entries to encrypted box "$boxName"',
      );
    }
  }

  static Future<List<int>> _loadOrCreateKey() async {
    final raw = await _secureStorage.read(key: _keyStorageName);
    if (raw != null && raw.isNotEmpty) {
      _log.d('Encryption key loaded from secure storage');
      return base64Url.decode(raw);
    }

    _log.i('No encryption key found — generating new key');
    final newKey = Hive.generateSecureKey();
    await _secureStorage.write(
      key: _keyStorageName,
      value: base64UrlEncode(newKey),
    );
    return newKey;
  }
}
