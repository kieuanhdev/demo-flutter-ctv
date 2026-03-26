import '../entities/product.dart';
import '../repository/products_repository.dart';

class AddProductUsecase {
  final ProductsRepository repository;
  AddProductUsecase(this.repository);
  Future<Product> call({
    required String title,
    required double price,
    String? category,
    String? thumbnail,
  }) {
    return repository.addProduct(
      title: title,
      price: price,
      category: category,
      thumbnail: thumbnail,
    );
  }
}
