import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key, required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = authController.isSigningOut.value;
      return IconButton(
        onPressed: isLoading ? null : authController.signOut,
        icon: const Icon(Icons.logout),
      );
    });
  }
}
