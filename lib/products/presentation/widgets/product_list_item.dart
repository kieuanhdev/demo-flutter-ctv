import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../domain/entities/product.dart';
import '../controllers/products_controller.dart';

class ProductListItem extends GetView<ProductsController> {
  const ProductListItem({
    super.key,
    required this.product,
    required this.cartController,
    required this.onTap,
  });

  final Product product;
  final CartController cartController;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: product.thumbnail != null
                    ? CachedNetworkImage(
                        imageUrl: product.thumbnail!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (context, _, __) => Container(
                          height: 120,
                          color: Colors.grey.shade200,
                          child: const Center(child: Icon(Icons.broken_image)),
                        ),
                      )
                    : Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.inventory_2_outlined),
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              Text(
                product.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                product.category ?? ' ',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Text('\$${product.price.toStringAsFixed(2)}'),
                  const Spacer(),
                  Obx(() {
                    final qty = cartController.items[product.id]?.quantity ?? 0;
                    final isUpdating = cartController.updatingIds.contains(
                      product.id,
                    );

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: isUpdating
                                ? null
                                : () async {
                                    await cartController.add(product);
                                    Get.snackbar(
                                      'Added to cart',
                                      qty > 0
                                          ? 'Now in cart: ${qty + 1}'
                                          : product.title,
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                            ),
                            child: isUpdating
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.add),
                          ),
                        ),
                        if (qty > 0)
                          Positioned(
                            top: -6,
                            right: -6,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.red,
                              child: Text(
                                '$qty',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
