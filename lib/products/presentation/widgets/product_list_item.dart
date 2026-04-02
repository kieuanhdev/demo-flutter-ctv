import 'package:cached_network_image/cached_network_image.dart';
import 'package:demo/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../cart/presentation/widgets/add_to_cart_fly.dart';
import '../../domain/entities/product.dart';

class ProductListItem extends StatefulWidget {
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
  State<ProductListItem> createState() => _ProductListItemState();
}

class _ProductListItemState extends State<ProductListItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: widget.onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: widget.product.thumbnail != null
                      ? CachedNetworkImage(
                          imageUrl: widget.product.thumbnail!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (context, _, _) => Container(
                            width: double.infinity,
                            color: context.appCustomColors.imagePlaceholder,
                            child: const Center(
                              child: Icon(Icons.broken_image),
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          color: context.appCustomColors.imagePlaceholder,
                          child: const Center(
                            child: Icon(Icons.inventory_2_outlined),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.product.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                widget.product.category ?? ' ',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('${widget.product.price.toStringAsFixed(2)} đ'),
                  const Spacer(),
                  Obx(() {
                    final qty =
                        widget.cartController.items[widget.product.id]?.quantity ??
                            0;
                    final isUpdating = widget.cartController.updatingIds.contains(
                      widget.product.id,
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
                                    await addProductWithFlyToCart(
                                      context: context,
                                      product: widget.product,
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context
                                  .appCustomColors
                                  .addToCartButton,
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
                              backgroundColor: context
                                  .appCustomColors
                                  .cartQuantityBadge,
                              child: Text(
                                '$qty',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onError,
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
