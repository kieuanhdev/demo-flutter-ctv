import 'package:dio_log/dio_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth/middleware/auth_middleware.dart';
import 'auth/presentation/pages/login_page.dart';
import 'auth/presentation/pages/register_page.dart';
import 'bindings/add_product_binding.dart';
import 'bindings/edit_product_binding.dart';
import 'bindings/login_binding.dart';
import 'bindings/main_shell_binding.dart';
import 'bindings/register_binding.dart';
import 'core/navigation/main_shell_page.dart';
import 'products/presentation/pages/add_product_page.dart';
import 'products/presentation/pages/edit_product_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String products = '/products';
  static const String profile = '/profile';
  static const String addProduct = '/products/add';
  static const String editProduct = '/products/edit';
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
      binding: LoginBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.products,
      page: () => const MainShellPage(),
      binding: MainShellBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.addProduct,
      page: () => const AddProductPage(),
      binding: AddProductBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.editProduct,
      page: () => const EditProductPage(),
      binding: EditProductBinding(),
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
