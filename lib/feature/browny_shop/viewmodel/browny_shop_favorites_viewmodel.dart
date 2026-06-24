import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/products_response.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:browny_applications_new/feature/browny_shop/viewmodel/browny_shop_favorite_mixin.dart';
import 'package:flutter/foundation.dart';

/// ViewModel หน้า [BrownyShopFavoritesPage] — รายการสินค้าโปรดของลูกค้า
///
/// - fetch รายการสินค้าโปรดจาก [BrownyShopDataSourceMixin.fetchFavorites]
/// - toggle สินค้าโปรด ([BrownyShopFavoriteMixin]) บน list ที่กำลังแสดง
class BrownyShopFavoritesViewmodel extends AppViewModel
    with BrownyShopFavoriteMixin {
  BrownyShopFavoritesViewmodel({
    required super.context,
    required BrownyShopDataSourceMixin repo,
  }) : _repo = repo;

  final BrownyShopDataSourceMixin _repo;

  @override
  BrownyShopDataSourceMixin get favoriteRepo => _repo;

  @override
  ValueNotifier<UiResult<List<ProductData>>> get favoriteProductsNotifier =>
      _favoritesNotifier;

  @override
  void dispose() {
    _favoritesNotifier.dispose();
    super.dispose();
  }

  /// รายการสินค้าโปรด
  final ValueNotifier<UiResult<List<ProductData>>> _favoritesNotifier =
      ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<List<ProductData>>> get favoritesNotifier =>
      _favoritesNotifier;

  /// ดึงรายการสินค้าโปรดของลูกค้าจาก API
  Future<void> fetchFavorites() async {
    _favoritesNotifier.value = UiResult.loading();

    final result = await _repo.fetchFavorites(
      customerId: currentCustomerProvider.current.id.orEmpty,
    );

    if (result.hasError) {
      _favoritesNotifier.value = UiResult.error(error: result.error);
      return;
    }
    if (result.isEmpty) {
      _favoritesNotifier.value = UiResult.empty();
      return;
    }
    final items = result.data;
    if (items.isEmpty) {
      _favoritesNotifier.value = UiResult.empty();
      return;
    }
    _favoritesNotifier.value = UiResult.success(data: items);
  }
}
