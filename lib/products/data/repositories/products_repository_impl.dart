import '../../../core/logger/app_logger.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/products_page.dart';
import '../../domain/repository/products_repository.dart';
import '../datasources/remote/products_remote_data_source.dart';

final _log = AppLogger.get('ProductsRepository');

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource remoteDataSource;

  ProductsRepositoryImpl(this.remoteDataSource);

  @override
  Future<ProductsPage> fetchProducts({
    required int skip,
    required int limit,
  }) async {
    _log.d('fetchProducts(skip: $skip, limit: $limit)');
    final dto = await remoteDataSource.fetchProducts(skip: skip, limit: limit);
    _log.d('fetchProducts → ${dto.products.length} items, total: ${dto.total}');
    return dto.toDomain();
  }

  @override
  Future<ProductsPage> searchProducts({
    required String q,
    required int skip,
    required int limit,
  }) async {
    _log.d('searchProducts(q: "$q", skip: $skip, limit: $limit)');
    final dto = await remoteDataSource.searchProducts(
      q: q,
      skip: skip,
      limit: limit,
    );
    _log.d('searchProducts → ${dto.products.length} results');
    return dto.toDomain();
  }

  @override
  Future<Product> addProduct({
    required String title,
    required double price,
    String? category,
    String? thumbnail,
  }) async {
    _log.i('addProduct: "$title"');
    final dto = await remoteDataSource.addProduct(
      title: title,
      price: price,
      category: category,
      thumbnail: thumbnail,
    );
    _log.i('addProduct → created id: ${dto.id}');
    return dto.toDomain();
  }

  @override
  Future<Product> updateProduct({
    required int id,
    required String title,
    required double price,
    String? category,
    String? thumbnail,
  }) async {
    _log.i('updateProduct #$id: "$title"');
    final dto = await remoteDataSource.updateProduct(
      id: id,
      title: title,
      price: price,
      category: category,
      thumbnail: thumbnail,
    );
    _log.i('updateProduct #$id → done');
    return dto.toDomain();
  }

  @override
  Future<void> deleteProduct({required int id}) async {
    _log.i('deleteProduct #$id');
    await remoteDataSource.deleteProduct(id: id);
    _log.i('deleteProduct #$id → done');
  }
}
