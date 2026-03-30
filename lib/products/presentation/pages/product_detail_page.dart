import 'package:demo/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app_routes.dart';
import '../../../cart/presentation/widgets/add_to_cart_button.dart';
import '../../domain/entities/product.dart';
import '../widgets/product_action_buttons.dart';
import '../widgets/product_detail_image.dart';
import '../widgets/product_detail_info.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        actions: const [
          ThemeModeMenuButton(),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ProductDetailImage(thumbnail: product.thumbnail),
            const SizedBox(height: 16),
            ProductDetailInfo(product: product),
            const SizedBox(height: 24),
            AddToCartButton(product: product),
            const SizedBox(height: 16),
            ProductActionButtons(
              product: product,
              onEdit: () {
                Get.toNamed(AppRoutes.editProduct, arguments: product);
              },
              onDeleted: () {
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
