import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Giữ [GlobalKey] gắn icon giỏ trên AppBar để overlay bay tới đúng vị trí.
class CartFlyTargetController extends GetxController {
  final GlobalKey cartIconKey = GlobalKey(debugLabel: 'cartFlyTarget');
}
