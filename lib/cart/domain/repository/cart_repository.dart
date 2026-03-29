import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<Map<int, CartItem>> loadItems({required int userId});
  Future<void> saveItems({required int userId, required Map<int, CartItem> items});
  Future<void> clearItems({required int userId});
}
