import 'package:dio/dio.dart';

import '../../../../core/logger/app_logger.dart';
import '../../models/product_dto.dart';
import '../../models/products_page_dto.dart';

final _log = AppLogger.get('ProductsRemoteDS');

class ProductsRemoteDataSource {
  final Dio dio;
  ProductsRemoteDataSource(this.dio);
  Future<ProductsPageDto> fetchProducts({
    required int skip,
    required int limit,
  }) async {
    _log.d('GET /products (skip: $skip, limit: $limit)');
    final response = await dio.get<Map<String, dynamic>>(
      '/products',
      queryParameters: {'skip': skip, 'limit': limit},
    );
    return ProductsPageDto.fromJson(response.data ?? const <String, dynamic>{});
  }

  Future<ProductsPageDto> searchProducts({
    required String q,
    required int skip,
    required int limit,
  }) async {
    _log.d('GET /products/search (q: "$q", skip: $skip, limit: $limit)');
    final response = await dio.get<Map<String, dynamic>>(
      '/products/search',
      queryParameters: {'q': q, 'skip': skip, 'limit': limit},
    );
    return ProductsPageDto.fromJson(response.data ?? const <String, dynamic>{});
  }

  Future<ProductDto> addProduct({
    required String title,
    required double price,
    String? category,
    String? thumbnail,
  }) async {
    _log.i('POST /products/add — title: "$title"');
    final response = await dio.post<Map<String, dynamic>>(
      '/products/add',
      data: <String, dynamic>{
        'title': title,
        'price': price,
        if (category != null && category.trim().isNotEmpty)
          'category': category.trim(),
        if (thumbnail != null && thumbnail.trim().isNotEmpty)
          'thumbnail': thumbnail.trim(),
      },
    );
    return ProductDto.fromJson(response.data ?? const <String, dynamic>{});
  }

  Future<ProductDto> updateProduct({
    required int id,
    required String title,
    required double price,
    String? category,
    String? thumbnail,
  }) async {
    _log.i('PUT /products/$id — title: "$title"');
    final response = await dio.put<Map<String, dynamic>>(
      '/products/$id',
      data: <String, dynamic>{
        'title': title,
        'price': price,
        if (category != null && category.trim().isNotEmpty)
          'category': category.trim(),
        if (thumbnail != null && thumbnail.trim().isNotEmpty)
          'thumbnail': thumbnail.trim(),
      },
    );
    return ProductDto.fromJson(response.data ?? const <String, dynamic>{});
  }

  Future<void> deleteProduct({required int id}) async {
    _log.i('DELETE /products/$id');
    await dio.delete<void>('/products/$id');
    _log.i('DELETE /products/$id → done');
  }
}
