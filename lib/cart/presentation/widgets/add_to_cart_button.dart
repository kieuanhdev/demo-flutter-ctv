import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../products/domain/entities/product.dart';
import '../controllers/cart_controller.dart';

class AddToCartButton extends GetView<CartController> {
  const AddToCartButton({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final qty = controller.items[product.id]?.quantity ?? 0;
      return FilledButton.icon(
        onPressed: () async {
          await controller.add(product);
          Get.snackbar('Added to cart', product.title);
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: Text(qty > 0 ? 'Add another (in cart: $qty)' : 'Add to cart'),
      );
    });
  }
}
