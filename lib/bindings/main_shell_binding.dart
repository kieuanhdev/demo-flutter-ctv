import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../auth/presentation/controllers/auth_controller.dart';
import '../cart/data/datasources/local/cart_hive_store.dart';
import '../cart/data/datasources/remote/cart_remote_data_source.dart';
import '../cart/data/repositories/cart_repository_impl.dart';
import '../cart/domain/usecases/clear_cart_usecase.dart';
import '../cart/domain/usecases/load_cart_usecase.dart';
import '../cart/domain/usecases/save_cart_usecase.dart';
import '../cart/presentation/controllers/cart_controller.dart';
import '../core/logger/app_logger.dart';
import '../core/navigation/main_nav_controller.dart';
import '../products/data/datasources/remote/products_remote_data_source.dart';
import '../products/data/repositories/products_repository_impl.dart';
import '../products/domain/usecases/add_product_usecase.dart';
import '../products/domain/usecases/delete_product_usecase.dart';
import '../products/domain/usecases/fetch_products_usecase.dart';
import '../products/domain/usecases/search_products_usecase.dart';
import '../products/domain/usecases/update_product_usecase.dart';
import '../products/presentation/controllers/products_controller.dart';

/// Shell sản phẩm + giỏ ([MainShellPage]).
class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    final log = AppLogger.get('MainShellBinding');
    log.i('Products + Cart + Nav…');

    final dio = Get.find<Dio>();
    final authController = Get.find<AuthController>();

    final productsRepository = ProductsRepositoryImpl(
      ProductsRemoteDataSource(dio),
    );

    if (!Get.isRegistered<ProductsController>()) {
      Get.put<ProductsController>(
        ProductsController(
          authController: authController,
          fetchProductsUsecase: FetchProductsUsecase(productsRepository),
          searchProductsUsecase: SearchProductsUsecase(productsRepository),
          addProductUsecase: AddProductUsecase(productsRepository),
          updateProductUsecase: UpdateProductUsecase(productsRepository),
          deleteProductUsecase: DeleteProductUsecase(productsRepository),
        ),
        permanent: true,
      );
    }

    final cartRepository = CartRepositoryImpl(
      localStore: CartHiveStore(),
      remoteDataSource: CartRemoteDataSource(dio),
    );

    if (!Get.isRegistered<CartController>()) {
      Get.put<CartController>(
        CartController(
          authController: authController,
          loadCartUsecase: LoadCartUsecase(cartRepository),
          saveCartUsecase: SaveCartUsecase(cartRepository),
          clearCartUsecase: ClearCartUsecase(cartRepository),
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<MainNavController>()) {
      Get.put<MainNavController>(MainNavController(), permanent: true);
    }

    log.i('MainShellBinding ready');
  }
}
