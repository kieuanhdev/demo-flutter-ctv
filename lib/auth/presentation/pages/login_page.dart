import 'package:demo/core/theme/theme.dart';
import 'package:flutter/material.dart';

import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng nhập'),
        actions: const [ThemeModeMenuButton()],
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: LoginForm(),
        ),
      ),
    );
  }
}
