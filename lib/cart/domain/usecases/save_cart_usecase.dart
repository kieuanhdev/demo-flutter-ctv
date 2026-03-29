import '../entities/cart_item.dart';
import '../repository/cart_repository.dart';

class SaveCartUsecase {
  final CartRepository repository;
  SaveCartUsecase(this.repository);
  Future<void> call({required int userId, required Map<int, CartItem> items}) {
    return repository.saveItems(userId: userId, items: items);
  }
}
