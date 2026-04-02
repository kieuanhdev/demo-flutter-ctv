import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../products/domain/entities/product.dart';
import '../controllers/cart_controller.dart';
import 'add_to_cart_fly.dart';

class AddToCartButton extends GetView<CartController> {
  const AddToCartButton({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final qty = controller.items[product.id]?.quantity ?? 0;
      return FilledButton.icon(
        onPressed: () async {
          await addProductWithFlyToCart(
            context: context,
            product: product,
          );
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: Text(
          qty > 0 ? 'Thêm nữa (trong giỏ: $qty)' : 'Thêm vào giỏ',
        ),
      );
    });
  }
}
