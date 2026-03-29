import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../../core/logger/app_logger.dart';
import '../../../../products/domain/entities/product.dart';
import '../../../domain/entities/cart_item.dart';

final _log = AppLogger.get('CartHiveStore');

class CartHiveStore {
  static const String boxName = 'cart_box';
  static const String itemsKey = 'cart_items';
  static const String serverCartIdKey = 'server_cart_id';

  Future<Map<int, CartItem>> readItems() async {
    final box = Hive.box<String>(boxName);
    try {
      final jsonString = box.get(itemsKey);
      if (jsonString == null) {
        _log.d('readItems → empty');
        return <int, CartItem>{};
      }

      final decoded = json.decode(jsonString);
      if (decoded is! List<dynamic>) {
        throw const FormatException('Cart payload must be a JSON list');
      }

      final map = <int, CartItem>{};
      for (final e in decoded) {
        if (e is! Map<String, dynamic>) {
          throw const FormatException('Cart item payload must be JSON object');
        }
        final item = _CartItemJson.fromJson(e);
        map[item.productId] = item.toDomain();
      }
      _log.d('readItems → ${map.length} items loaded');
      return map;
    } catch (e) {
      _log.e('readItems → corrupted cart, clearing', error: e);
      await box.delete(itemsKey);
      return <int, CartItem>{};
    }
  }

  Future<void> writeItems(Map<int, CartItem> items) async {
    final box = Hive.box<String>(boxName);
    try {
      final list = items.values
          .map((e) => _CartItemJson.fromDomain(e).toJson())
          .toList();
      await box.put(itemsKey, json.encode(list));
      _log.d('writeItems → ${items.length} items saved');
    } catch (e) {
      _log.e('writeItems → failed', error: e);
      throw StateError('Failed to persist cart items: $e');
    }
  }

  Future<int?> readServerCartId() async {
    final box = Hive.box<String>(boxName);
    try {
      final raw = box.get(serverCartIdKey);
      if (raw == null || raw.isEmpty) return null;
      return int.tryParse(raw);
    } catch (e) {
      _log.e('readServerCartId → failed', error: e);
      return null;
    }
  }

  Future<void> writeServerCartId(int cartId) async {
    final box = Hive.box<String>(boxName);
    try {
      await box.put(serverCartIdKey, cartId.toString());
      _log.d('writeServerCartId → $cartId');
    } catch (e) {
      _log.e('writeServerCartId → failed', error: e);
    }
  }

  Future<void> clearServerCartId() async {
    final box = Hive.box<String>(boxName);
    try {
      await box.delete(serverCartIdKey);
      _log.d('clearServerCartId → done');
    } catch (e) {
      _log.e('clearServerCartId → failed', error: e);
    }
  }
}

class _CartItemJson {
  final int productId;
  final String title;
  final double price;
  final String? category;
  final String? thumbnail;
  final int quantity;

  _CartItemJson({
    required this.productId,
    required this.title,
    required this.price,
    required this.category,
    required this.thumbnail,
    required this.quantity,
  });

  factory _CartItemJson.fromDomain(CartItem item) {
    return _CartItemJson(
      productId: item.product.id,
      title: item.product.title,
      price: item.product.price,
      category: item.product.category,
      thumbnail: item.product.thumbnail,
      quantity: item.quantity,
    );
  }

  factory _CartItemJson.fromJson(Map<String, dynamic> json) {
    return _CartItemJson(
      productId: (json['productId'] as num).toInt(),
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String?,
      thumbnail: json['thumbnail'] as String?,
      quantity: (json['quantity'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'category': category,
      'thumbnail': thumbnail,
      'quantity': quantity,
    };
  }

  CartItem toDomain() {
    return CartItem(
      product: Product(
        id: productId,
        title: title,
        price: price,
        category: category,
        thumbnail: thumbnail,
      ),
      quantity: quantity,
    );
  }
}
