import '../../domain/entities/product.dart';

class ProductDto {
  final int id;
  final String title;
  final String? category;
  final double price;
  final String? thumbnail;

  const ProductDto({
    required this.id,
    required this.title,
    this.category,
    required this.price,
    this.thumbnail,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    final priceNum = json['price'] as num?;
    return ProductDto(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      category: json['category'] as String?,
      price: priceNum == null ? 0 : priceNum.toDouble(),
      thumbnail: json['thumbnail'] as String?,
    );
  }

  Product toDomain() {
    return Product(
      id: id,
      title: title,
      category: category,
      price: price,
      thumbnail: thumbnail,
    );
  }
}
