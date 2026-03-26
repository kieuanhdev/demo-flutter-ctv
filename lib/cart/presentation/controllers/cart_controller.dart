import 'package:get/get.dart';

import '../../../core/logger/app_logger.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/usecases/clear_cart_usecase.dart';
import '../../domain/usecases/load_cart_usecase.dart';
import '../../domain/usecases/save_cart_usecase.dart';

final _log = AppLogger.get('CartController');

class CartController extends GetxController {
  CartController({
    required this.loadCartUsecase,
    required this.saveCartUsecase,
    required this.clearCartUsecase,
  });

  final LoadCartUsecase loadCartUsecase;
  final SaveCartUsecase saveCartUsecase;
  final ClearCartUsecase clearCartUsecase;

  final RxMap<int, CartItem> items = <int, CartItem>{}.obs;
  final RxSet<int> updatingIds = <int>{}.obs;

  int get totalQuantity {
    return items.values.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return items.values.fold<double>(0, (sum, item) => sum + item.subtotal);
  }

  @override
  void onInit() {
    super.onInit();
    _loadLocalCart();
  }

  Future<void> _loadLocalCart() async {
    _log.i('Loading local cart...');
    try {
      final local = await loadCartUsecase();
      items.assignAll(local);
      _log.i('Loaded ${local.length} items from local cart');
    } catch (e, st) {
      _log.e('Failed to load local cart', error: e, stackTrace: st);
      items.clear();
    }
  }

  Future<void> _persistLocalCart() async {
    try {
      await saveCartUsecase(items);
    } catch (e, st) {
      _log.e('Failed to persist cart to Hive', error: e, stackTrace: st);
    }
  }

  Future<void> add(Product product, {int quantity = 1}) async {
    final qty = quantity <= 0 ? 1 : quantity;
    updatingIds.add(product.id);
    try {
      final existing = items[product.id];
      if (existing == null) {
        items[product.id] = CartItem(product: product, quantity: qty);
      } else {
        items[product.id] = existing.copyWith(
          quantity: existing.quantity + qty,
        );
      }
      await _persistLocalCart();
    } finally {
      updatingIds.remove(product.id);
    }
  }

  Future<void> setQuantity(int productId, int quantity) async {
    updatingIds.add(productId);
    try {
      if (quantity <= 0) {
        items.remove(productId);
      } else {
        final existing = items[productId];
        if (existing == null) return;
        items[productId] = existing.copyWith(quantity: quantity);
      }
      await _persistLocalCart();
    } finally {
      updatingIds.remove(productId);
    }
  }

  Future<void> increment(int productId) async {
    final current = items[productId]?.quantity ?? 0;
    if (current <= 0) return;
    await setQuantity(productId, current + 1);
  }

  Future<void> decrement(int productId) async {
    final current = items[productId]?.quantity ?? 0;
    if (current <= 0) return;
    await setQuantity(productId, current - 1);
  }

  Future<void> remove(int productId) async {
    await setQuantity(productId, 0);
  }

  Future<void> clear() async {
    items.clear();
    updatingIds.clear();
    try {
      await clearCartUsecase();
    } catch (e, st) {
      _log.e('Failed to clear cart in Hive', error: e, stackTrace: st);
    }
  }
}
