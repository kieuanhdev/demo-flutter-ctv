import 'package:flutter/material.dart';

/// Màu bổ sung ngoài [ColorScheme] — dùng cho nút giỏ, placeholder ảnh, v.v.
@immutable
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  const AppCustomColors({
    required this.addToCartButton,
    required this.cartQuantityBadge,
    required this.imagePlaceholder,
  });

  final Color addToCartButton;
  final Color cartQuantityBadge;
  final Color imagePlaceholder;

  @override
  AppCustomColors copyWith({
    Color? addToCartButton,
    Color? cartQuantityBadge,
    Color? imagePlaceholder,
  }) {
    return AppCustomColors(
      addToCartButton: addToCartButton ?? this.addToCartButton,
      cartQuantityBadge: cartQuantityBadge ?? this.cartQuantityBadge,
      imagePlaceholder: imagePlaceholder ?? this.imagePlaceholder,
    );
  }

  @override
  AppCustomColors lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) return this;
    return AppCustomColors(
      addToCartButton: Color.lerp(addToCartButton, other.addToCartButton, t)!,
      cartQuantityBadge: Color.lerp(
        cartQuantityBadge,
        other.cartQuantityBadge,
        t,
      )!,
      imagePlaceholder: Color.lerp(
        imagePlaceholder,
        other.imagePlaceholder,
        t,
      )!,
    );
  }
}

extension AppCustomColorsContext on BuildContext {
  AppCustomColors get appCustomColors =>
      Theme.of(this).extension<AppCustomColors>()!;
}
