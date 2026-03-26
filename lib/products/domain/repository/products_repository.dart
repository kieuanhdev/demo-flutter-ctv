import '../entities/product.dart';
import '../entities/products_page.dart';

abstract class ProductsRepository {
  Future<ProductsPage> fetchProducts({required int skip, required int limit});

  Future<ProductsPage> searchProducts({
    required String q,
    required int skip,
    required int limit,
  });

  Future<Product> addProduct({
    required String title,
    required double price,
    String? category,
    String? thumbnail,
  });

  Future<Product> updateProduct({
    required int id,
    required String title,
    required double price,
    String? category,
    String? thumbnail,
  });

  Future<void> deleteProduct({required int id});
}
