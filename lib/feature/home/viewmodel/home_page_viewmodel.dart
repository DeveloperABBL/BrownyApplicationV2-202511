import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/home/models/banner_model.dart';
import 'package:browny_applications_new/feature/home/repository/home_repo.dart';
import 'package:flutter/foundation.dart';

class HomePageViewmodel extends AppViewModel {
  HomePageViewmodel({
    required super.context,
    required HomeDataSourceMixin repo,
  }) : _repo = repo;

  // ========== Repo ==========
  HomeDataSourceMixin _repo;

  // ========== Controller, ValueNotifier ==========
  final ValueNotifier<UiResult<List<BannerModel>>> _bannerNotifier =
      ValueNotifier(
        UiResult.loading(),
      );
  ValueListenable<UiResult<List<BannerModel>>> get bannerNotifier =>
      _bannerNotifier;

  bool isProfileGuest() {
    return currentCustomerProvider.current.isGuest;
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
