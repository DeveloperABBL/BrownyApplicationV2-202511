import 'package:browny_applications_new/core/data/remote/models/response/coin_claimed_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coin_history_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/product_types_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/products_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:browny_applications_new/feature/browny_shop/viewmodel/browny_shop_favorite_mixin.dart';
import 'package:browny_applications_new/feature/coin/models/coin_data_model.dart';
import 'package:browny_applications_new/feature/coin/repository/coin_claim_repo.dart';
import 'package:browny_applications_new/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CoinViewmModel extends AppViewModel with BrownyShopFavoriteMixin {
  CoinViewmModel({
    required super.context,
    required CoinDataSourceMixin repo,
    required this.brownyShopRepo,
  }) : _repo = repo;

  final CoinDataSourceMixin _repo;
  final BrownyShopDataSourceMixin brownyShopRepo;

  @override
  BrownyShopDataSourceMixin get favoriteRepo => brownyShopRepo;

  @override
  ValueNotifier<UiResult<List<ProductData>>> get favoriteProductsNotifier =>
      _shopProductsNotifier;

  // ========== dispose ==========
  @override
  void dispose() {
    _toDayDataNotifier.dispose();
    _coinClaimDataNotifier.dispose();
    _coinHistoryNotifier.dispose();
    _coinHistoryGroupsNotifier.dispose();
    _shopProductsNotifier.dispose();
    _shopProductTypesNotifier.dispose();
    _shopSelectedCategoryNotifier.dispose();
    super.dispose();
  }

  /// Notifier fetch รายการประเภทสินค้า Browny Shop (chip filter)
  final ValueNotifier<UiResult<List<ProductTypeData>>>
  _shopProductTypesNotifier = ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<List<ProductTypeData>>>
  get shopProductTypesNotifier => _shopProductTypesNotifier;

  /// DONG 2026-05-26
  ///
  /// API fetch รายการประเภทสินค้า Browny Shop — ใช้สร้าง chip filter
  Future<void> fetchShopProductTypes() async {
    _shopProductTypesNotifier.value = UiResult.loading();
    final result = await brownyShopRepo.fetchProductTypes();
    if (result.hasError) {
      _shopProductTypesNotifier.value = UiResult.error(error: result.error);
      return;
    }
    if (result.isEmpty) {
      _shopProductTypesNotifier.value = UiResult.empty();
      return;
    }
    final types = result.data.productType ?? const <ProductTypeData>[];
    if (types.isEmpty) {
      _shopProductTypesNotifier.value = UiResult.empty();
      return;
    }
    _shopProductTypesNotifier.value = UiResult.success(data: types);
  }

  // ========== ValueNotifier, Controller ==========
  // ข้อมูลวันที่ที่จะแสดง
  final ValueNotifier<UiResult<String>> _toDayDataNotifier = ValueNotifier(
    UiResult.empty(),
  );
  ValueListenable<UiResult<String>> get toDayDataNotifier => _toDayDataNotifier;
  // ข้อมูล coin สำหรับ claim ทั้งหมด
  final ValueNotifier<UiResult<CoinDataModel>> _coinClaimDataNotifier =
      ValueNotifier(
        UiResult.loading(),
      );
  ValueListenable<UiResult<CoinDataModel>> get coinClaimDataNotifier =>
      _coinClaimDataNotifier;
  // ข้อมูลประวัติ Browny Coin
  late final ValueNotifier<UiResult<CoinHistoryResponse>> _coinHistoryNotifier =
      ValueNotifier(
        UiResult.loading(),
      );
  ValueListenable<UiResult<CoinHistoryResponse>> get coinHistoryNotifier =>
      _coinHistoryNotifier;

  // ข้อมูลประวัติ Browny Coin ที่ถูกจัดกลุ่มตามเดือน
  late final ValueNotifier<UiResult<List<CoinHistoryGroup>>>
  _coinHistoryGroupsNotifier = ValueNotifier(
    UiResult.loading(),
  );
  ValueListenable<UiResult<List<CoinHistoryGroup>>>
  get coinHistoryGroupsNotifier => _coinHistoryGroupsNotifier;

  /// Notifier fetch รายการสินค้า Browny Shop
  final ValueNotifier<UiResult<List<ProductData>>> _shopProductsNotifier =
      ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<List<ProductData>>> get shopProductsNotifier =>
      _shopProductsNotifier;

  /// Notifier เก็บ category ที่ user เลือกอยู่ใน Shop section
  /// ค่าเริ่มต้น = "all"
  final ValueNotifier<String> _shopSelectedCategoryNotifier = ValueNotifier(
    'all',
  );
  ValueListenable<String> get shopSelectedCategoryNotifier =>
      _shopSelectedCategoryNotifier;
  // ========== Logic ==========
  /// เปลี่ยน category ที่เลือกใน Shop section แล้ว fetch ข้อมูลใหม่
  Future<void> onShopCategorySelected(String category) async {
    if (_shopSelectedCategoryNotifier.value == category) return;
    _shopSelectedCategoryNotifier.value = category;
    await fetchShopProducts(productType: category);
  }

  /// DONG 2026-05-10
  ///
  /// API fetch รายการสินค้า Browny Shop
  ///
  /// Parameters:
  /// - productType: String (default "all")
  Future<void> fetchShopProducts({String productType = 'all'}) async {
    // 1. Set loading
    _shopProductsNotifier.value = UiResult.loading();

    final customerId = currentCustomerProvider.current.id.orEmpty;

    // 2. Call repo
    final result = await brownyShopRepo.fetchProducts(
      productType: productType,
      customerId: customerId,
    );

    // 3. Handle error
    if (result.hasError) {
      _shopProductsNotifier.value = UiResult.error(error: result.error);
      return;
    }

    // 4. Handle empty
    if (result.isEmpty) {
      _shopProductsNotifier.value = UiResult.empty();
      return;
    }

    // 5. Handle success
    final products = result.data.product ?? <ProductData>[];
    if (products.isEmpty) {
      _shopProductsNotifier.value = UiResult.empty();
      return;
    }
    _shopProductsNotifier.value = UiResult.success(data: products);
  }

  Future<UiResult<CoinClaimedResponse>> coinClaiming() async {
    String id = currentCustomerProvider.current.id!;
    final result = await _repo.coinClaiming(id);
    if (result.isError) {
      return UiResult.error(error: result.error);
    }

    await fetchCoinCliamData();
    return UiResult.success(data: result.data);
  }

  Future<void> fetchCoinCliamData() async {
    String id = currentCustomerProvider.current.id!;
    final profileResult = await _repo.fetchProfileInfo(id);

    if (profileResult.isError || profileResult.isEmpty) {
      // Error จะ claim ไม่ได้
      _coinClaimDataNotifier.value = UiResult.error(
        error: Exception(profileResult.error.toString()),
      );
      return;
    }

    final result = await _repo.fetchCoinClaimData(id);

    if (result.isEmpty) {
      _coinClaimDataNotifier.value = UiResult.empty();
      return;
    }
    if (result.hasError) {
      _coinClaimDataNotifier.value = UiResult.error(error: result.error);
      return;
    }

    final profileDataLocal = await _repo.customerProfileData();
    // update ข้อมูล profile ทั้งหมด
    currentCustomerProvider.newUser = UserModel.fromCustomerProfileData(
      profileResult.data.copyWith(
        creditBalance: profileDataLocal.data.creditBalance,
        brownyCoin: profileDataLocal.data.brownyCoin,
        coinValue: profileDataLocal.data.coinValue,
        currentCoin: profileDataLocal.data.currentCoin,
      ),
    );

    // render ข้อมูล claim
    if (context.mounted) {
      final data = CoinDataModel.fromCoinClaimData(
        Localizations.localeOf(context).languageCode,
        result.data.data!,
      );

      _toDayDataNotifier.value = UiResult.success(
        data: data.todayCalendarDate.orEmpty,
        // data: data.streaksDisplay.firstWhere((e) => e.isToday).day,
      );

      _coinClaimDataNotifier.value = UiResult.success(
        data: data,
      );
    }
  }

  Future<void> fetchCoinHistory() async {
    _coinHistoryNotifier.value = UiResult.loading();
    _coinHistoryGroupsNotifier.value = UiResult.loading();

    String id = currentCustomerProvider.current.id!;
    final result = await _repo.fetchCoinHistory(id);

    if (result.isEmpty) {
      _coinHistoryNotifier.value = UiResult.empty();
      _coinHistoryGroupsNotifier.value = UiResult.empty();
      return;
    }

    if (result.hasError) {
      _coinHistoryNotifier.value = UiResult.error(error: result.error);
      _coinHistoryGroupsNotifier.value = UiResult.error(error: result.error);
      return;
    }

    _coinHistoryNotifier.value = UiResult.success(data: result.data);

    // จัดกลุ่มประวัติตามเดือน
    final history = result.data.data?.history ?? [];
    final groups = history.groupByMonth();
    _coinHistoryGroupsNotifier.value = UiResult.success(data: groups);
  }

  String descriptionPopupCondition(BuildContext context) {
    switch (context.languageCode) {
      case 'en':
        // Terms and Conditions
        // • For every XX THB spent on washing and drying, receive 1 Browny Coin
        // • Every 10 Browny Coins have a value of 1 THB
        // • You have XXX coins that will expire in October X, 202X
        return '''
<p>Terms and Conditions</p>
<ul>
<li>For every XX THB spent on washing and drying, receive 1 Browny Coin</li>
<li>Every 10 Browny Coins have a value of 1 THB</li>
<li>You have XXX coins that will expire in October X, 202X</li>
</ul>
''';
      case 'zh':
        // 条款和条件
        // • 每消费XX泰铢洗烘服务，可获得1个Browny Coin
        // • 每10个Browny Coin价值1泰铢
        // • 您有XXX个硬币将于202X年10月X日到期
        return '''
<p>条款和条件</p>
<ul>
<li>每消费XX泰铢洗烘服务，可获得1个Browny Coin</li>
<li>每10个Browny Coin价值1泰铢</li>
<li>您有XXX个硬币将于202X年10月X日到期</li>
</ul>
''';
      default:
        return
        // '''
        // เงื่อนไข
        // • ทุกๆ XX บาท ในการซักอบ ได้รับ 1 Browny Coin
        // • ทุกๆ 10 Browny Coin มีมูลค่า 1 บาท
        // • คุณมี XXX เหรียญ ที่จะหมดอายุใน X ตุลาคม 202X
        // ''';
        '''
<p>เงื่อนไข</p>
<ul>
<li>ทุกๆ XX บาท ในการซักอบ ได้รับ 1 Browny Coin</li>
<li>ทุกๆ 10 Browny Coin มีมูลค่า 1 บาท</li>
<li>คุณมี XXX เหรียญ ที่จะหมดอายุใน X ตุลาคม 202X</li>
</ul>
''';
    }
  }
}
