import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/add_product_controller.dart';
import '../widgets/product_form.dart';

class AddProductPage extends GetView<AddProductController> {
  const AddProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm sản phẩm')),
      body: SafeArea(
        child: ProductForm(
          formKey: c.formKey,
          form: c.form,
          isSubmitting: c.productsController.isAdding,
          onSubmit: c.submit,
          submitLabel: 'Thêm',
          submitIcon: Icons.add,
          fieldKeyPrefix: 'add',
        ),
      ),
    );
  }
}
