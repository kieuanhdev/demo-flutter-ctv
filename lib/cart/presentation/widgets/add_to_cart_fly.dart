import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../products/domain/entities/product.dart';
import '../controllers/cart_controller.dart';
import '../controllers/cart_fly_target_controller.dart';

/// Lấy [Rect] global của widget gắn với [context] (ví dụ nút hoặc ảnh).
Rect? globalBoundsOf(BuildContext? context) {
  if (context == null) return null;
  final ro = context.findRenderObject();
  if (ro is! RenderBox || !ro.hasSize) return null;
  return ro.localToGlobal(Offset.zero) & ro.size;
}

/// Thêm vào giỏ rồi chạy animation thumbnail thu nhỏ bay vào icon giỏ.
Future<void> addProductWithFlyToCart({
  required BuildContext context,
  required Product product,
  Rect? startRect,
}) async {
  final cart = Get.find<CartController>();
  await cart.add(product);
  if (!context.mounted) return;

  await _playFlyAnimation(
    context: context,
    product: product,
    startRect: startRect,
  );

  if (context.mounted) {
    // Một snackbar tại một thời điểm — thêm liên tục chỉ giữ bản mới nhất.
    Get.closeAllSnackbars();
    final bottomPad =
        MediaQuery.paddingOf(context).bottom + kBottomNavigationBarHeight + 8;
    Get.snackbar(
      'Đã thêm vào giỏ',
      product.title,
      duration: const Duration(milliseconds: 1600),
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.fromLTRB(12, 0, 12, bottomPad),
    );
  }
}

Future<void> _playFlyAnimation({
  required BuildContext context,
  required Product product,
  Rect? startRect,
}) async {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  final media = MediaQuery.of(context);
  final targetCtrl = Get.find<CartFlyTargetController>();
  final endBox =
      targetCtrl.cartIconKey.currentContext?.findRenderObject() as RenderBox?;
  late final Rect endRect;
  if (endBox != null && endBox.hasSize) {
    endRect = endBox.localToGlobal(Offset.zero) & endBox.size;
  } else {
    endRect = Rect.fromCircle(
      center: Offset(
        media.size.width - 28,
        media.padding.top + kToolbarHeight / 2,
      ),
      radius: 22,
    );
  }

  final start = startRect;
  if (start == null) return;

  final completer = Completer<void>();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Material(
      type: MaterialType.transparency,
      child: _FlyingProductToCart(
        product: product,
        startRect: start,
        endRect: endRect,
        onComplete: () {
          entry.remove();
          if (!completer.isCompleted) completer.complete();
        },
      ),
    ),
  );
  overlay.insert(entry);
  return completer.future;
}

class _FlyingProductToCart extends StatefulWidget {
  const _FlyingProductToCart({
    required this.product,
    required this.startRect,
    required this.endRect,
    required this.onComplete,
  });

  final Product product;
  final Rect startRect;
  final Rect endRect;
  final VoidCallback onComplete;

  @override
  State<_FlyingProductToCart> createState() => _FlyingProductToCartState();
}

class _FlyingProductToCartState extends State<_FlyingProductToCart>
    with SingleTickerProviderStateMixin {
  static const double _flySize = 52;

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: Curves.easeInOutCubic,
  );

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _t,
          builder: (_, _) {
            final v = _t.value;
            final begin = widget.startRect.center;
            final end = widget.endRect.center;
            final straight = Offset.lerp(begin, end, v)!;
            final arcHeight = -68 * math.sin(math.pi * v);
            final pos = straight + Offset(0, arcHeight);
            final scale = lerpDouble(1, 0.12, Curves.easeIn.transform(v))!;
            final opacity = 1.0 - Curves.easeIn.transform(v) * 0.15;

            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  left: pos.dx - _flySize / 2,
                  top: pos.dy - _flySize / 2,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: scale,
                      child: SizedBox(
                        width: _flySize,
                        height: _flySize,
                        child: _thumb(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _thumb() {
    final url = widget.product.thumbnail;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: url != null && url.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, _) => ColoredBox(
                color: Colors.grey.shade300,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (_, _, _) => ColoredBox(
                color: Colors.grey.shade400,
                child: const Icon(Icons.inventory_2_outlined),
              ),
            )
          : ColoredBox(
              color: Colors.grey.shade400,
              child: const Icon(Icons.inventory_2_outlined),
            ),
    );
  }
}
