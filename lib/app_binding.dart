import 'package:demo/products/presentation/controllers/products_controller.dart'
    show ProductsController;
import 'package:dio/dio.dart';
import 'package:dio_log/interceptor/dio_log_interceptor.dart';
import 'package:get/get.dart';

import 'auth/data/datasources/local/auth_session_hive_store.dart';
import 'auth/data/datasources/remote/auth_remote_data_source.dart';
import 'auth/data/repositories/auth_repository_impl.dart';
import 'auth/domain/usecases/load_session_usecase.dart';
import 'auth/domain/usecases/register_usecase.dart';
import 'auth/domain/usecases/sign_in_usecase.dart';
import 'auth/domain/usecases/sign_out_usecase.dart';
import 'auth/presentation/controllers/auth_controller.dart';
import 'cart/data/datasources/local/cart_hive_store.dart';
import 'cart/data/datasources/remote/cart_remote_data_source.dart';
import 'cart/data/repositories/cart_repository_impl.dart';
import 'cart/domain/usecases/clear_cart_usecase.dart';
import 'cart/domain/usecases/load_cart_usecase.dart';
import 'cart/domain/usecases/save_cart_usecase.dart';
import 'cart/presentation/controllers/cart_controller.dart';
import 'core/config/api_config.dart';
import 'core/logger/app_logger.dart';
import 'products/data/datasources/remote/products_remote_data_source.dart';
import 'products/data/repositories/products_repository_impl.dart';
import 'products/domain/usecases/add_product_usecase.dart';
import 'products/domain/usecases/delete_product_usecase.dart';
import 'products/domain/usecases/fetch_products_usecase.dart';
import 'products/domain/usecases/search_products_usecase.dart';
import 'products/domain/usecases/update_product_usecase.dart';

class AppBinding extends Bindings {
  static const int _maxRetryCount = 2;

  bool _shouldRetry(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      default:
        return false;
    }
  }

  Duration _retryDelay(int retryCount) {
    // exponential backoff: 400ms, 800ms, ...
    return Duration(milliseconds: 400 * (1 << retryCount));
  }

  @override
  void dependencies() {
    final log = AppLogger.get('AppBinding');
    log.i('Initializing dependencies...');

    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    Get.put<Dio>(dio, permanent: true);
    var handlingUnauthorized = false;
    log.i('API base URL: ${ApiConfig.baseUrl}');

    // ── Auth ──────────────────────────────────────────────────────────

    final authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSource(dio),
      localStore: AuthSessionHiveStore(),
    );

    final authController = AuthController(
      signInUsecase: SignInUsecase(authRepository),
      registerUsecase: RegisterUsecase(authRepository),
      signOutUsecase: SignOutUsecase(authRepository),
      loadSessionUsecase: LoadSessionUsecase(authRepository),
    );
    Get.put<AuthController>(authController, permanent: true);

    // Auth token injection
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final isAuthEndpoint = options.path.startsWith('/auth/');
          if (!isAuthEndpoint) {
            final accessToken = authController.session.value?.accessToken;
            if (accessToken != null && accessToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $accessToken';
            }
          }
          handler.next(options);
        },
        onError: (err, handler) async {
          final requestOptions = err.requestOptions;
          final retryCount = (requestOptions.extra['_retryCount'] as int?) ?? 0;
          final canRetry = _shouldRetry(err) && retryCount < _maxRetryCount;

          if (canRetry) {
            final delay = _retryDelay(retryCount);
            log.w(
              'Request failed, retrying (${retryCount + 1}/$_maxRetryCount) '
              '${requestOptions.method} ${requestOptions.path} in '
              '${delay.inMilliseconds}ms: ${err.message}',
            );
            await Future<void>.delayed(delay);
            try {
              final retryOptions = requestOptions.copyWith(
                extra: <String, dynamic>{
                  ...requestOptions.extra,
                  '_retryCount': retryCount + 1,
                },
              );
              final response = await dio.fetch<dynamic>(retryOptions);
              handler.resolve(response);
              return;
            } catch (_) {
              // Continue to next handling branch.
            }
          }

          final statusCode = err.response?.statusCode;
          final isAuthEndpoint = requestOptions.path.startsWith('/auth/');

          if (statusCode == 401 && !isAuthEndpoint && !handlingUnauthorized) {
            handlingUnauthorized = true;
            try {
              await authController.signOut();
            } finally {
              handlingUnauthorized = false;
            }
          }

          handler.next(err);
        },
      ),
    );

    dio.interceptors.add(DioLogInterceptor());

    log.i('Auth layer initialized');

    // ── Products ──────────────────────────────────────────────────────

    final productsRepository = ProductsRepositoryImpl(
      ProductsRemoteDataSource(dio),
    );
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
    log.i('Products layer initialized');

    // ── Cart ──────────────────────────────────────────────────────────

    final cartRepository = CartRepositoryImpl(
      localStore: CartHiveStore(),
      remoteDataSource: CartRemoteDataSource(dio),
    );
    Get.put<CartController>(
      CartController(
        authController: authController,
        loadCartUsecase: LoadCartUsecase(cartRepository),
        saveCartUsecase: SaveCartUsecase(cartRepository),
        clearCartUsecase: ClearCartUsecase(cartRepository),
      ),
      permanent: true,
    );
    log.i('Cart layer initialized');
    log.i('All dependencies ready ✓');
  }
}
