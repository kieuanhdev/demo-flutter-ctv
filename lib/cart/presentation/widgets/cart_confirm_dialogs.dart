import 'package:flutter/material.dart';

/// Xác nhận xóa một sản phẩm khỏi giỏ (khi giảm số lượng về 0).
Future<bool> confirmRemoveCartLine(
  BuildContext context, {
  required String productTitle,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Xóa sản phẩm'),
      content: Text(
        'Bạn có chắc chắn muốn xóa "$productTitle" khỏi giỏ hàng?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Xóa'),
        ),
      ],
    ),
  );
  return result == true;
}

/// Xác nhận xóa toàn bộ giỏ hàng.
Future<bool> confirmClearEntireCart(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Xóa giỏ hàng'),
      content: const Text(
        'Bạn có chắc chắn muốn xóa tất cả sản phẩm khỏi giỏ hàng?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Xóa tất cả'),
        ),
      ],
    ),
  );
  return result == true;
}
