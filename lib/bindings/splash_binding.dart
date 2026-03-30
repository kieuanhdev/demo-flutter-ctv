import 'package:dio/dio.dart';
import 'package:dio_log/interceptor/dio_log_interceptor.dart';
import 'package:get/get.dart';

import '../auth/data/datasources/local/auth_session_hive_store.dart';
import '../auth/data/datasources/remote/auth_remote_data_source.dart';
import '../auth/data/repositories/auth_repository_impl.dart';
import '../auth/domain/usecases/load_session_usecase.dart';
import '../auth/domain/usecases/register_usecase.dart';
import '../auth/domain/usecases/sign_in_usecase.dart';
import '../auth/domain/usecases/sign_out_usecase.dart';
import '../auth/presentation/controllers/auth_controller.dart';
import '../core/config/api_config.dart';
import '../core/logger/app_logger.dart';

/// Chạy lúc khởi động app: [Dio] + [AuthController] (bắt buộc trước mọi màn).
class SplashBinding extends Bindings {
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
    return Duration(milliseconds: 400 * (1 << retryCount));
  }

  @override
  void dependencies() {
    final log = AppLogger.get('SplashBinding');
    log.i('Dio + Auth…');

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
            } catch (_) {}
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
    log.i('SplashBinding ready');
  }
}
