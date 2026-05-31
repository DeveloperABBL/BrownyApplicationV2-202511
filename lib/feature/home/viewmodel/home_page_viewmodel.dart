import 'dart:async';

import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/banner_collect_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/banner_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/popup_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/product_types_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/browny_shop_orders_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/products_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/working_machines_response.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/articles/models/article_detail_model.dart';
import 'package:browny_applications_new/feature/articles/screens/articles_page.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:browny_applications_new/feature/browny_shop/viewmodel/browny_shop_favorite_mixin.dart';
import 'package:browny_applications_new/feature/home/models/banner_model.dart';
import 'package:browny_applications_new/feature/home/repository/home_repo.dart';
import 'package:browny_applications_new/models/user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

enum HomePageState { home, couponVoucher, scan, branches, brownyShop }

class HomePageViewmodel extends AppViewModel with BrownyShopFavoriteMixin {
  HomePageViewmodel({
    required super.context,
    required HomeDataSourceMixin repo,
    required BrownyShopDataSourceMixin brownyShopRepo,
  }) : _repo = repo,
       _brownyShopRepo = brownyShopRepo;

  // ========== Repo ==========
  final HomeDataSourceMixin _repo;
  HomeDataSourceMixin get homeRepo => _repo;

  final BrownyShopDataSourceMixin _brownyShopRepo;
  BrownyShopDataSourceMixin get brownyShopRepo => _brownyShopRepo;

  @override
  BrownyShopDataSourceMixin get favoriteRepo => _brownyShopRepo;

  @override
  ValueNotifier<UiResult<List<ProductData>>> get favoriteProductsNotifier =>
      _shopProductsNotifier;

  // ========== Dispose ==========
  @override
  void dispose() {
    _homePageStateNotifier.dispose();
    _bannerNotifier.dispose();
    _bannerHighlightNotifier.dispose();
    _categoriesNotifier.dispose();
    _workingMachinesNotifier.dispose();
    _customerNotificationsCountNotifier.dispose();
    _shopProductsNotifier.dispose();
    _shopProductTypesNotifier.dispose();
    _shopSelectedCategoryNotifier.dispose();
    _brownyLiveNotifier.dispose();
    _brownyOrdersNotifier.dispose();
    _serviceFilterNotifier.dispose();
    super.dispose();
  }

  // ========== Controller, ValueNotifier ==========
  /// Notifier สำหรับเก็บ notifications ของลูกค้า
  final ValueNotifier<UiResult<int>> _customerNotificationsCountNotifier =
      ValueNotifier(UiResult.loading());

  ValueListenable<UiResult<int>> get customerNotificationsCountNotifier =>
      _customerNotificationsCountNotifier;

  /// Notifier สำหรับคุมการแสดงผลที่หน้า home_page
  final ValueNotifier<UiResult<HomePageState>> _homePageStateNotifier =
      ValueNotifier(
        UiResult.success(data: HomePageState.home),
      );
  ValueListenable<UiResult<HomePageState>> get homePageStateNotifier =>
      _homePageStateNotifier;

  /// Notifier fetch banner
  final ValueNotifier<UiResult<List<BannerModel>>> _bannerNotifier =
      ValueNotifier(
        UiResult.loading(),
      );
  ValueListenable<UiResult<List<BannerModel>>> get bannerNotifier =>
      _bannerNotifier;

  /// Notifier fetch banner highlight
  final ValueNotifier<UiResult<List<BannerHighLightModel>>>
  _bannerHighlightNotifier = ValueNotifier(
    UiResult.loading(),
  );
  ValueListenable<UiResult<List<BannerHighLightModel>>>
  get bannerHighlightNotifier => _bannerHighlightNotifier;

  /// Notifier fetch categories
  final ValueNotifier<UiResult<List<CategoryData>>> _categoriesNotifier =
      ValueNotifier(
        UiResult.loading(),
      );
  ValueListenable<UiResult<List<CategoryData>>> get categoriesNotifier =>
      _categoriesNotifier;

  /// Notifier fetch working machines (เครื่องที่กำลังทำงาน)
  final ValueNotifier<UiResult<WorkingMachinesResponse>>
  _workingMachinesNotifier = ValueNotifier(
    UiResult.loading(),
  );
  ValueListenable<UiResult<WorkingMachinesResponse>>
  get workingMachinesNotifier => _workingMachinesNotifier;

  /// Notifier fetch รายการสินค้า Browny Shop
  final ValueNotifier<UiResult<List<ProductData>>> _shopProductsNotifier =
      ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<List<ProductData>>> get shopProductsNotifier =>
      _shopProductsNotifier;

