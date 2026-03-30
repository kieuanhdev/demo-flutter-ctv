import 'package:get/get.dart';

import '../products/domain/entities/product.dart';
import '../products/presentation/controllers/edit_product_controller.dart';
import '../products/presentation/controllers/products_controller.dart';

class EditProductBinding extends Bindings {
  @override
  void dependencies() {
    final productsController = Get.find<ProductsController>();
    final product = Get.arguments as Product;
    Get.put(
      EditProductController(
        productsController: productsController,
        product: product,
      ),
    );
  }
}
