import 'package:get/get.dart';

import '../../../app_routes.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../core/error/app_error_mapper.dart';
import '../../../core/logger/app_logger.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/usecases/load_session_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';

final _log = AppLogger.get('AuthController');

class AuthController extends GetxController {
  final SignInUsecase signInUsecase;
  final RegisterUsecase registerUsecase;
  final SignOutUsecase signOutUsecase;
  final LoadSessionUsecase loadSessionUsecase;

  AuthController({
    required this.signInUsecase,
    required this.registerUsecase,
    required this.signOutUsecase,
    required this.loadSessionUsecase,
  });

  final Rxn<AuthSession> session = Rxn<AuthSession>();
  final RxBool isSigningIn = false.obs;
  final RxBool isRegistering = false.obs;
  final RxBool isSigningOut = false.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    _onAppStarted();
  }

  Future<void> _onAppStarted() async {
    _log.i('App started — loading saved session...');

    try {
      final loaded = await loadSessionUsecase();
      if (loaded != null) {
        session.value = loaded;
        _log.i('Session restored for user: ${loaded.profile.username}');
      } else {
        _log.i('No saved session found');
      }
    } catch (e, st) {
      session.value = null;
      _log.e('Failed to load session', error: e, stackTrace: st);
    }

    if (session.value != null) {
      Get.offAllNamed(AppRoutes.products);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    _log.i('Sign in attempt — user: $username');
    isSigningIn.value = true;
    error.value = null;

    try {
      session.value = await signInUsecase(
        username: username,
        password: password,
      );
      _log.i('Sign in success — user: ${session.value?.profile.username}');
      Get.offAllNamed(AppRoutes.products);
    } catch (e, st) {
      error.value = AppErrorMapper.message(e);
      _log.e('Sign in failed', error: e, stackTrace: st);
    } finally {
      isSigningIn.value = false;
    }
  }

  Future<void> signOut() async {
    _log.i('Signing out...');
    isSigningOut.value = true;
    error.value = null;

    try {
      await signOutUsecase();

      if (Get.isRegistered<CartController>()) {
        await Get.find<CartController>().clear();
      }

      session.value = null;
      _log.i('Sign out complete — session cleared');
      Get.offAllNamed(AppRoutes.login);
    } catch (e, st) {
      error.value = AppErrorMapper.message(e);
      _log.e('Sign out failed', error: e, stackTrace: st);
    } finally {
      isSigningOut.value = false;
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _log.i('Register attempt — user: $username');
    isRegistering.value = true;
    error.value = null;

    try {
      await registerUsecase(
        username: username,
        email: email,
        password: password,
      );
      _log.i('Register success — user: $username');
      Get.snackbar('Success', 'Register successful. Please login.');
      Get.offAllNamed(AppRoutes.login);
    } catch (e, st) {
      error.value = AppErrorMapper.message(e);
      _log.e('Register failed', error: e, stackTrace: st);
    } finally {
      isRegistering.value = false;
    }
  }

}