  /// Notifier fetch รายการประเภทสินค้า Browny Shop (chip filter)
  final ValueNotifier<UiResult<List<ProductTypeData>>>
  _shopProductTypesNotifier = ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<List<ProductTypeData>>>
  get shopProductTypesNotifier => _shopProductTypesNotifier;

  /// Notifier เก็บ category ที่ user เลือกอยู่ใน Shop section
  /// ค่าเริ่มต้น = "all"
  final ValueNotifier<String> _shopSelectedCategoryNotifier = ValueNotifier(
    'all',
  );
  ValueListenable<String> get shopSelectedCategoryNotifier =>
      _shopSelectedCategoryNotifier;

  /// Notifier fetch Browny Live (เปิด/ปิดไอคอน + ลิงก์ external)
  final ValueNotifier<UiResult<BrownyLiveResponse>> _brownyLiveNotifier =
      ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<BrownyLiveResponse>> get brownyLiveNotifier =>
      _brownyLiveNotifier;

  /// Notifier fetch คำสั่งซื้อ Browny Shop ที่รอชำระเงิน (pending_payment)
  /// — แสดงในการ์ดสถานะการทำงานหน้า Home
  final ValueNotifier<UiResult<List<BrownyShopOrderItem>>>
  _brownyOrdersNotifier = ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<List<BrownyShopOrderItem>>> get brownyOrdersNotifier =>
      _brownyOrdersNotifier;

  /// ตัวกรองชนิดบริการในการ์ด "สถานะการทำงาน"
  /// 0 = ทั้งหมด, 1 = ซัก-อบ (เครื่อง), 2 = การสั่งซื้อ (Browny Shop)
  final ValueNotifier<int> _serviceFilterNotifier = ValueNotifier(0);
  ValueListenable<int> get serviceFilterNotifier => _serviceFilterNotifier;

  void setServiceFilter(int value) {
    _serviceFilterNotifier.value = value;
  }

  bool isProfileGuest() {
    return currentCustomerProvider.current.isGuest;
  }

  // ========== Variables ==========
  ArticleDetailModel? _highlighSelected;
  ArticleDetailModel? get highlighSelected => _highlighSelected;
  void onBannerHighLightSelected(
    BuildContext context, {
    required ArticleDetailModel? highlight,
    bool redirect = true,
  }) {
    _highlighSelected = highlight;

    if (redirect) {
      context.pushNamed(
        ArticlesPage.pageName,
        extra: this,
      );
    }
  }

  // ========== Logic ==========
  Future<void> refresh() async {
    await fetchBanners();
    await fetchBannersHighlight();
    await fetchWorkingMachines();
    unawaited(fetchBrownyShopPendingOrders());
    unawaited(fetchCustomerNotifications());
    unawaited(fetchBrownyLive());
    unawaited(fetchShopProductTypes());
    final profileResult = await _repo.fetchProfileInfo('');
    if (profileResult.isSuccess) {
      currentCustomerProvider.newUser = UserModel.fromCustomerProfileData(
        profileResult.data,
      );
    }
  }

  void onBannerSliding() {
    _bannerNotifier.value = UiResult.success(
      data: _bannerNotifier.value.data!,
    );
  }

  void onHomePageNavigationChage(int index) {
    switch (index) {
      case 0:
        onHomePageStateChange(HomePageState.home);
        break;
    }
  }

  void onHomePageStateChange(HomePageState state) {
    _homePageStateNotifier.value = UiResult.success(
      data: state,
    );
  }

  Future<void> fetchBanners() async {
    final customerId = currentCustomerProvider.current.id;
    final response = await _repo.fetchBanner(customerId: customerId);
    if (response.isEmpty || response.hasError) {
      _bannerNotifier.value = UiResult.empty();
      _categoriesNotifier.value = UiResult.empty();
      return;
    }

    _bannerNotifier.value = UiResult.success(
      data: response.data.data!
          .map((e) => BannerModel.fromBannerResponse(e))
          .toList(),
    );

    // เก็บ categories จาก response
    if (response.data.categories != null &&
        response.data.categories!.isNotEmpty) {
      _categoriesNotifier.value = UiResult.success(
        data: response.data.categories!,
      );
    } else {
      _categoriesNotifier.value = UiResult.empty();
    }
  }

  Future<void> fetchBannersHighlight() async {
    final customerId = currentCustomerProvider.current.id;
    final response = await _repo.fetchBannerHighlight(customerId: customerId);
    if (response.isEmpty || response.hasError) {
      _bannerHighlightNotifier.value = UiResult.empty();
      return;
    }

    _bannerHighlightNotifier.value = UiResult.success(
      data: (response.data.data ?? [])
          .map((e) => BannerHighLightModel.fromBannerResponse(e))
          .toList(),
    );
  }

