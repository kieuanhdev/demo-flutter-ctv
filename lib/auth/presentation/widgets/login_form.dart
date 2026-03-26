import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/login_form_controller.dart';

class LoginForm extends GetView<LoginFormController> {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller.usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        Obx(() {
          final err = auth.error.value;
          if (err == null || err.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Error: $err',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
        }),

        SizedBox(
          height: 48,
          child: Obx(() {
            final isLoading = auth.isLoading.value;
            return ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      await auth.signIn(
                        username: controller.usernameController.text.trim(),
                        password: controller.passwordController.text,
                      );
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login'),
            );
          }),
        ),
      ],
    );
  }
}
