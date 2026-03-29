import '../entities/auth_session.dart';
import '../repository/auth_repository.dart';

class LoadSessionUsecase {
  final AuthRepository repository;
  LoadSessionUsecase(this.repository);
  Future<AuthSession?> call() {
    return repository.loadSession();
  }
}