  /// Fetch Browny Live + อัปเดต [_brownyLiveNotifier]
  ///
  /// เรียกครั้งเดียวตอนเข้าหน้า + ตอน pull-to-refresh — view subscribe ผ่าน
  /// notifier ไม่ต้อง re-fetch ทุก rebuild (กันบั๊ก keyboard เปิด/ปิด
  /// แล้ว `MediaQuery` propagate มาทำให้ HomePage rebuild → ยิงรัว ๆ)
  Future<void> fetchBrownyLive() async {
    _brownyLiveNotifier.value = UiResult.loading();
    try {
      final result = await _repo.fetchBrownyLive();
      if (result.hasError) {
        _brownyLiveNotifier.value = UiResult.error(error: result.error);
        return;
      }
      if (result.isEmpty) {
        _brownyLiveNotifier.value = UiResult.empty(error: result.error);
        return;
      }
      _brownyLiveNotifier.value = UiResult.success(data: result.data);
    } on Exception catch (e) {
      _brownyLiveNotifier.value = UiResult.error(error: e);
    }
  }

  /// Fetch popups จาก API
  ///
  /// จะกรองเฉพาะ popup ที่:
  /// - active = true
  /// - อยู่ในช่วงเวลาที่กำหนด
  /// - ไม่ถูก dismiss ไปแล้วในวันนี้
  Future<UiResult<List<PopupData>>> fetchPopups() async {
    try {
      final result = await _repo.fetchPopups(showOn: 'home');
      if (result.isEmpty) {
        return UiResult.empty();
      }

      if (result.hasError) {
        return UiResult.empty(error: result.error);
      }

      return UiResult.success(data: result.data);
    } on Exception catch (e) {
      return UiResult.error(error: e);
    }
  }

  /// ใช้เช็คว่าวันนี้มีการแสดง popup ชวนเพื่อนไปแล้วหรือยัง
  Future<UiResult<bool>> fetchPopupInivitFriendForToday() async {
    final showToday = await _repo.fetchPopupInvitFriend();
    return UiResult.success(
      data: showToday.data,
    );
  }

  /// บันทึกว่า popup นี้ถูก dismiss สำหรับวันนี้
  void dismissPopupForToday(int popupId) {
    _repo.dismissPopupForToday(popupId);
  }

  void dismissInvitFriendForToday() {
    _repo.dismissInvitFriendForToday();
  }

  /// บันทึกว่า popup list นี้ถูก dismiss สำหรับวันนี้
  void dismissPopupsForToday(List<PopupData> popups) {
    _repo.dismissPopupsForToday(popups);
  }

  /// DONG 2026-02-28
  ///
  /// API fetch รายการเครื่องที่กำลังทำงาน
  ///
  /// จะแสดงเครื่องที่กำลังทำงานของ user ปัจจุบัน
  Future<void> fetchWorkingMachines() async {
    try {
      _workingMachinesNotifier.value = UiResult.loading();

      // ดึง customer_id และ notification_token
      final customerId = currentCustomerProvider.current.id;
      final notificationToken = await FirebaseMessaging.instance.getToken();

      // ต้องมีค่าใดค่านึง
      if (customerId.orEmpty.isEmpty && notificationToken.orEmpty.isEmpty) {
        _workingMachinesNotifier.value = UiResult.empty();
        return;
      }

      final result = await _repo.fetchWorkingMachines(
        customerId: customerId,
        notificationToken: notificationToken,
      );

      if (result.hasError) {
        _workingMachinesNotifier.value = UiResult.error(error: result.error);
        return;
      }

      if (result.isEmpty) {
        _workingMachinesNotifier.value = UiResult.empty();
        return;
      }

      _workingMachinesNotifier.value = UiResult.success(data: result.data);

      // [DEBUG] POC: เริ่ม Live Activity จากเครื่องแรกที่กำลังทำงาน
      // if (kDebugMode) {
      //   final machines = result.data.data;
      //   if (machines != null && machines.isNotEmpty) {
      //     final machine = machines.first;
      //     final remaining =
      //         CustomerServicesWorkingModel.fromWorkingMachineResponse(
      //           machine,
      //         ).remainingTimeDuration;
      //     await LaundryLiveActivityService.instance.startActivity(
      //       data: LaundryLiveActivityData(
      //         machineId: '${machine.id ?? 0}',
      //         machineNumber: machine.getNameDisplay('th'),
      //         serviceType: 'wash',
      //         branchName: '',
      //         remainingSeconds: remaining.inSeconds,
      //         totalSeconds: remaining.inSeconds,
      //       ),
      //     );
      //   }
      // }
    } on Exception catch (e) {
      _workingMachinesNotifier.value = UiResult.error(error: e);
    }
  }

