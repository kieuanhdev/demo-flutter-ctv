import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app_routes.dart';
import '../controllers/auth_controller.dart';
import '../controllers/login_form_controller.dart';

class LoginForm extends GetView<LoginFormController> {
  const LoginForm({super.key});

  static const _fieldDecoration = InputDecoration();

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
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: controller.validateUsername,
            decoration: _fieldDecoration.copyWith(
              labelText: 'Tên đăng nhập',
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => TextFormField(
              controller: controller.passwordController,
              obscureText: controller.obscurePassword.value,
              textInputAction: TextInputAction.done,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: controller.validatePassword,
              onFieldSubmitted: (_) async {
                if (!controller.validate()) return;
                await auth.signIn(
                  username: controller.usernameController.text.trim(),
                  password: controller.passwordController.text,
                );
              },
              decoration: _fieldDecoration.copyWith(
                labelText: 'Mật khẩu',
                suffixIcon: IconButton(
                  onPressed: controller.toggleObscurePassword,
                  icon: Icon(
                    controller.obscurePassword.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  tooltip: controller.obscurePassword.value
                      ? 'Hiện mật khẩu'
                      : 'Ẩn mật khẩu',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final err = auth.error.value;
            if (err == null || err.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                err,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            );
          }),
          Obx(() {
            final isLoading = auth.isSigningIn.value;
            return FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!controller.validate()) return;
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
                  : const Text('Đăng nhập'),
            );
          }),
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.register),
            child: const Text('Chưa có tài khoản? Đăng ký'),
          ),
        ],
      ),
    );
  }
}
