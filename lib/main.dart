import 'package:demo/core/logger/app_logger.dart';
import 'package:demo/hive_encryption.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app_binding.dart';
import 'app_routes.dart';
import 'auth/data/datasources/local/auth_session_hive_store.dart';
import 'cart/data/datasources/local/cart_hive_store.dart';

final _log = AppLogger.get('Main');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _log.i('App launching...');

  _log.d('Initializing Hive...');
  await Hive.initFlutter();
  final cipher = await HiveEncryption.buildCipher();
  await HiveEncryption.openEncryptedStringBox(
    AuthSessionHiveStore.boxName,
    cipher: cipher,
  );
  await HiveEncryption.openEncryptedStringBox(
    CartHiveStore.boxName,
    cipher: cipher,
  );
  _log.i(
    'Hive initialized with encrypted boxes: '
    '[${AuthSessionHiveStore.boxName}, ${CartHiveStore.boxName}]',
  );

  _log.i('Starting app...');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: AppBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
