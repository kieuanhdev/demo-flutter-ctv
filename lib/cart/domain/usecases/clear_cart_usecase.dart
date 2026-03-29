import '../repository/cart_repository.dart';

class ClearCartUsecase {
  final CartRepository repository;
  ClearCartUsecase(this.repository);
  Future<void> call({required int userId}) {
    return repository.clearItems(userId: userId);
  }
}
