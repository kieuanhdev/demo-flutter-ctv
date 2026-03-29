import 'package:dio/dio.dart';

import '../../../../core/logger/app_logger.dart';

final _log = AppLogger.get('CartRemoteDS');

class CartRemoteDataSource {
  final Dio dio;

  CartRemoteDataSource(this.dio);

  Future<Map<String, dynamic>?> fetchUserLatestCart({required int userId}) async {
    _log.d('GET /carts/user/$userId');
    final response = await dio.get<Map<String, dynamic>>('/carts/user/$userId');
    final data = response.data;
    if (data == null) return null;

    final carts = data['carts'] as List<dynamic>? ?? const <dynamic>[];
    if (carts.isEmpty) return null;

    final latest = carts.last;
    if (latest is Map<String, dynamic>) return latest;
    return null;
  }

  Future<Map<String, dynamic>> addCart({
    required int userId,
    required List<Map<String, dynamic>> products,
  }) async {
    _log.i('POST /carts/add (userId: $userId, items: ${products.length})');
    final response = await dio.post<Map<String, dynamic>>(
      '/carts/add',
      data: <String, dynamic>{'userId': userId, 'products': products},
    );
    return response.data ?? const <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updateCart({
    required int cartId,
    required List<Map<String, dynamic>> products,
  }) async {
    _log.i('PUT /carts/$cartId (items: ${products.length})');
    final response = await dio.put<Map<String, dynamic>>(
      '/carts/$cartId',
      data: <String, dynamic>{'products': products},
    );
    return response.data ?? const <String, dynamic>{};
  }

  Future<void> deleteCart({required int cartId}) async {
    _log.i('DELETE /carts/$cartId');
    await dio.delete<void>('/carts/$cartId');
  }
}
