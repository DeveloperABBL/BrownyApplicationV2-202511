import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/flash_sales_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/product_types_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/products_response.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:browny_applications_new/feature/browny_shop/viewmodel/browny_shop_favorite_mixin.dart';
import 'package:flutter/foundation.dart';

/// ViewModel หลักของหน้า BrownyShopPage
///
/// รับผิดชอบ:
/// - state ของ category ที่เลือก
/// - fetch รายการสินค้าตาม category
/// - toggle สินค้าโปรด ([BrownyShopFavoriteMixin])
/// - (อนาคต) flash deals, banners ฯลฯ
class BrownyShopPageViewmodel extends AppViewModel
    with BrownyShopFavoriteMixin {
  BrownyShopPageViewmodel({
    required super.context,
    required BrownyShopDataSourceMixin repo,
  }) : _repo = repo;

  final BrownyShopDataSourceMixin _repo;

  @override
  BrownyShopDataSourceMixin get favoriteRepo => _repo;

  @override
  ValueNotifier<UiResult<List<ProductData>>> get favoriteProductsNotifier =>
      _productsNotifier;

  @override
  void dispose() {
    _productsNotifier.dispose();
    _productTypesNotifier.dispose();
    _selectedCategoryNotifier.dispose();
    _flashSalesNotifier.dispose();
    super.dispose();
  }

  /// รายการประเภทสินค้า (chip filter)
  final ValueNotifier<UiResult<List<ProductTypeData>>> _productTypesNotifier =
      ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<List<ProductTypeData>>> get productTypesNotifier =>
      _productTypesNotifier;

  /// ดึงรายการประเภทสินค้าจาก API
  Future<void> fetchProductTypes() async {
    _productTypesNotifier.value = UiResult.loading();
    final result = await _repo.fetchProductTypes();
    if (result.hasError) {
      _productTypesNotifier.value = UiResult.error(error: result.error);
      return;
    }
    if (result.isEmpty) {
      _productTypesNotifier.value = UiResult.empty();
      return;
    }
    final types = result.data.productType ?? const <ProductTypeData>[];
    if (types.isEmpty) {
      _productTypesNotifier.value = UiResult.empty();
      return;
    }
    _productTypesNotifier.value = UiResult.success(data: types);
  }

  /// รายการ Flash Sale ที่ active อยู่
  final ValueNotifier<UiResult<List<FlashSaleData>>> _flashSalesNotifier =
      ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<List<FlashSaleData>>> get flashSalesNotifier =>
      _flashSalesNotifier;

  /// ดึงรายการ Flash Sale จาก API
  Future<void> fetchFlashSales() async {
    _flashSalesNotifier.value = UiResult.loading();

    final result = await _repo.fetchFlashSales();

    if (result.hasError) {
      _flashSalesNotifier.value = UiResult.error(error: result.error);
      return;
    }
    if (result.isEmpty) {
      _flashSalesNotifier.value = UiResult.empty();
      return;
    }
    final sales = result.data.flashSales ?? <FlashSaleData>[];
    if (sales.isEmpty) {
      _flashSalesNotifier.value = UiResult.empty();
      return;
    }
    _flashSalesNotifier.value = UiResult.success(data: sales);
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
