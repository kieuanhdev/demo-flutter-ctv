import '../repository/cart_repository.dart';

class ClearCartUsecase {
  final CartRepository repository;
  ClearCartUsecase(this.repository);
  Future<void> call() {
    return repository.saveItems(const <int, Never>{});
  }
}
