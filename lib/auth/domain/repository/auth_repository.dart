import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> signIn(String username, String password);
  Future<void> register({
    required String username,
    required String email,
    required String password,
  });
  Future<void> signOut();
  Future<AuthSession?> loadSession();
}
