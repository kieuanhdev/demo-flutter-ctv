import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../widgets/cart_item_list.dart';
import '../widgets/cart_summary.dart';

class CartPage extends GetView<CartController> {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            tooltip: 'Clear cart',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: controller.clear,
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.items.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          final lines = controller.items.values.toList();

          return Column(
            children: [
              Expanded(child: CartItemList(items: lines)),
              CartSummary(totalPrice: controller.totalPrice),
            ],
          );
        }),
      ),
    );
  }
}
