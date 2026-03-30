import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../controllers/cart_fly_target_controller.dart';

class CartIconButton extends StatelessWidget {
  const CartIconButton({
    super.key,
    required this.onPressed,
    this.attachFlyTarget = true,
  });

  final VoidCallback onPressed;

  /// Chỉ một icon giỏ trong cây widget được gắn [GlobalKey] làm điểm đến bay.
  /// Màn khác (ví dụ chi tiết) đặt `false` để tránh lỗi trùng key.
  final bool attachFlyTarget;

  @override
  Widget build(BuildContext context) {
    final fly = Get.isRegistered<CartFlyTargetController>()
        ? Get.find<CartFlyTargetController>()
        : null;

    return GetX<CartController>(
      builder: (cart) {
        final stack = Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Giỏ hàng',
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: onPressed,
            ),
            if (cart.totalQuantity > 0)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '${cart.totalQuantity}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );

        if (fly == null || !attachFlyTarget) return stack;
        return KeyedSubtree(key: fly.cartIconKey, child: stack);
      },
    );
  }
}
