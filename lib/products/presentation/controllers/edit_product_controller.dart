import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/logger/app_logger.dart';
import '../../domain/entities/product.dart';
import '../widgets/product_form.dart';
import 'products_controller.dart';

final _log = AppLogger.get('EditProductController');

class EditProductController extends GetxController {
  EditProductController({
    required this.productsController,
    required this.product,
  });

  final ProductsController productsController;
  final Product product;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final ProductFormController form = ProductFormController(
    initialTitle: product.title,
    initialPrice: product.price,
    initialCategory: product.category ?? '',
    initialThumbnail: product.thumbnail ?? '',
  );

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final price = form.parsePrice();
    if (price == null) return;

    final updated = await productsController.updateProduct(
      id: product.id,
      title: form.title,
      price: price,
      category: form.category,
      thumbnail: form.thumbnail,
    );

    if (updated != null) {
      Get.back(result: updated);
      Get.snackbar('Success', 'Updated: ${updated.title}');
    } else {
      _log.e('Edit failed: ${productsController.error.value}');
      Get.snackbar('Error', productsController.error.value ?? 'Update failed');
    }
  }

  @override
  void onClose() {
    form.dispose();
    super.onClose();
  }
}
