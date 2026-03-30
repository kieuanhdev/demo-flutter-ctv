import 'package:get/get.dart';

import '../auth/presentation/controllers/login_form_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LoginFormController());
  }
}
