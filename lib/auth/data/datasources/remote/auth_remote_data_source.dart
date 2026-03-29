import 'package:dio/dio.dart';

import '../../../../core/logger/app_logger.dart';
import '../../models/auth_session_dto.dart';

final _log = AppLogger.get('AuthRemoteDS');

class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource(this.dio);

  Future<AuthSessionDto> login({
    required String username,
    required String password,
  }) async {
    _log.i('POST /auth/login — user: $username');
    final response = await dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'username': username, 'password': password},
    );

    final data = response.data;
    if (data == null) {
      _log.e('login → empty response data');
      throw StateError('Empty response data for /auth/login');
    }

    _log.i('login → success');
    return AuthSessionDto.fromJson(data);
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _log.i('POST /auth/register — user: $username');
    await dio.post<dynamic>(
      '/auth/register',
      options: Options(
        // Register may take longer on cold server start / DB migration.
        connectTimeout: const Duration(seconds: 25),
        sendTimeout: const Duration(seconds: 25),
        receiveTimeout: const Duration(seconds: 35),
      ),
      data: <String, dynamic>{
        'username': username,
        'email': email,
        'password': password,
      },
    );
    _log.i('register → success');
  }
}
