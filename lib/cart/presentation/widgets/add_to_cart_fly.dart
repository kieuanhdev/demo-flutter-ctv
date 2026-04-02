import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../products/domain/entities/product.dart';
import '../controllers/cart_controller.dart';

/// Mở modal chọn số lượng, rồi thêm vào giỏ.
Future<void> addProductWithFlyToCart({
  required BuildContext context,
  required Product product,
  Rect? startRect,
}) async {
  final selectedQuantity = await _showAddToCartQuantitySheet(
    context: context,
    product: product,
  );
  if (selectedQuantity == null || selectedQuantity <= 0) return;

  final cart = Get.find<CartController>();
  await cart.add(product, quantity: selectedQuantity);
  if (!context.mounted) return;

  if (context.mounted) {
    Get.closeAllSnackbars();
    final bottomPad =
        MediaQuery.paddingOf(context).bottom + kBottomNavigationBarHeight + 8;
    Get.snackbar(
      'Đã thêm vào giỏ',
      '${product.title} x$selectedQuantity',
      duration: const Duration(milliseconds: 1600),
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.fromLTRB(12, 0, 12, bottomPad),
    );
  }
}

Future<int?> _showAddToCartQuantitySheet({
  required BuildContext context,
  required Product product,
}) {
  int quantity = 1;
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Chọn số lượng',
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(ctx).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        onPressed: quantity > 1
                            ? () => setSheetState(() => quantity -= 1)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        '$quantity',
                        style: Theme.of(ctx).textTheme.headlineSmall,
                      ),
                      const SizedBox(width: 20),
                      IconButton.filledTonal(
                        onPressed: () => setSheetState(() => quantity += 1),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(quantity),
                    child: const Text('Thêm vào giỏ'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
