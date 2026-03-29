import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../app_routes.dart';
import '../presentation/controllers/auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthController>();
    final isLoggedIn = auth.session.value != null;
    final isPublicRoute =
        route == AppRoutes.login || route == AppRoutes.register;

    if (!isLoggedIn && !isPublicRoute) {
      return const RouteSettings(name: AppRoutes.login);
    }
    if (isLoggedIn && isPublicRoute) {
      return const RouteSettings(name: AppRoutes.products);
    }
    return null;
  }
}
