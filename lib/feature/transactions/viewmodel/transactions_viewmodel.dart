import 'package:browny_applications_new/core/data/remote/models/request/coupon_order_request.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coupon_order_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/payment_status_check_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/feature/authentication/error/authen_exception.dart';
import 'package:browny_applications_new/feature/transactions/models/payment_transaction_state.dart';
import 'package:browny_applications_new/core/utils/location_helper.dart';
import 'package:browny_applications_new/core/utils/permission_helper.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/core/widgets/app_overlays.dart';
import 'package:browny_applications_new/feature/transactions/models/coupon_detail_model.dart';
import 'package:browny_applications_new/feature/transactions/models/coupon_list_model.dart';
import 'package:browny_applications_new/feature/transactions/models/coupon_receipt_model.dart';
import 'package:browny_applications_new/feature/transactions/models/customer_coupon_model.dart';
import 'package:browny_applications_new/feature/transactions/repository/coupon_voucher_repo.dart';
import 'package:browny_applications_new/feature/transactions/repository/transaction_repo.dart';
import 'package:browny_applications_new/feature/transactions/screens/coupon_voucher_selected_page.dart';
import 'package:browny_applications_new/feature/transactions/screens/purchase_coupon_voucher_page.dart';
import 'package:browny_applications_new/feature/transactions/viewmodel/coupon_voucher_selected_viewmodel_delegate.dart';
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
    with
        // viewmodel สำหรับคุมการทำงานจังหวะสั่งซื้อ e-voucher
        PurchaseCouponViewmodelDelegate,
        // viewmodel สำหรับควบคุมการทำงานเมื่อเลือก coupon, e-voucher ที่ซื้อแล้ว
        CouponVoucherSelectedViewmodelDelegate {
  TransactionsViewmodel({
    required super.context,
    required CouponVoucherDataSourceMixin couponRepo,
    required TransactionDataSourceMixin transactionRepo,
  }) : _couponRepo = couponRepo,
       _transactionRepo = transactionRepo;

  // ========== Repository ==========
  final CouponVoucherDataSourceMixin _couponRepo;
  final TransactionDataSourceMixin _transactionRepo;
  @override
  CouponVoucherDataSourceMixin get repoDelegate => _couponRepo;

  @override
  UserModel get currentUserDelegate => currentCustomerProvider.current;

  @override
  void dispose() {
    _paymentMethodNotifier.dispose();
    _showNearbyStoresNotifier.dispose();
    _evoucherForSellNotifier.dispose();
    _evoucherNotifier.dispose();
    _transactionStateNotifier.dispose();
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

  late final ValueNotifier<UiResult<List<PaymentMethodModel>>>
  _paymentMethodNotifier = ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<List<PaymentMethodModel>>>
  get paymentMethodNotifier => _paymentMethodNotifier;
  PaymentMethodModel? _paymentSelected;
  PaymentMethodModel? get paymentSelected => _paymentSelected;
  // เก็บค่า payment ก่อนที่จะเข้าหน้าแก้ไข (สำหรับ cancel)
  PaymentMethodModel? _paymentSelectedBeforeEdit;

  /// Unified state สำหรับจัดการ Payment Transaction (payment status + receipt)
  /// แทนที่การใช้ paymentStatusNotifier และ couponReceiptNotifier แยกกัน
  late final ValueNotifier<UiResult<PaymentTransactionState>>
  _transactionStateNotifier = ValueNotifier(
    UiResult.success(data: PaymentTransactionState.idle()),
  );
  ValueListenable<UiResult<PaymentTransactionState>>
  get transactionStateNotifier => _transactionStateNotifier;

  // ========== function, Logic ==========
  late CouponPackageItem _selectedCoupon;
  @override
  CouponPackageItem get selectedCoupon => _selectedCoupon;

  void goPurchasePage(BuildContext context, CouponPackageItem selected) {
    _selectedCoupon = selected;
    storeListNotifier = ValueNotifier(UiResult.loading());
    context
        .pushNamed(
          PurchaseCouponVoucherPage.pageName,
          extra: this,
        )
        .then((_) async {
          if (!context.mounted) return;

          AppOverlays.showLoading(context);
          await initializeLocationAndFetchCoupons();
          AppOverlays.hideLoading();
        });
  }

  void goSelectedPage(BuildContext context, CustomerCouponModel selected) {
    setCustomerCouponSelectedDelegate = selected;
    context
        .pushNamed(
          CouponVoucherSelected.pageName,
          extra: this,
        )
        .then((_) async {
          if (!context.mounted) return;

          AppOverlays.showLoading(context);
          await initializeLocationAndFetchCoupons();
          AppOverlays.hideLoading();
        });
  }

  /// ดึงข้อมูล Payment Methods ที่มีให้เลือก
  ///
  /// [fetchAll] = true: แสดงทั้งหมด, false: แสดงแค่ 3 ตัวแรก
  ///
  /// กลไก:
  /// - ดึง payment methods จาก couponDetail
  /// - ถ้ามีการเลือกไว้แล้ว (_paymentSelected != null) จะเอาตัวที่เลือกมาไว้ index 0
  /// - ถ้ายังไม่เคยเลือก จะเลือกตัวแรกเป็น default
  Future<void> fetchPaymentMethod(
    BuildContext context, {
    bool fetchAll = false,
  }) async {
    // Set loading state ถ้ายังไม่ได้ loading อยู่
    if (!_paymentMethodNotifier.value.isLoading) {
      _paymentMethodNotifier.value = UiResult.loading();
    }

    // ตรวจสอบว่า couponDetail พร้อมใช้งานหรือยัง
    if (!couponDetailNotifier!.value.isSuccess) {
      _paymentMethodNotifier.value = UiResult.empty(
        error: couponDetailNotifier!.value.error,
      );
      return;
    }

    // ดึง payment methods จาก couponDetail ตามภาษาปัจจุบัน
    final listPayment = couponDetailNotifier!.value.data!
        .paymentMethodsAvailable(context.languageCode);

    // ถ้าไม่มี payment method ให้เลือก
    if (listPayment.isEmpty) {
      _paymentMethodNotifier.value = UiResult.empty();
      return;
    }

    // Fetch ข้อมูล profile เพื่ออัพเดท credit balance (สำหรับ TP Wallet)
    final profileResult = await repoDelegate.fetchProfile('');
    if (profileResult.isEmpty || profileResult.isError) {
      _paymentMethodNotifier.value = UiResult.empty();
      return;
    }

    final userModel = UserModel.fromCustomerProfileData(
      profileResult.data.data,
    );
    // อัพเดทข้อมูล user ใหม่ใน provider
    currentCustomerProvider.newUser = userModel;

    // Copy list เพื่อไม่ให้กระทบ original
    var finalList = listPayment.toList();

    // ถ้ามีการเลือก payment ไว้แล้วก่อนหน้านี้
    if (_paymentSelected != null) {
      // หาตำแหน่งของ payment ที่เลือกไว้
      final selectedIndex = finalList.indexWhere(
        (e) => e.method == _paymentSelected!.method,
      );

      if (selectedIndex != -1) {
        // Mark ทั้งหมดเป็น unselected ก่อน
        finalList = finalList
            .map((e) => e.copyWith(isSelected: false))
            .toList();

        // เอาตัวที่เลือกออกจาก list
        final selected = finalList.removeAt(selectedIndex);

        // ใส่กลับไปที่ index 0 และ mark เป็น selected
        finalList.insert(0, selected.copyWith(isSelected: true));
      }
    } else {
      // ถ้ายังไม่เคยเลือก ให้เลือกตัวแรกเป็น default
      finalList = finalList.asMap().entries.map((entry) {
        // ตัวแรก (index 0) จะถูก mark เป็น selected
        return entry.value.copyWith(isSelected: entry.key == 0);
      }).toList();
      // เก็บตัวแรกไว้ใน _paymentSelected
      if (finalList.isNotEmpty) {
        _paymentSelected = finalList.first;
      }
    }

    // Update notifier พร้อมจำกัดจำนวนตามค่า fetchAll
    // fetchAll = true: ส่งทั้งหมด, false: ส่งแค่ 3 ตัว
    _paymentMethodNotifier.value = UiResult.success(
      data: finalList.take(fetchAll ? finalList.length : 3).toList(),
    );
  }

  /// เรียกเมื่อ User เลือก payment method
  ///
  /// [payment]: payment ที่เลือก
  /// [fetchAll]: true = อัพเดทแสดงทั้งหมด, false = แสดงแค่ 3 ตัว
  ///
  /// กลไก:
  /// - ดึง payment methods ทั้งหมดจาก couponDetail (ไม่ใช่จาก notifier เพราะอาจมีแค่ 3 ตัว)
  /// - เอา payment ที่เลือกมาไว้ index 0 และ mark เป็น selected
  /// - payment อื่นๆ จะถูก mark เป็น unselected
  void onPaymentChanged(
    PaymentMethodModel payment, {
    bool fetchAll = false,
  }) {
    // ตรวจสอบว่า couponDetail พร้อมใช้งาน
    if (!couponDetailNotifier!.value.isSuccess) return;

    // ดึง payment methods ทั้งหมดจาก couponDetail (ไม่ดึงจาก notifier เพราะอาจมีแค่ 3 ตัว)
    final fullList = couponDetailNotifier!.value.data!.paymentMethodsAvailable(
      context.languageCode,
    );

    // Mark ทุกตัวเป็น unselected ก่อน
    var newList = fullList.map((e) => e.copyWith(isSelected: false)).toList();

    // หาตำแหน่งของ payment ที่เลือก
    final selectedIndex = newList.indexWhere((e) => e.method == payment.method);

    if (selectedIndex != -1) {
      // เอา payment ที่เลือกออกจาก list
      final selected = newList.removeAt(selectedIndex);

      // ใส่กลับไปที่ index 0 และ mark เป็น selected
      newList.insert(0, selected.copyWith(isSelected: true));

      // เก็บค่าไว้ใน _paymentSelected เพื่อใช้ตอน fetch ครั้งถัดไป
      _paymentSelected = newList.first;
    }

    // Update notifier พร้อมจำกัดจำนวนตาม fetchAll
    // fetchAll = true: ส่งทั้งหมด (ใช้ใน available_payment_method_page)
    // fetchAll = false: ส่งแค่ 3 ตัว (ใช้ใน transaction_selected_page)
    _paymentMethodNotifier.value = UiResult.success(
      data: newList.take(fetchAll ? newList.length : 3).toList(),
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
          onCancel: () async {
            // User cancelled - fetch without location
            _showNearbyStoresNotifier.value = false;
            await fetchCouponPackageListDependsOn(currentLocation: null);
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

  void disposeTransaction() {
    _paymentMethodNotifier.value = UiResult.loading();
    _paymentSelected = null;
    _paymentSelectedBeforeEdit = null;
  }

  /// เริ่มต้นการแก้ไข payment method (เก็บค่าเดิมไว้สำหรับ cancel)
  void startEditingPaymentMethod() {
    _paymentSelectedBeforeEdit = _paymentSelected;
  }

  /// ยืนยันการเลือก payment method ใหม่ (ไม่ต้องทำอะไร เพราะค่าถูกเก็บไว้แล้วใน onPaymentChanged)
  void confirmPaymentMethodEdit() {
    _paymentSelectedBeforeEdit = null;
  }

  /// ยกเลิกการเลือก payment method - restore ค่าเดิมกลับมา
  Future<void> cancelPaymentMethodEdit(BuildContext context) async {
    if (_paymentSelectedBeforeEdit != null) {
      _paymentSelected = _paymentSelectedBeforeEdit;
      _paymentSelectedBeforeEdit = null;
      // Fetch ใหม่เพื่อให้ payment เดิมกลับมาเป็น index 0
      await fetchPaymentMethod(context, fetchAll: false);
    }
  }

  /// สร้างคำสั่งซื้อคูปอง
  ///
  /// Returns:
  /// - UiResult.success: สำเร็จ พร้อม CouponOrderResponse
  /// - UiResult.error: เกิด error
  /// - UiResult.empty: ไม่มี payment method ที่เลือก หรือ API ไม่สำเร็จ
  Future<UiResult<CouponOrderResponse>> createCouponOrder() async {
    // ตรวจสอบว่ามี payment method ที่เลือกหรือไม่
    if (_paymentSelected == null) {
      return UiResult.empty(
        error: Exception('กรุณาเลือกวิธีชำระเงิน'),
      );
    }

    // ตรวจสอบว่ามี customer ID หรือไม่
    final customerId = currentCustomerProvider.current.id;
    if (customerId == null || customerId.isEmpty) {
      return UiResult.error(
        error: Exception('ไม่พบข้อมูลผู้ใช้'),
      );
    }

    if (_selectedCoupon.data.packageId == null) {
      return UiResult.error(
        error: Exception(
          'เกิดข้อผิดพลาดในการสร้างคำสั่งซื้อ: ไม่พบ package id',
        ),
      );
    }

    try {
      // สร้าง request
      final request = CouponOrderRequest(
        customerId: customerId,
        couponPackageId: selectedPackageNotifier?.value?.packageId ?? 0,
        quantity: 1,
        paymentMethod: _paymentSelected!.method,
      );

      // เรียก API
      final result = await _transactionRepo.createCouponOrder(request);

      // Handle result
      if (result.isSuccess) {
        return UiResult.success(data: result.data);
      } else if (result.isEmpty) {
        return UiResult.empty(error: result.error);
      } else {
        return UiResult.error(error: result.error);
      }
    } catch (e) {
      return UiResult.error(
        error: Exception('เกิดข้อผิดพลาดในการสร้างคำสั่งซื้อ: ${e.toString()}'),
      );
    }
  }

  /// ตรวจสอบสถานะการชำระเงิน
  ///
  /// อัพเดท transaction state เป็น checkingPayment -> paymentSuccess
  ///
  /// Returns:
  /// - UiResult.success: สำเร็จ พร้อม PaymentStatusCheckResponse
  /// - UiResult.error: เกิด error
  /// - UiResult.empty: API ไม่สำเร็จ
  Future<UiResult<PaymentStatusCheckResponse>> checkPaymentStatus(
    CouponOrderData orderData,
  ) async {
    try {
      // อัพเดท state เป็น checking
      _transactionStateNotifier.value = UiResult.success(
        data: PaymentTransactionState.checkingPayment(),
      );

      final result = await _transactionRepo.checkPaymentStatus(orderData);

      if (result.isSuccess) {
        // อัพเดท state เป็น payment success
        _transactionStateNotifier.value = UiResult.success(
          data: PaymentTransactionState.paymentSuccess(result.data),
        );
        return UiResult.success(data: result.data);
      } else if (result.isEmpty) {
        _transactionStateNotifier.value = UiResult.success(
          data: PaymentTransactionState.error(
            result.error,
          ),
        );
        return UiResult.empty(error: result.error);
      } else {
        _transactionStateNotifier.value = UiResult.success(
          data: PaymentTransactionState.error(
            result.error,
          ),
        );
        return UiResult.error(error: result.error);
      }
    } catch (e) {
      final exception = Exception(
        'เกิดข้อผิดพลาดในการตรวจสอบสถานะ: ${e.toString()}',
      );
      _transactionStateNotifier.value = UiResult.success(
        data: PaymentTransactionState.error(exception),
      );
      return UiResult.error(error: exception);
    }
  }

  /// ดึงข้อมูลใบเสร็จคูปอง/e-voucher
  ///
  /// ใช้ orderId จาก transaction state ที่เก็บไว้
  /// อัพเดท transaction state เป็น loadingReceipt -> receiptLoaded
  ///
  /// Returns:
  /// - UiResult.success: สำเร็จ พร้อม CouponReceiptModel
  /// - UiResult.error: เกิด error
  /// - UiResult.empty: ไม่มี orderId หรือ API ไม่สำเร็จ
  Future<UiResult<CouponReceiptModel>> fetchCouponReceipt() async {
    final currentState = _transactionStateNotifier.value;

    // ตรวจสอบว่า state พร้อมดึงใบเสร็จหรือไม่
    if (!currentState.isSuccess || !currentState.data!.canFetchReceipt) {
      final error = Exception(
        'ไม่สามารถดึงใบเสร็จได้ กรุณาตรวจสอบสถานะการชำระเงินก่อน',
      );
      _transactionStateNotifier.value = UiResult.success(
        data: PaymentTransactionState.error(
          error,
          paymentStatus: currentState.data?.paymentStatus,
        ),
      );
      return UiResult.empty(error: error);
    }

    final state = currentState.data!;
    final orderId = state.orderId;

    // ตรวจสอบว่ามี orderId หรือไม่ (double check)
    if (orderId == null) {
      final error = Exception('ไม่พบ Order ID');
      _transactionStateNotifier.value = UiResult.success(
        data: PaymentTransactionState.error(
          error,
          paymentStatus: state.paymentStatus,
        ),
      );
      return UiResult.empty(error: error);
    }

    try {
      // อัพเดท state เป็น loading receipt
      _transactionStateNotifier.value = UiResult.success(
        data: PaymentTransactionState.loadingReceipt(state.paymentStatus!),
      );

      final result = await _transactionRepo.fetchCouponReceipt(
        orderId.toString(),
      );

      if (result.isSuccess) {
        final receiptModel = CouponReceiptModel.fromCouponReceiptData(
          result.data.data!,
        );

        // อัพเดท state เป็น receipt loaded (transaction complete)
        _transactionStateNotifier.value = UiResult.success(
          data: PaymentTransactionState.receiptLoaded(
            state.paymentStatus!,
            receiptModel,
          ),
        );

        return UiResult.success(data: receiptModel);
      } else if (result.isEmpty) {
        _transactionStateNotifier.value = UiResult.success(
          data: PaymentTransactionState.error(
            result.error,
            paymentStatus: state.paymentStatus,
          ),
        );
        return UiResult.empty(error: result.error);
      } else {
        _transactionStateNotifier.value = UiResult.success(
          data: PaymentTransactionState.error(
            result.error,
            paymentStatus: state.paymentStatus,
          ),
        );
        return UiResult.error(error: result.error);
      }
    } catch (e) {
      final exception = Exception(
        'เกิดข้อผิดพลาดในการดึงข้อมูลใบเสร็จ: ${e.toString()}',
      );
      _transactionStateNotifier.value = UiResult.success(
        data: PaymentTransactionState.error(
          exception,
          paymentStatus: state.paymentStatus,
        ),
      );
      return UiResult.error(error: exception);
    }
  }

  Future<UiResult<void>> verifyOrder() async {
    try {
      if (paymentSelected?.isTpWallet == true) {
        final result = await _couponRepo.fetchCustomerCredit(
          currentCustomerProvider.current.id!,
        );

        if (result.isEmpty || result.hasError) {
          try {
            return UiResult.error(
              error: Unprocessable(result.error.toString()),
            );
          } catch (_) {
            return UiResult.error(error: Unprocessable());
          }
        }
        // update ข้อมูล User ด้วย
        currentCustomerProvider.updateCreditAndCoinBalance(result.data);
        final tpWalletBalance = double.tryParse(
          result.data.creditBalance!.replaceAll(',', ''),
        )!;

        final packgaePrice = double.tryParse(
          selectedPackageNotifier!.value!.price!.replaceAll(',', ''),
        )!;
        if (tpWalletBalance >= packgaePrice) {
          return UiResult.success(data: null);
        }

        return UiResult.empty();
      } else {
        return UiResult.success(data: null);
      }
    } catch (e) {
      return UiResult.error(error: Unprocessable(e.toString()));
    }
  }
}
