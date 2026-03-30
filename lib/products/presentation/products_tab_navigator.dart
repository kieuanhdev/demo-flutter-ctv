import 'package:flutter/material.dart';

import '../domain/entities/product.dart';
import 'pages/product_detail_page.dart';
import 'pages/products_page.dart';

/// Route nội bộ tab Sản phẩm — [Navigator] lồng để [MainShellPage] giữ bottom bar.
abstract final class ProductsTabNav {
  static const String root = '/';
  static const String detail = '/product-detail';
}

/// Tab đầu của shell: stack Riêng (danh sách → chi tiết) không che navbar dưới.
class ProductsTabNavigator extends StatelessWidget {
  const ProductsTabNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: ProductsTabNav.root,
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case ProductsTabNav.root:
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const ProductsPage(),
            );
          case ProductsTabNav.detail:
            final product = settings.arguments! as Product;
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => ProductDetailPage(product: product),
            );
          default:
            return MaterialPageRoute<void>(
              settings: const RouteSettings(name: ProductsTabNav.root),
              builder: (_) => const ProductsPage(),
            );
        }
      },
    );
  }
}
