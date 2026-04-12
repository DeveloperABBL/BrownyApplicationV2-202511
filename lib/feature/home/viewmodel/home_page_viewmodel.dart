import 'dart:async';

import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/banner_collect_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/banner_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/popup_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/working_machines_response.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/articles/models/article_detail_model.dart';
import 'package:browny_applications_new/feature/articles/screens/articles_page.dart';
import 'package:browny_applications_new/feature/home/models/banner_model.dart';
import 'package:browny_applications_new/feature/home/repository/home_repo.dart';
import 'package:browny_applications_new/models/user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

enum HomePageState { home, couponVoucher, scan, branches, brownyShop }

class HomePageViewmodel extends AppViewModel {
  HomePageViewmodel({
    required super.context,
    required HomeDataSourceMixin repo,
  }) : _repo = repo;

  // ========== Repo ==========
  final HomeDataSourceMixin _repo;
  HomeDataSourceMixin get homeRepo => _repo;

  // ========== Dispose ==========
  @override
  void dispose() {
    _homePageStateNotifier.dispose();
    _bannerNotifier.dispose();
    _bannerHighlightNotifier.dispose();
    _categoriesNotifier.dispose();
    _workingMachinesNotifier.dispose();
    _customerNotificationsCountNotifier.dispose();
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
    unawaited(fetchCustomerNotifications());
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

  Future<UiResult<BrownyLiveResponse>> fetchBrownyLive() async {
    try {
      final result = await _repo.fetchBrownyLive();
      if (result.isEmpty || result.hasError) {
        return UiResult.empty(error: result.error);
      }

      return UiResult.success(data: result.data);
    } on Exception catch (e) {
      return UiResult.error(error: e);
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
}
