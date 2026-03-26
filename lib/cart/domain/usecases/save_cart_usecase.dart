import '../entities/cart_item.dart';
import '../repository/cart_repository.dart';

class SaveCartUsecase {
  final CartRepository repository;
  SaveCartUsecase(this.repository);
  Future<void> call(Map<int, CartItem> items) {
    return repository.saveItems(items);
  }
}
