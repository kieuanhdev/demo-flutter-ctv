import '../entities/products_page.dart';
import '../repository/products_repository.dart';

class SearchProductsUsecase {
  final ProductsRepository repository;
  SearchProductsUsecase(this.repository);
  Future<ProductsPage> call({
    required String q,
    required int skip,
    required int limit,
  }) {
    return repository.searchProducts(q: q, skip: skip, limit: limit);
  }
}
