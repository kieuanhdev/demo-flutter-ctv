import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app_routes.dart';
import '../controllers/auth_controller.dart';
import '../controllers/register_form_controller.dart';

class RegisterForm extends GetView<RegisterFormController> {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: controller.usernameController,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: controller.validateUsername,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: controller.validateEmail,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'you@example.com',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.passwordController,
            obscureText: true,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: controller.validatePassword,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.confirmPasswordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: controller.validateConfirmPassword,
            onFieldSubmitted: (_) async {
              if (!controller.validate()) return;
              await auth.register(
                username: controller.usernameController.text.trim(),
                email: controller.emailController.text.trim(),
                password: controller.passwordController.text,
              );
            },
            decoration: const InputDecoration(
              labelText: 'Confirm password',
              border: OutlineInputBorder(),
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
              final isLoading = auth.isRegistering.value;
              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!controller.validate()) return;
                        await auth.register(
                          username: controller.usernameController.text.trim(),
                          email: controller.emailController.text.trim(),
                          password: controller.passwordController.text,
                        );
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Register'),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Get.offAllNamed(AppRoutes.login),
            child: const Text('Already have an account? Login'),
          ),
        ],
      ),
    );
  }
}
