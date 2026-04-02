import 'package:demo/cart/presentation/controllers/cart_controller.dart';
import 'package:demo/cart/presentation/pages/cart_page.dart';
import 'package:demo/auth/presentation/pages/profile_page.dart';
import 'package:demo/products/presentation/products_tab_navigator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'main_nav_controller.dart';

class MainShellPage extends GetView<MainNavController> {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final idx = controller.currentIndex.value;
      final cartIcon = _NavCartIcon(selected: idx == 1);

      return Scaffold(
        body: IndexedStack(
          index: idx,
          children: const [
            ProductsTabNavigator(),
            CartPage(),
            ProfilePage(),
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
              icon: cartIcon,
              label: 'Giỏ hàng',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Tài khoản',
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
