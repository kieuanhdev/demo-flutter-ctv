import '../../../core/logger/app_logger.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repository/cart_repository.dart';
import '../datasources/local/cart_hive_store.dart';

final _log = AppLogger.get('CartRepository');

class CartRepositoryImpl implements CartRepository {
  final CartHiveStore localStore;

  CartRepositoryImpl({required this.localStore});

  @override
  Future<Map<int, CartItem>> loadItems() async {
    _log.d('loadItems → reading from Hive');
    final items = await localStore.readItems();
    _log.d('loadItems → ${items.length} items');
    return items;
  }

  @override
  Future<void> saveItems(Map<int, CartItem> items) async {
    _log.d('saveItems → ${items.length} items to Hive');
    await localStore.writeItems(items);
  }
}
