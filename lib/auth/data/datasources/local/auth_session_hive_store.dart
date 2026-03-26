import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../../../core/logger/app_logger.dart';
import '../../models/auth_session_dto.dart';

final _log = AppLogger.get('AuthHiveStore');

class AuthSessionHiveStore {
  static const String boxName = 'auth_box';
  static const String sessionKey = 'auth_session';

  Future<AuthSessionDto?> read() async {
    final box = Hive.box<String>(boxName);
    if (!box.containsKey(sessionKey)) {
      _log.d('read → no session key in Hive');
      return null;
    }

    try {
      final jsonString = box.get(sessionKey);
      if (jsonString == null) return null;

      final decoded = json.decode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Session payload must be a JSON object');
      }
      _log.d('read → session loaded from Hive');
      return AuthSessionDto.fromJson(decoded);
    } catch (e) {
      _log.e('read → corrupted session, deleting', error: e);
      await box.delete(sessionKey);
      return null;
    }
  }

  Future<void> write(AuthSessionDto session) async {
    final box = Hive.box<String>(boxName);
    try {
      await box.put(sessionKey, json.encode(session.toJson()));
      _log.d('write → session persisted');
    } catch (e) {
      _log.e('write → failed to persist session', error: e);
      throw StateError('Failed to persist auth session: $e');
    }
  }

  Future<void> clear() async {
    final box = Hive.box<String>(boxName);
    try {
      await box.delete(sessionKey);
      _log.d('clear → session removed');
    } catch (e) {
      _log.e('clear → failed', error: e);
      throw StateError('Failed to clear auth session: $e');
    }
  }
}
