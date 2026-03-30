import 'package:demo/products/presentation/controllers/products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductSearchBar extends GetView<ProductsController> {
  const ProductSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: TextField(
        controller: controller.searchTextController,
        onChanged: controller.onSearchChanged,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Tìm sản phẩm...',
          suffixIcon: Obx(() {
            final hasText = controller.searchQuery.value.trim().isNotEmpty;
            if (!hasText) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller.searchTextController.clear();
                controller.onSearchChanged('');
              },
            );
          }),
          isDense: true,
        ),
      ),
    );
  }
}
