import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/product.dart';
import '../controllers/products_controller.dart';

class ProductActionButtons extends GetView<ProductsController> {
  const ProductActionButtons({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDeleted,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDeleted;

  Future<void> _confirmAndDelete(BuildContext context) async {
    final scheme = Theme.of(context).colorScheme;
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: Text('Bạn có chắc muốn xóa "${product.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Xóa',
              style: TextStyle(color: scheme.error),
            ),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await controller.deleteProduct(id: product.id);
    if (controller.error.value != null) {
      Get.snackbar('Lỗi', controller.error.value!);
      return;
    }
    onDeleted();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit),
            label: const Text('Sửa'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() {
            final isDeleting = controller.deletingIds.contains(product.id);
            return OutlinedButton.icon(
              onPressed: isDeleting ? null : () => _confirmAndDelete(context),
              icon: const Icon(Icons.delete_outline),
              label: Text(isDeleting ? 'Đang xóa...' : 'Xóa'),
            );
          }),
        ),
      ],
    );
  }
}
