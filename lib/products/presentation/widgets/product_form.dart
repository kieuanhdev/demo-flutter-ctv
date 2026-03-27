import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductFormController {
  ProductFormController({
    String initialTitle = '',
    double? initialPrice,
    String initialCategory = '',
    String initialThumbnail = '',
  }) : titleController = TextEditingController(text: initialTitle),
       priceController = TextEditingController(
         text: initialPrice == null ? '' : initialPrice.toString(),
       ),
       categoryController = TextEditingController(text: initialCategory),
       thumbnailController = TextEditingController(text: initialThumbnail);

  final TextEditingController titleController;
  final TextEditingController priceController;
  final TextEditingController categoryController;
  final TextEditingController thumbnailController;

  String get title => titleController.text.trim();
  String get category => categoryController.text.trim();
  String get thumbnail => thumbnailController.text.trim();

  double? parsePrice() {
    final raw = priceController.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  void dispose() {
    titleController.dispose();
    priceController.dispose();
    categoryController.dispose();
    thumbnailController.dispose();
  }
}

class ProductForm extends StatelessWidget {
  const ProductForm({
    super.key,
    required this.formKey,
    required this.form,
    required this.isSubmitting,
    required this.onSubmit,
    required this.submitLabel,
    required this.submitIcon,
    this.fieldKeyPrefix,
  });

  final GlobalKey<FormState> formKey;
  final ProductFormController form;
  final RxBool isSubmitting;
  final Future<void> Function() onSubmit;
  final String submitLabel;
  final IconData submitIcon;
  final String? fieldKeyPrefix;

  @override
  Widget build(BuildContext context) {
    final prefix = fieldKeyPrefix;

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LabeledTextFormField(
            fieldKey: prefix == null ? null : ValueKey('${prefix}_title'),
            labelText: 'Title',
            controller: form.titleController,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Title is required' : null,
          ),
          const SizedBox(height: 12),
          LabeledTextFormField(
            fieldKey: prefix == null ? null : ValueKey('${prefix}_price'),
            labelText: 'Price',
            controller: form.priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            validator: (v) {
              final p = _tryParsePrice(v);
              if (p == null) return 'Price must be a number';
              if (p < 0) return 'Price must be >= 0';
              return null;
            },
          ),
          const SizedBox(height: 12),
          LabeledTextFormField(
            fieldKey: prefix == null ? null : ValueKey('${prefix}_category'),
            labelText: 'Category (optional)',
            controller: form.categoryController,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          LabeledTextFormField(
            fieldKey: prefix == null ? null : ValueKey('${prefix}_thumbnail'),
            labelText: 'Thumbnail URL (optional)',
            controller: form.thumbnailController,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16),
          Obx(() {
            final submitting = isSubmitting.value;
            return FilledButton.icon(
              onPressed: submitting ? null : onSubmit,
              icon: submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(submitIcon),
              label: Text(submitting ? 'Please wait...' : submitLabel),
            );
          }),
        ],
      ),
    );
  }

  double? _tryParsePrice(String? raw) {
    if (raw == null) return null;
    final normalized = raw.trim().replaceAll(',', '.');
    return double.tryParse(normalized);
  }
}

class LabeledTextFormField extends StatelessWidget {
  const LabeledTextFormField({
    super.key,
    required this.labelText,
    required this.controller,
    this.keyboardType,
    required this.textInputAction,
    this.validator,
    this.fieldKey,
  });

  final Key? fieldKey;
  final String labelText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}
