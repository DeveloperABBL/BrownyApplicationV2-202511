import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/products_response.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:flutter/foundation.dart';

/// ViewModel หลักของหน้า BrownyShopPage
///
/// รับผิดชอบ:
/// - state ของ category ที่เลือก
/// - fetch รายการสินค้าตาม category
/// - (อนาคต) flash deals, banners ฯลฯ
class BrownyShopPageViewmodel extends AppViewModel {
  BrownyShopPageViewmodel({
    required super.context,
    required BrownyShopDataSourceMixin repo,
  }) : _repo = repo;

  final BrownyShopDataSourceMixin _repo;

  @override
  void dispose() {
    _productsNotifier.dispose();
    _selectedCategoryNotifier.dispose();
    super.dispose();
  }

  /// รายการสินค้าใน Browny Shop
  final ValueNotifier<UiResult<List<ProductData>>> _productsNotifier =
      ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<List<ProductData>>> get productsNotifier =>
      _productsNotifier;

  /// Category ที่ user เลือก (default = "all")
  final ValueNotifier<String> _selectedCategoryNotifier = ValueNotifier('all');
  ValueListenable<String> get selectedCategoryNotifier =>
      _selectedCategoryNotifier;

  /// ถูกเรียกเมื่อ user กดเลือก chip
  Future<void> onCategorySelected(String category) async {
    if (_selectedCategoryNotifier.value == category) return;
    _selectedCategoryNotifier.value = category;
    await fetchProducts(productType: category);
  }

  /// ดึงรายการสินค้าจาก API
  Future<void> fetchProducts({String productType = 'all'}) async {
    _productsNotifier.value = UiResult.loading();

    final customerId = currentCustomerProvider.current.id.orEmpty;
    final result = await _repo.fetchProducts(
      productType: productType,
      customerId: customerId,
    );

    if (result.hasError) {
      _productsNotifier.value = UiResult.error(error: result.error);
      return;
    }
    if (result.isEmpty) {
      _productsNotifier.value = UiResult.empty();
      return;
    }
    final products = result.data.product ?? <ProductData>[];
    if (products.isEmpty) {
      _productsNotifier.value = UiResult.empty();
      return;
    }
    _productsNotifier.value = UiResult.success(data: products);
  }
}
