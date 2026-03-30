import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Quản lý [ThemeMode] (sáng / tối / theo hệ thống), lưu vào Hive.
class ThemeController extends GetxController {
  ThemeController();

  static const String _boxName = 'app_prefs';
  static const String _keyThemeMode = 'themeMode';

  late final Box<String> _prefs;
  late final Rx<ThemeMode> themeMode;

  @override
  void onInit() {
    super.onInit();
    _prefs = Hive.box<String>(_boxName);
    themeMode = _readSavedMode().obs;
  }

  ThemeMode _readSavedMode() {
    final raw = _prefs.get(_keyThemeMode);
    switch (raw) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _prefs.put(_keyThemeMode, mode.name);
  }
}
