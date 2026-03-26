import '../entities/products_page.dart';
import '../repository/products_repository.dart';

class FetchProductsUsecase {
  final ProductsRepository repository;
  FetchProductsUsecase(this.repository);
  Future<ProductsPage> call({required int skip, required int limit}) {
    return repository.fetchProducts(skip: skip, limit: limit);
  }
}
