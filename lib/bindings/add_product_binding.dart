import 'package:get/get.dart';

import '../products/presentation/controllers/add_product_controller.dart';
import '../products/presentation/controllers/products_controller.dart';

class AddProductBinding extends Bindings {
  @override
  void dependencies() {
    final productsController = Get.find<ProductsController>();
    Get.put(AddProductController(productsController: productsController));
  }
}
