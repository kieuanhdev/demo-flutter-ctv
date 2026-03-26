import '../../domain/entities/products_page.dart';
import 'product_dto.dart';

class ProductsPageDto {
  final List<ProductDto> products;
  final int total;
  final int skip;
  final int limit;
  const ProductsPageDto({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });
  factory ProductsPageDto.fromJson(Map<String, dynamic> json) {
    final productsJson =
        json['products'] as List<dynamic>? ?? const <dynamic>[];
    return ProductsPageDto(
      products: productsJson
          .map((e) => ProductDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      skip: (json['skip'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 0,
    );
  }
  ProductsPage toDomain() {
    return ProductsPage(
      products: products.map((e) => e.toDomain()).toList(),
      total: total,
      skip: skip,
      limit: limit,
    );
  }
}
