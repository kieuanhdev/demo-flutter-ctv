import '../entities/product.dart';
import '../repository/products_repository.dart';

class UpdateProductUsecase {
  final ProductsRepository repository;
  UpdateProductUsecase(this.repository);
  Future<Product> call({
    required int id,
    required String title,
    required double price,
    String? category,
    String? thumbnail,
  }) {
    return repository.updateProduct(
      id: id,
      title: title,
      price: price,
      category: category,
      thumbnail: thumbnail,
    );
  }
}
