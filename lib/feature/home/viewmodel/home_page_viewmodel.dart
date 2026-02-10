import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/home/models/banner_model.dart';
import 'package:browny_applications_new/feature/home/repository/home_repo.dart';
import 'package:browny_applications_new/models/user_model.dart';
import 'package:flutter/foundation.dart';

enum HomePageState { home, couponVoucher, scan, branches, brownyShop }

class HomePageViewmodel extends AppViewModel {
  HomePageViewmodel({
    required super.context,
    required HomeDataSourceMixin repo,
  }) : _repo = repo;

  // ========== Repo ==========
  HomeDataSourceMixin _repo;

  // ========== Dispose ==========
  @override
  void dispose() {
    _homePageStateNotifier.dispose();
    _bannerNotifier.dispose();
    super.dispose();
  }

  // ========== Controller, ValueNotifier ==========
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

  bool isProfileGuest() {
    return currentCustomerProvider.current.isGuest;
  }

  // ========== Logic ==========
  Future<void> refresh() async {
    await fetchBanners();
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
    final response = await _repo.fetchBanner();
    if (response.isEmpty || response.hasError) {
      _bannerNotifier.value = UiResult.empty();
      return;
    }

    _bannerNotifier.value = UiResult.success(
      data: response.data.data!
          .map((e) => BannerModel.fromBannerResponse(e))
          .toList(),
    );
  }
}
