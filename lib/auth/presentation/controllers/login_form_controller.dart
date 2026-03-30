import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LoginFormController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final obscurePassword = true.obs;

  void toggleObscurePassword() => obscurePassword.toggle();

  String? validateUsername(String? value) {
    final username = value?.trim() ?? '';
    if (username.isEmpty) {
      return 'Username is required';
    }
    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  bool validate() {
    final form = formKey.currentState;
    if (form == null) return false;
    return form.validate();
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
