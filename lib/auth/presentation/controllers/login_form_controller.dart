import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LoginFormController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
