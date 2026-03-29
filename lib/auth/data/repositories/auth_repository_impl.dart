import '../../../core/logger/app_logger.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasources/local/auth_session_hive_store.dart';
import '../datasources/remote/auth_remote_data_source.dart';

final _log = AppLogger.get('AuthRepository');

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthSessionHiveStore localStore;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localStore,
  });

  @override
  Future<AuthSession> signIn(String username, String password) async {
    _log.i('signIn → calling remote login...');
    final sessionDto = await remoteDataSource.login(
      username: username,
      password: password,
    );

    _log.d('signIn → saving session to local store');
    await localStore.write(sessionDto);
    return sessionDto.toDomain();
  }

  @override
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _log.i('register → calling remote register...');
    await remoteDataSource.register(
      username: username,
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    _log.i('signOut → clearing local session');
    await localStore.clear();
  }

  @override
  Future<AuthSession?> loadSession() async {
    _log.d('loadSession → reading from local store');
    final dto = await localStore.read();
    _log.d('loadSession → ${dto != null ? 'found' : 'empty'}');
    return dto?.toDomain();
  }
}
