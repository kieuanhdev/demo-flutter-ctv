import 'package:demo/core/theme/theme.dart';
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
        title: const Text('Giỏ hàng'),
        actions: [
          const ThemeModeMenuButton(),
          IconButton(
            tooltip: 'Xóa giỏ hàng',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: controller.clear,
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.items.isEmpty) {
            return const Center(child: Text('Giỏ hàng của bạn đang trống.'));
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
