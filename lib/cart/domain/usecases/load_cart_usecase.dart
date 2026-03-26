import '../entities/cart_item.dart';
import '../repository/cart_repository.dart';

class LoadCartUsecase {
  final CartRepository repository;
  LoadCartUsecase(this.repository);
  Future<Map<int, CartItem>> call() {
    return repository.loadItems();
  }
}
