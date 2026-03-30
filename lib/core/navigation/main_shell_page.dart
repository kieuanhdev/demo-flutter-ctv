import 'package:demo/cart/presentation/controllers/cart_controller.dart';
import 'package:demo/cart/presentation/controllers/cart_fly_target_controller.dart';
import 'package:demo/cart/presentation/pages/cart_page.dart';
import 'package:demo/products/presentation/pages/products_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'main_nav_controller.dart';

class MainShellPage extends GetView<MainNavController> {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fly = Get.isRegistered<CartFlyTargetController>()
        ? Get.find<CartFlyTargetController>()
        : null;

    return Obx(() {
      final idx = controller.currentIndex.value;
      final cartIcon = _NavCartIcon(selected: idx == 1);

      return Scaffold(
        body: IndexedStack(
          index: idx,
          children: const [
            ProductsPage(),
            CartPage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: idx,
          onDestinationSelected: (i) => controller.currentIndex.value = i,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront),
              label: 'Sản phẩm',
            ),
            NavigationDestination(
              icon: fly != null
                  ? KeyedSubtree(
                      key: fly.cartIconKey,
                      child: cartIcon,
                    )
                  : cartIcon,
              label: 'Giỏ hàng',
            ),
          ],
        ),
      );
    });
  }
}

class _NavCartIcon extends StatelessWidget {
  const _NavCartIcon({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return GetX<CartController>(
      builder: (cart) {
        final n = cart.totalQuantity;
        final icon = Icon(
          selected ? Icons.shopping_cart : Icons.shopping_cart_outlined,
        );
        if (n <= 0) return icon;
        return Badge(
          label: Text('$n'),
          child: icon,
        );
      },
    );
  }
}
