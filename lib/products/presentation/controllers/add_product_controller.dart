import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/logger/app_logger.dart';
import '../widgets/product_form.dart';
import 'products_controller.dart';

final _log = AppLogger.get('AddProductController');

class AddProductController extends GetxController {
  AddProductController({required this.productsController});

  final ProductsController productsController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ProductFormController form = ProductFormController();

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final price = form.parsePrice();
    if (price == null) return;

    final created = await productsController.addProduct(
      title: form.title,
      price: price,
      category: form.category,
      thumbnail: form.thumbnail,
    );

    if (created != null) {
      Get.back(result: created);
      Get.snackbar('Thành công', 'Đã thêm: ${created.title}');
    } else {
      _log.e('Add product failed: ${productsController.error.value}');
      Get.snackbar(
        'Lỗi',
        productsController.error.value ?? 'Không thể thêm sản phẩm',
      );
    }
  }

  @override
  void onClose() {
    form.dispose();
    super.onClose();
  }
}
