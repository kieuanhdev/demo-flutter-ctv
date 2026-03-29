import '../entities/auth_session.dart';
import '../repository/auth_repository.dart';

class SignInUsecase {
  final AuthRepository repository;
  SignInUsecase(this.repository);
  Future<AuthSession> call({
    required String username,
    required String password,
  }) {
    return repository.signIn(username, password);
  }
}
