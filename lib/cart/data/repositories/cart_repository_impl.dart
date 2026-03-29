import '../../../core/logger/app_logger.dart';
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
      if (remoteProducts.isEmpty || localItems.isEmpty) {
        _log.d('loadItems → remote/local empty, using local ${localItems.length}');
        return localItems;
      }

      final remoteQtyById = <int, int>{};
      for (final p in remoteProducts) {
        if (p is! Map<String, dynamic>) continue;
        final id = (p['id'] as num?)?.toInt();
        final qty = (p['quantity'] as num?)?.toInt() ?? 0;
        if (id != null && qty > 0) remoteQtyById[id] = qty;
      }

      final merged = <int, CartItem>{};
      for (final entry in localItems.entries) {
        final remoteQty = remoteQtyById[entry.key];
        if (remoteQty == null || remoteQty <= 0) continue;
        merged[entry.key] = entry.value.copyWith(quantity: remoteQty);
      }

      await localStore.writeItems(merged);
      _log.d('loadItems → merged remote quantities, ${merged.length} items');
      return merged;
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
        return;
      }

      await remoteDataSource.updateCart(cartId: serverCartId, products: products);
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
