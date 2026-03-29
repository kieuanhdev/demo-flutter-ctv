import 'package:get/get.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../core/logger/app_logger.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/usecases/clear_cart_usecase.dart';
import '../../domain/usecases/load_cart_usecase.dart';
import '../../domain/usecases/save_cart_usecase.dart';

final _log = AppLogger.get('CartController');

class CartController extends GetxController {
  CartController({
    required this.authController,
    required this.loadCartUsecase,
    required this.saveCartUsecase,
    required this.clearCartUsecase,
  });

  final AuthController authController;
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
    final userId = authController.session.value?.profile.id;
    if (userId != null) {
      _loadCart(userId);
    }

    ever(authController.session, (session) async {
      final nextUserId = session?.profile.id;
      if (nextUserId == null) {
        items.clear();
        updatingIds.clear();
        return;
      }
      await _loadCart(nextUserId);
    });
  }

  int? get _userId => authController.session.value?.profile.id;

  Future<void> _loadCart(int userId) async {
    _log.i('Loading cart for userId=$userId...');
    try {
      final local = await loadCartUsecase(userId: userId);
      items.assignAll(local);
      _log.i('Loaded ${local.length} items');
    } catch (e, st) {
      _log.e('Failed to load cart', error: e, stackTrace: st);
      items.clear();
    }
  }

  Future<void> _persistCart() async {
    final userId = _userId;
    if (userId == null) return;
    try {
      await saveCartUsecase(userId: userId, items: items);
    } catch (e, st) {
      _log.e('Failed to persist cart', error: e, stackTrace: st);
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
      await _persistCart();
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
      await _persistCart();
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
    final userId = _userId;
    items.clear();
    updatingIds.clear();
    if (userId == null) return;
    try {
      await clearCartUsecase(userId: userId);
    } catch (e, st) {
      _log.e('Failed to clear cart', error: e, stackTrace: st);
    }
  }
}
