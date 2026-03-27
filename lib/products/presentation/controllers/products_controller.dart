import 'package:flutter/widgets.dart';
import '/auth/domain/entities/auth_session.dart';
import '/auth/presentation/controllers/auth_controller.dart';
import '/core/error/app_error_mapper.dart';
import '/core/logger/app_logger.dart';
import '/products/domain/entities/product.dart';
import '/products/domain/entities/products_page.dart';
import '/products/domain/usecases/add_product_usecase.dart';
import '/products/domain/usecases/fetch_products_usecase.dart';
import '/products/domain/usecases/delete_product_usecase.dart';
import '/products/domain/usecases/search_products_usecase.dart';
import '/products/domain/usecases/update_product_usecase.dart';
import 'package:get/get.dart';

final _log = AppLogger.get('ProductsController');

class ProductsController extends GetxController {
  final AuthController authController;
  final FetchProductsUsecase fetchProductsUsecase;
  final SearchProductsUsecase searchProductsUsecase;
  final AddProductUsecase addProductUsecase;
  final UpdateProductUsecase updateProductUsecase;
  final DeleteProductUsecase deleteProductUsecase;

  static const int pageSize = 10;

  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isAdding = false.obs;
  final RxBool isUpdating = false.obs;
  final RxSet<int> deletingIds = <int>{}.obs;
  final RxBool hasMore = true.obs;
  final RxnString error = RxnString();

  int _skip = 0;
  int _total = 0;
  String? _activeQuery;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchTextController = TextEditingController();

  ProductsController({
    required this.authController,
    required this.fetchProductsUsecase,
    required this.searchProductsUsecase,
    required this.addProductUsecase,
    required this.updateProductUsecase,
    required this.deleteProductUsecase,
  });

  int? _lastUserId;

  @override
  void onInit() {
    super.onInit();
    _log.i('onInit — listening to auth session changes');

    _lastUserId = authController.session.value?.profile.id;
    if (_lastUserId != null) {
      refreshProducts();
    }

    ever<AuthSession?>(authController.session, (session) async {
      final newUserId = session?.profile.id;
      if (newUserId == _lastUserId) {
        _log.d('Session updated (token refresh) — skipping products reload');
        return;
      }
      _lastUserId = newUserId;

      if (session == null) {
        _log.i('Auth session cleared — resetting products state');
        _resetState();
        return;
      }
      _log.i('New user logged in — refreshing products');
      await refreshProducts();
    });

    debounce<String>(
      searchQuery,
      (_) => refreshProducts(),
      time: const Duration(milliseconds: 450),
    );
  }

  void _resetState() {
    products.clear();
    _skip = 0;
    _total = 0;
    hasMore.value = true;
    isLoading.value = false;
    isLoadingMore.value = false;
    error.value = null;
  }

  Future<void> refreshProducts() async {
    if (isLoading.value) return;

    _log.i('Refreshing products... (query: ${_activeQuery ?? 'none'})');
    isLoading.value = true;
    error.value = null;
    _skip = 0;
    hasMore.value = true;
    products.clear();

    try {
      final page = await _fetch(skip: _skip);
      products.assignAll(page.products);
      _total = page.total;
      _skip = page.skip + page.products.length;
      hasMore.value = products.length < _total;
    } catch (e, st) {
      error.value = AppErrorMapper.message(e);
      _log.e('refreshProducts failed', error: e, stackTrace: st);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value) return;
    if (isLoadingMore.value || isLoading.value) return;

    isLoadingMore.value = true;
    error.value = null;

    try {
      final page = await _fetch(skip: _skip);
      products.addAll(page.products);
      _total = page.total;
      _skip = page.skip + page.products.length;
      hasMore.value = products.length < _total;
    } catch (e, st) {
      error.value = AppErrorMapper.message(e);
      _log.e('loadMore failed', error: e, stackTrace: st);
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<ProductsPage> _fetch({required int skip}) {
    final q = _activeQuery;
    if (q == null || q.isEmpty) {
      return fetchProductsUsecase(skip: skip, limit: pageSize);
    }
    return searchProductsUsecase(q: q, skip: skip, limit: pageSize);
  }

  void onSearchChanged(String query) {
    _activeQuery = query.trim().isEmpty ? null : query.trim();
    searchQuery.value = query;
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  Future<Product?> addProduct({
    required String title,
    required double price,
    String? category,
    String? thumbnail,
  }) async {
    if (isAdding.value) return null;
    isAdding.value = true;
    error.value = null;

    try {
      final created = await addProductUsecase(
        title: title,
        price: price,
        category: category,
        thumbnail: thumbnail,
      );
      products.insert(0, created);
      _total += 1;
      hasMore.value = products.length < _total;
      return created;
    } catch (e, st) {
      error.value = AppErrorMapper.message(e);
      _log.e('addProduct failed', error: e, stackTrace: st);
      return null;
    } finally {
      isAdding.value = false;
    }
  }

  Future<Product?> updateProduct({
    required int id,
    required String title,
    required double price,
    String? category,
    String? thumbnail,
  }) async {
    if (isUpdating.value) return null;
    isUpdating.value = true;
    error.value = null;

    try {
      final updated = await updateProductUsecase(
        id: id,
        title: title,
        price: price,
        category: category,
        thumbnail: thumbnail,
      );

      final idx = products.indexWhere((p) => p.id == id);
      if (idx >= 0) {
        products[idx] = updated;
        products.refresh();
      }
      return updated;
    } catch (e, st) {
      error.value = AppErrorMapper.message(e);
      _log.e('updateProduct failed', error: e, stackTrace: st);
      return null;
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> deleteProduct({required int id}) async {
    if (deletingIds.contains(id)) return;
    deletingIds.add(id);
    error.value = null;

    try {
      await deleteProductUsecase(id: id);
      final idx = products.indexWhere((p) => p.id == id);
      if (idx >= 0) {
        products.removeAt(idx);
        if (_total > 0) _total -= 1;
        hasMore.value = products.length < _total;
      }
    } catch (e, st) {
      error.value = AppErrorMapper.message(e);
      _log.e('deleteProduct failed', error: e, stackTrace: st);
    } finally {
      deletingIds.remove(id);
    }
  }
}
