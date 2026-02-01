import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/location_helper.dart';
import 'package:browny_applications_new/core/utils/permission_helper.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/core/widgets/app_overlays.dart';
import 'package:browny_applications_new/feature/transactions/models/coupon_list_model.dart';
import 'package:browny_applications_new/feature/transactions/models/customer_coupon_model.dart';
import 'package:browny_applications_new/feature/transactions/repository/coupon_voucher_repo.dart';
import 'package:browny_applications_new/feature/transactions/screens/purchase_coupon_voucher_page.dart';
import 'package:browny_applications_new/feature/transactions/viewmodel/purchase_coupon_viewmodel_delegate.dart';
import 'package:browny_applications_new/models/user_model.dart';
import 'package:browny_applications_new/res/icons/assets.gen.dart';
import 'package:browny_applications_new/res/strings/app_strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart' as handler;

class TransactionsViewmodel extends AppViewModel
    with PurchaseCouponViewmodelDelegate {
  TransactionsViewmodel({
    required super.context,
    required CouponVoucherDataSourceMixin couponRepo,
  }) : _couponRepo = couponRepo;

  // ========== Repository ==========
  final CouponVoucherDataSourceMixin _couponRepo;
  @override
  CouponVoucherDataSourceMixin get repoDelegate => _couponRepo;

  @override
  UserModel get currentUserDelegate => currentCustomerProvider.current;

  @override
  void dispose() {
    _showNearbyStoresNotifier.dispose();
    _evoucherForSellNotifier.dispose();
    _evoucherNotifier.dispose();
    super.dispose();
  }

  // ========== Notifier, Controller ==========

  late final ValueNotifier<bool> _showNearbyStoresNotifier = ValueNotifier(
    true,
  );
  ValueListenable<bool> get showNearbyStoresNotifier =>
      _showNearbyStoresNotifier;

  late final ValueNotifier<UiResult<List<CustomerCouponModel>>>
  _evoucherNotifier = ValueNotifier(
    UiResult.loading(),
  );
  ValueListenable<UiResult<List<CustomerCouponModel>>> get evoucherNotifier =>
      _evoucherNotifier;

  late final ValueNotifier<UiResult<CouponListModel>> _evoucherForSellNotifier =
      ValueNotifier(
        UiResult.loading(),
      );
  ValueListenable<UiResult<CouponListModel>> get evoucherForSellNotifier =>
      _evoucherForSellNotifier;

  // ========== function, Logic ==========
  late CouponPackageItem _selectedCoupon;
  @override
  CouponPackageItem get selectedCoupon => _selectedCoupon;

  void goPurchasePage(BuildContext context, CouponPackageItem selected) {
    _selectedCoupon = selected;
    storeListNotifier = ValueNotifier(UiResult.loading());
    context.pushNamed(
      PurchaseCouponVoucherPage.pageName,
      extra: this,
    );
  }

  /// Initialize location permission and fetch coupon packages
  Future<void> initializeLocationAndFetchCoupons() async {
    // Check location permission
    final hasPermission = await PermissionHelper.hasLocationPermission();

    if (!hasPermission) {
      // Request permission
      final granted = await PermissionHelper.requestLocationPermission();

      if (context.mounted && granted != handler.PermissionStatus.granted) {
        // User denied permission
        AppOverlays.showBrownyDialog(
          context,
          imageAsset: Assets.png.brownyError2.path,
          title: 'ไม่สามารถเข้าถึงตำแหน่งได้',
          message: 'กรุณาให้สิทธิ์เข้าถึงตำแหน่งเพื่อแสดงสาขาใกล้คุณ',
          confirmText: 'เปิด Setting',
          onConfirm: () async {
            await PermissionHelper.openAppSettings();
            // Retry after opening settings
            await initializeLocationAndFetchCoupons();
          },
          cancelText: context.wording.cancel,
          onCancel: () {
            // User cancelled - fetch without location
            _showNearbyStoresNotifier.value = false;
            fetchCouponPackageListDependsOn(currentLocation: null);
          },
        );
        return;
      }
    }

    // Permission granted - get location and fetch
    try {
      final position = await LocationHelper.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);
      await fetchCouponPackageListDependsOn(currentLocation: latLng);
    } catch (e) {
      print('Error getting location: $e');
      // Fallback to fetch without location
      _showNearbyStoresNotifier.value = false;
      await fetchCouponPackageListDependsOn(currentLocation: null);
    }
  }

  /// Handle nearby stores switch change
  Future<void> onNearbyStoresSwitchChanged(bool value) async {
    _showNearbyStoresNotifier.value = value;

    if (value) {
      // User turned on - request location permission and fetch
      await initializeLocationAndFetchCoupons();
    } else {
      // User turned off - fetch without location
      await fetchCouponPackageListDependsOn(currentLocation: null);
    }
  }

  /// fetch E-Voucher All-Store ทั้งหมดมา
  Future<void> fetchCouponPackageListDependsOn({
    LatLng? currentLocation,
  }) async {
    if (!_evoucherForSellNotifier.value.isLoading) {
      _evoucherForSellNotifier.value = UiResult.loading();
    }

    final customerId = currentCustomerProvider.current.id;
    final result = await _couponRepo.fetchCouponPackageList(
      customerId: customerId,
      latitude: currentLocation?.latitude.toString(),
      longitude: currentLocation?.longitude.toString(),
    );

    if (result.isEmpty || result.hasError) {
      _evoucherForSellNotifier.value = UiResult.empty();
      return;
    }

    _evoucherForSellNotifier.value = UiResult.success(
      data: CouponListModel.fromResponse(result.data),
    );
  }

  /// Fetch ข้อมูล EVoucher ของ Customer
  Future<void> fetchCustomerEVoucher() async {
    if (!evoucherNotifier.value.isLoading) {
      _evoucherNotifier.value = UiResult.loading();
    }

    String id = currentCustomerProvider.current.id!;
    final result = await _couponRepo.fetchCouponEVoucher(id);
    if (result.isEmpty || result.data.data.orEmpty.isEmpty) {
      // ไม่ข้อมูล noti ด้วย empty
      _evoucherNotifier.value = UiResult.empty();
      return;
    }

    if (result.hasError) {
      // มี error
      _evoucherNotifier.value = UiResult.error(error: result.error);
      return;
    }

    _evoucherNotifier.value = UiResult.success(
      data: result.data.data!
          .map(
            (e) => CustomerCouponModel.fromCouponData(e),
          )
          .toList(),
    );
  }
}
