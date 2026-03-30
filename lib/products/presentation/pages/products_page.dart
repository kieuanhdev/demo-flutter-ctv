import 'package:demo/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/product.dart';
import '../products_tab_navigator.dart';
import '../controllers/product_search_bar.dart';
import '../controllers/products_controller.dart';
import '../widgets/logout_button.dart';
import '../widgets/product_grid.dart';

class ProductsPage extends GetView<ProductsController> {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm'),
        actions: [
          const ThemeModeMenuButton(),
          LogoutButton(authController: auth),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Thêm sản phẩm',
        onPressed: () {
          Get.toNamed(AppRoutes.addProduct);
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const ProductSearchBar(),
          Expanded(
            child: ProductGrid(
              onTapProduct: (p) {
                final product = p as Product;
                Navigator.of(context).pushNamed(
                  ProductsTabNav.detail,
                  arguments: product,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
