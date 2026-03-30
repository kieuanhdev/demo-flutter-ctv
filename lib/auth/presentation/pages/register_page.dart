import 'package:demo/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/register_form.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: const [ThemeModeMenuButton()],
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: RegisterForm(),
        ),
      ),
    );
  }
}
