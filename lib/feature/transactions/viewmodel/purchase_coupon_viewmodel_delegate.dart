import 'package:browny_applications_new/core/data/remote/models/request/coupon_list_request.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coupon_detail_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/transactions/models/coupon_detail_model.dart';
import 'package:browny_applications_new/feature/transactions/models/coupon_list_model.dart';
import 'package:browny_applications_new/feature/transactions/models/store_list_model.dart';
import 'package:browny_applications_new/feature/transactions/repository/coupon_voucher_repo.dart';
import 'package:browny_applications_new/models/user_model.dart';
import 'package:flutter/foundation.dart';

mixin PurchaseCouponViewmodelDelegate implements AppViewModelDelegateMixin {
  // ========== Dispose ==========
  @override
  void disposeDelegate() {
    storeListNotifier?.dispose();
    storeListNotifier = null;
    _couponDetailNotifier?.dispose();
    _couponDetailNotifier = null;
    _selectedPackageNotifier?.dispose();
    _selectedPackageNotifier = null;
  }

  // ========== Repo delegate ==========
  CouponVoucherDataSourceMixin get repoDelegate;

  // ========== Notifier, Controller ==========
  ValueNotifier<UiResult<List<StoreListModel>>>? storeListNotifier;

  ValueNotifier<UiResult<CouponDetailModel>>? _couponDetailNotifier;
  ValueListenable<UiResult<CouponDetailModel>>? get couponDetailNotifier =>
      _couponDetailNotifier ??
      (_couponDetailNotifier = ValueNotifier(UiResult.loading()));

  ValueNotifier<PackageDetailData?>? _selectedPackageNotifier;
  ValueListenable<PackageDetailData?>? get selectedPackageNotifier =>
      _selectedPackageNotifier;

  // ========== Function, Logic ==========
  CouponPackageItem get selectedCoupon;

  UserModel get currentUserDelegate;

  /// เลือก package จาก list
  void selectPackage(PackageDetailData package) {
    _selectedPackageNotifier?.value = package;
  }

  /// Fetch ข้อมูล Coupon Detail จาก API
  ///
  /// [latitude] - ละติจูดของผู้ใช้ (ถ้ามี)
  /// [longitude] - ลองจิจูดของผู้ใช้ (ถ้ามี)
  Future<void> fetchCouponDetail({
    String? latitude,
    String? longitude,
  }) async {
    // Initialize notifier if null
    _couponDetailNotifier ??= ValueNotifier(UiResult.loading());
    _selectedPackageNotifier ??= ValueNotifier(null);

    if (!_couponDetailNotifier!.value.isLoading) {
      _couponDetailNotifier!.value = UiResult.loading();
    }

    if (selectedCoupon.data.couponId == null) {
      _couponDetailNotifier!.value = UiResult.empty();
      return;
    }

    // สร้าง request body
    final request = CouponListRequest(
      latitude: latitude,
      longitude: longitude,
      customerId: currentUserDelegate.id,
    );

    final response = await repoDelegate.fetchCouponDetail(
      selectedCoupon.data.couponId!,
      request,
    );

    if (response.isEmpty || response.hasError) {
      _couponDetailNotifier!.value = UiResult.empty();
      return;
    }

    final detailModel = CouponDetailModel.fromResponse(response.data);

    // Auto-select package ที่ตรงกับ packageId
    final selectedPackage = detailModel.getPackageById(
      selectedCoupon.data.packageId!,
    );
    _selectedPackageNotifier!.value = selectedPackage;

    _couponDetailNotifier!.value = UiResult.success(data: detailModel);
  }

  Future<void> fetchStoreList() async {
    if (!storeListNotifier!.value.isLoading) {
      storeListNotifier!.value = UiResult.loading();
    }
    final response = await repoDelegate.fetchCouponStoreList();
    if (response.isEmpty || response.hasError) {
      storeListNotifier!.value = UiResult.empty();
      return;
    }

    storeListNotifier!.value = UiResult.success(
      data: response.data.data.orEmpty
          .map(
            (e) => StoreListModel.fromCouponData(e),
          )
          .toList(),
    );
  }
}
