class Product {
  final int id;
  final String title;
  final String? category;
  final double price;
  final String? thumbnail;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    this.category,
    this.thumbnail,
  });
}
