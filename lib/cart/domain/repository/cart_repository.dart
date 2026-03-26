import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<Map<int, CartItem>> loadItems();
  Future<void> saveItems(Map<int, CartItem> items);
}
