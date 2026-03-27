import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/edit_product_controller.dart';
import '../widgets/product_form.dart';

class EditProductPage extends GetView<EditProductController> {
  const EditProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: SafeArea(
        child: ProductForm(
          formKey: c.formKey,
          form: c.form,
          isSubmitting: c.productsController.isUpdating,
          onSubmit: c.submit,
          submitLabel: 'Save',
          submitIcon: Icons.save,
          fieldKeyPrefix: 'edit_${c.product.id}',
        ),
      ),
    );
  }
}
