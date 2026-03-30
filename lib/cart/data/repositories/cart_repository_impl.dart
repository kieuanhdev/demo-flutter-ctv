import '../../../core/logger/app_logger.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repository/cart_repository.dart';
import '../datasources/local/cart_hive_store.dart';
import '../datasources/remote/cart_remote_data_source.dart';

final _log = AppLogger.get('CartRepository');

class CartRepositoryImpl implements CartRepository {
  final CartHiveStore localStore;
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({
    required this.localStore,
    required this.remoteDataSource,
  });

  @override
  Future<Map<int, CartItem>> loadItems({required int userId}) async {
    _log.d('loadItems → reading from Hive');
    final localItems = await localStore.readItems();

    try {
      final remoteCart = await remoteDataSource.fetchUserLatestCart(userId: userId);
      if (remoteCart == null) {
        await localStore.clearServerCartId();
        _log.d('loadItems → no remote cart, using local ${localItems.length}');
        return localItems;
      }

      final remoteCartId = (remoteCart['id'] as num?)?.toInt();
      if (remoteCartId != null) {
        await localStore.writeServerCartId(remoteCartId);
      }

      final remoteProducts =
          remoteCart['products'] as List<dynamic>? ?? const <dynamic>[];

      /// Máy đã có giỏ local → giữ số lượng Hive; ghi đè lại server (merge: false)
      /// để sửa các lần PUT trước từng bị API gộp/cộng dồn (DummyJSON).
      if (localItems.isNotEmpty) {
        if (remoteCartId != null) {
          try {
            final products = localItems.values
                .map(
                  (item) => <String, dynamic>{
                    'id': item.product.id,
                    'quantity': item.quantity,
                  },
                )
                .toList();
            await remoteDataSource.updateCart(
              cartId: remoteCartId,
              products: products,
              merge: false,
            );
            _log.d(
              'loadItems → reconciled server with local (${localItems.length} items)',
            );
          } catch (e) {
            _log.w('loadItems → reconcile server skipped: $e');
          }
        }
        return localItems;
      }

      if (remoteProducts.isEmpty) {
        _log.d('loadItems → local & remote empty');
        return localItems;
      }

      final hydrated = _hydrateFromRemoteProducts(remoteProducts);
      await localStore.writeItems(hydrated);
      _log.d('loadItems → hydrated from remote, ${hydrated.length} items');
      return hydrated;
    } catch (e) {
      _log.e('loadItems → remote sync failed, fallback local', error: e);
      return localItems;
    }
  }

  @override
  Future<void> saveItems({
    required int userId,
    required Map<int, CartItem> items,
  }) async {
    _log.d('saveItems → ${items.length} items to Hive');
    await localStore.writeItems(items);

    try {
      final products = items.values
          .map(
            (item) => <String, dynamic>{
              'id': item.product.id,
              'quantity': item.quantity,
            },
          )
          .toList();
      final serverCartId = await localStore.readServerCartId();

      if (serverCartId == null) {
        final created = await remoteDataSource.addCart(
          userId: userId,
          products: products,
        );
        final createdId = (created['id'] as num?)?.toInt();
        if (createdId != null) {
          await localStore.writeServerCartId(createdId);
        }
        _log.i(
          'saveItems → synced to server (POST /carts/add, '
          'serverCartId=${createdId ?? "?"}, items=${products.length})',
        );
        return;
      }

      await remoteDataSource.updateCart(
        cartId: serverCartId,
        products: products,
        merge: false,
      );
      _log.i(
        'saveItems → synced to server (PUT /carts/$serverCartId, '
        'items=${products.length})',
      );
    } catch (e) {
      _log.e('saveItems → remote sync failed', error: e);
    }
  }

  @override
  Future<void> clearItems({required int userId}) async {
    await localStore.writeItems(const <int, CartItem>{});
    final serverCartId = await localStore.readServerCartId();
    if (serverCartId != null) {
      try {
        await remoteDataSource.deleteCart(cartId: serverCartId);
      } catch (e) {
        _log.e('clearItems → remote delete failed', error: e);
      }
    }
    await localStore.clearServerCartId();
  }
}

/// Ghép dòng từ GET cart (DummyJSON: id, title, price, quantity, thumbnail…).
Map<int, CartItem> _hydrateFromRemoteProducts(List<dynamic> remoteProducts) {
  final map = <int, CartItem>{};
  for (final raw in remoteProducts) {
    if (raw is! Map<String, dynamic>) continue;
    final id = (raw['id'] as num?)?.toInt();
    final qty = (raw['quantity'] as num?)?.toInt() ?? 0;
    final title = raw['title'] as String?;
    final price = (raw['price'] as num?)?.toDouble();
    if (id == null || qty <= 0 || title == null || price == null) continue;

    final product = Product(
      id: id,
      title: title,
      price: price,
      category: raw['category'] as String?,
      thumbnail: raw['thumbnail'] as String?,
    );
    final line = CartItem(product: product, quantity: qty);
    final existing = map[id];
    if (existing == null) {
      map[id] = line;
    } else {
      map[id] = existing.copyWith(quantity: existing.quantity + qty);
    }
  }
  return map;
}
