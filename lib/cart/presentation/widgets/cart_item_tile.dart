import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/cart_item.dart';
import '../controllers/cart_controller.dart';

class CartItemTile extends GetView<CartController> {
  const CartItemTile({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: item.product.thumbnail != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item.product.thumbnail!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorWidget: (context, _, __) =>
                    const Icon(Icons.broken_image, size: 20),
              ),
            )
          : const Icon(Icons.inventory_2_outlined),
      title: Text(item.product.title),
      subtitle: Text(
        'Giá: ${item.product.price} • Tạm tính: ${item.subtotal}',
      ),
      trailing: SizedBox(
        width: 160,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => controller.decrement(item.product.id),
            ),
            Text('${item.quantity}'),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => controller.increment(item.product.id),
            ),
          ],
        ),
      ),
    );
  }
}
