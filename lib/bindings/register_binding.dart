import 'package:get/get.dart';

import '../auth/presentation/controllers/register_form_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(RegisterFormController());
  }
}
