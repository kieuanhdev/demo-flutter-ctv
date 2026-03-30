import 'package:dio_log/dio_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth/middleware/auth_middleware.dart';
import 'auth/presentation/controllers/login_form_controller.dart';
import 'auth/presentation/controllers/register_form_controller.dart';
import 'auth/presentation/pages/login_page.dart';
import 'auth/presentation/pages/register_page.dart';
import 'core/navigation/main_shell_page.dart';
import 'products/domain/entities/product.dart';

import 'products/presentation/controllers/add_product_controller.dart';
import 'products/presentation/controllers/edit_product_controller.dart';
import 'products/presentation/controllers/products_controller.dart';
import 'products/presentation/pages/add_product_page.dart';
import 'products/presentation/pages/edit_product_page.dart';
import 'products/presentation/pages/product_detail_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String products = '/products';
  static const String profile = '/profile';
  static const String addProduct = '/products/add';
  static const String editProduct = '/products/edit';
  static const String productDetail = '/products/detail';
}

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: BindingsBuilder(() {
        Get.put(LoginFormController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: BindingsBuilder(() {
        Get.put(RegisterFormController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.products,
      page: () => const MainShellPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.addProduct,
      page: () => const AddProductPage(),
      binding: BindingsBuilder(() {
        final productsController = Get.find<ProductsController>();
        Get.put(AddProductController(productsController: productsController));
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.editProduct,
      page: () => const EditProductPage(),
      binding: BindingsBuilder(() {
        final productsController = Get.find<ProductsController>();
        final product = Get.arguments as Product;
        Get.put(
          EditProductController(
            productsController: productsController,
            product: product,
          ),
        );
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () {
        final product = Get.arguments as Product;
        return ProductDetailPage(product: product);
      },
      middlewares: [AuthMiddleware()],
    ),
  ];
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      showDebugBtn(context, btnColor: Colors.deepOrange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
