import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'theme_controller.dart';

/// Nút chọn chế độ giao diện (Sáng / Tối / Theo hệ thống).
class ThemeModeMenuButton extends StatelessWidget {
  const ThemeModeMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ThemeController>();

    return Obx(() {
      final mode = controller.themeMode.value;
      final IconData icon;
      switch (mode) {
        case ThemeMode.dark:
          icon = Icons.dark_mode_outlined;
          break;
        case ThemeMode.light:
          icon = Icons.light_mode_outlined;
          break;
        case ThemeMode.system:
          icon = Icons.brightness_auto_outlined;
      }

      return PopupMenuButton<ThemeMode>(
        tooltip: 'Giao diện',
        icon: Icon(icon),
        initialValue: mode,
        onSelected: controller.setThemeMode,
        itemBuilder: (context) => [
          PopupMenuItem(
            value: ThemeMode.light,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.light_mode_outlined),
              title: const Text('Sáng'),
              selected: mode == ThemeMode.light,
            ),
          ),
          PopupMenuItem(
            value: ThemeMode.dark,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Tối'),
              selected: mode == ThemeMode.dark,
            ),
          ),
          PopupMenuItem(
            value: ThemeMode.system,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.brightness_auto_outlined),
              title: const Text('Theo hệ thống'),
              selected: mode == ThemeMode.system,
            ),
          ),
        ],
      );
    });
  }
}
