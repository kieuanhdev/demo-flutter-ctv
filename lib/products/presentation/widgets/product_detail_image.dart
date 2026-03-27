import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProductDetailImage extends StatelessWidget {
  const ProductDetailImage({super.key, required this.thumbnail});

  final String? thumbnail;

  @override
  Widget build(BuildContext context) {
    if (thumbnail != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: thumbnail!,
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          errorWidget: (context, _, __) => const SizedBox(
            height: 220,
            child: Center(child: Icon(Icons.broken_image)),
          ),
        ),
      );
    }

    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
      ),
      child: const Center(child: Icon(Icons.inventory_2_outlined, size: 60)),
    );
  }
}