  /// DONG 2026-05-31
  ///
  /// API ดึงคำสั่งซื้อ Browny Shop ที่ "รอชำระเงิน" (pending_payment)
  /// — กรองช่วง 6 ชั่วโมงล่าสุด (start_date..end_date = yyyy-MM-dd) แล้วคัด
  /// เฉพาะ status == 'pending_payment' มาแสดงในการ์ดสถานะการทำงานหน้า Home
  Future<void> fetchBrownyShopPendingOrders() async {
    final customerId = currentCustomerProvider.current.id.orEmpty;
    if (customerId.isEmpty) {
      _brownyOrdersNotifier.value = UiResult.empty();
      return;
    }
    _brownyOrdersNotifier.value = UiResult.loading();

    // ย้อนหลัง 6 ชม. จากเวลาปัจจุบัน
    final now = DateTime.now();
    final from = now.subtract(const Duration(hours: 6));

    final result = await _brownyShopRepo.fetchBrownyShopOrders(
      customerId: customerId,
      startDate: _formatDate(from),
      endDate: _formatDate(now),
    );

    if (result.hasError) {
      _brownyOrdersNotifier.value = UiResult.error(error: result.error);
      return;
    }
    if (result.isEmpty) {
      _brownyOrdersNotifier.value = UiResult.empty();
      return;
    }
    // กรองเฉพาะออร์เดอร์ที่รอชำระเงิน
    final pending = result.data
        .where((o) => o.isPendingPayment)
        .toList();
    if (pending.isEmpty) {
      _brownyOrdersNotifier.value = UiResult.empty();
      return;
    }
    _brownyOrdersNotifier.value = UiResult.success(data: pending);
  }

  /// format วันที่เป็น yyyy-MM-dd สำหรับ query start_date/end_date
  String _formatDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  /// DONG 2026-03-08
  ///
  /// API Collect Banner (เก็บคูปองจาก Banner)
  ///
  /// Parameters:
  /// - bannerId: ID ของ Banner
  ///
  /// Returns:
  /// - UiResult BannerCollectResponse with status และ message
  ///
  /// Response HTTP Codes:
  /// - 200: สำเร็จ
  /// - 400: ข้อมูลไม่ถูกต้อง
  /// - 500: เกิดข้อผิดพลาดภายในระบบ
  Future<UiResult<BannerCollectResponse>> collectBanner({
    required int bannerId,
  }) async {
    try {
      final customerId = currentCustomerProvider.current.id;

      // ต้องมี customer_id
      if (customerId == null || customerId.isEmpty) {
        return UiResult.error(
          error: Exception('Customer ID not found'),
        );
      }

      final result = await _repo.collectBanner(
        bannerId: bannerId,
        customerId: customerId,
      );

      if (result.hasError) {
        return UiResult.error(error: result.error);
      }

      if (result.isEmpty) {
        return UiResult.empty();
      }

      // After successful collection, refresh banners to update button status
      await fetchBanners();
      await fetchBannersHighlight();
      // assign state ใหม่ ให้ widget render ตาม state
      _highlighSelected = _highlighSelected?.copyWith(buttonStatus: 'Claimed');
      return UiResult.success(data: result.data);
    } on Exception catch (e) {
      return UiResult.error(error: e);
    }
  }

  Future<void> fetchCustomerNotifications() async {
    // 1. Set loading state
    _customerNotificationsCountNotifier.value = UiResult.loading();

    String customerId = currentCustomerProvider.current.id.orEmpty;
    if (customerId.isEmpty) {
      _customerNotificationsCountNotifier.value = UiResult.empty();
      return;
    }

    // 2. Call repository
    final result = await homeRepo.fetchCustomerNotifications(customerId);

    // 3. Handle error
    if (result.hasError) {
      _customerNotificationsCountNotifier.value = UiResult.error(
        error: result.error,
      );
      return;
    }

    // 4. Handle empty
    if (result.isEmpty) {
      _customerNotificationsCountNotifier.value = UiResult.empty();
      return;
    }

    // 5. Handle success
    _customerNotificationsCountNotifier.value = UiResult.success(
      data: result.data.data.orEmpty.length,
    );
  }

  /// เปลี่ยน category ที่เลือกใน Shop section แล้ว fetch ข้อมูลใหม่
  Future<void> onShopCategorySelected(String category) async {
    if (_shopSelectedCategoryNotifier.value == category) return;
    _shopSelectedCategoryNotifier.value = category;
    await fetchShopProducts(productType: category);
  }

  /// DONG 2026-05-26
  ///
  /// API fetch รายการประเภทสินค้า Browny Shop — ใช้สร้าง chip filter
  Future<void> fetchShopProductTypes() async {
    _shopProductTypesNotifier.value = UiResult.loading();
    final result = await _brownyShopRepo.fetchProductTypes();
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
    final result = await _brownyShopRepo.fetchProducts(
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
}
