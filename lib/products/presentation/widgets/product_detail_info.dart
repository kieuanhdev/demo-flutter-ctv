import 'package:demo/products/domain/entities/product.dart';
import 'package:flutter/material.dart';

class ProductDetailInfo extends StatelessWidget {
  const ProductDetailInfo({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('ID: ${product.id}'),
        const SizedBox(height: 8),
        Text('Price: ${product.price.toStringAsFixed(2)}'),
        const SizedBox(height: 8),
        if (product.category != null) Text('Category: ${product.category}'),
      ],
    );
  }
}
