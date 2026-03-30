import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app_routes.dart';
import '../controllers/auth_controller.dart';
import '../controllers/register_form_controller.dart';

class RegisterForm extends GetView<RegisterFormController> {
  const RegisterForm({super.key});

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
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.none,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: controller.validateUsername,
            decoration: _fieldDecoration.copyWith(labelText: 'Tên đăng nhập'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: controller.validateEmail,
            decoration: _fieldDecoration.copyWith(
              labelText: 'Email',
              hintText: 'ban@email.com',
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => TextFormField(
              controller: controller.passwordController,
              obscureText: controller.obscurePassword.value,
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: controller.validatePassword,
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
          const SizedBox(height: 12),
          Obx(
            () => TextFormField(
              controller: controller.confirmPasswordController,
              obscureText: controller.obscureConfirmPassword.value,
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
              decoration: _fieldDecoration.copyWith(
                labelText: 'Xác nhận mật khẩu',
                suffixIcon: IconButton(
                  onPressed: controller.toggleObscureConfirmPassword,
                  icon: Icon(
                    controller.obscureConfirmPassword.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  tooltip: controller.obscureConfirmPassword.value
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
            final isLoading = auth.isRegistering.value;
            return FilledButton(
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
                  : const Text('Đăng ký'),
            );
          }),
          TextButton(
            onPressed: () => Get.offAllNamed(AppRoutes.login),
            child: const Text('Đã có tài khoản? Đăng nhập'),
          ),
        ],
      ),
    );
  }
}
