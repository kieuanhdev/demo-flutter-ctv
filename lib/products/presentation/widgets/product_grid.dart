import 'package:demo/products/presentation/controllers/products_controller.dart'
    show ProductsController;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../cart/presentation/controllers/cart_controller.dart';
import 'product_list_item.dart';

class ProductGrid extends GetView<ProductsController> {
  const ProductGrid({super.key, required this.onTapProduct});

  final void Function(dynamic product) onTapProduct;

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return Obx(() {
      if (controller.isLoading.value && controller.products.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.error.value != null && controller.products.isEmpty) {
        return Center(child: Text('Error: ${controller.error.value}'));
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 200 &&
              !controller.isLoadingMore.value &&
              controller.hasMore.value &&
              !controller.isLoading.value) {
            controller.loadMore();
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: controller.refreshProducts,
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount:
                controller.products.length +
                (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.products.length) {
                return const Card(
                  elevation: 0,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final product = controller.products[index];
              return ProductListItem(
                product: product,
                cartController: cart,
                onTap: () => onTapProduct(product),
              );
            },
          ),
        ),
      );
    });
  }
}
