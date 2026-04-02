import 'package:get/get.dart';

class MainNavController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void goToProducts() => currentIndex.value = 0;

  void goToCart() => currentIndex.value = 1;

  void goToProfile() => currentIndex.value = 2;
}
