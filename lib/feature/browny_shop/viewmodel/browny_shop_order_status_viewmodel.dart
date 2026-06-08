import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/browny_shop_order_detail_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/checkout_draft_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/payment_status_check_response.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:flutter/foundation.dart';

/// ViewModel หน้าสถานะคำสั่งซื้อ Browny Shop ([BrownyShopOrderStatusPage])
///
/// รับ [orderId] เพื่อ fetch รายละเอียด/สถานะคำสั่งซื้อ (GET /browny-shop/orders/
/// {orderId}) — กรณีสถานะ pending_payment เปิดให้กลับเข้า process ชำระเงินได้
/// ([fetchPendingOrder] + [checkPaymentStatus])
class BrownyShopOrderStatusViewModel extends AppViewModel {
  BrownyShopOrderStatusViewModel({
    required super.context,
    required BrownyShopDataSourceMixin repo,
    required this.orderId,
  }) : _repo = repo {
    fetchOrderDetail();
  }

  final BrownyShopDataSourceMixin _repo;

  /// id คำสั่งซื้อ — ใช้ fetch สถานะ + กลับเข้า process ชำระเงิน
  final String orderId;

  final _statusNotifier = ValueNotifier<UiResult<BrownyShopOrderDetailData>>(
    UiResult.loading(),
  );
  ValueListenable<UiResult<BrownyShopOrderDetailData>> get statusNotifier =>
      _statusNotifier;

  String get _customerId => kDebugMode
      ? '019e81e8-61ab-7395-92cb-b075c9828efc'
      : currentCustomerProvider.current.id.orEmpty;

  /// โหลดรายละเอียด/สถานะคำสั่งซื้อ — GET /browny-shop/orders/{orderId}
  Future<void> fetchOrderDetail() async {
    _statusNotifier.value = UiResult.loading();
    final result = await _repo.fetchOrderDetail(
      orderId: orderId,
      customerId: _customerId,
    );
    if (result.isSuccess) {
      _statusNotifier.value = UiResult.success(data: result.data);
    } else if (result.isEmpty) {
      _statusNotifier.value = UiResult.empty();
    } else {
      _statusNotifier.value = UiResult.error(error: result.error);
    }
  }

  /// GET /browny-shop/checkout/{orderId} — ดึง order ที่รอชำระ (response_payload/
  /// payment_url) เพื่อกลับเข้า process ชำระเงินจากปุ่ม "ชำระเงิน"
  Future<UiResult<CheckoutDraftData>> fetchPendingOrder() async {
    final result = await _repo.fetchPendingOrder(
      orderId: orderId,
      customerId: _customerId,
    );
    if (result.isSuccess) return UiResult.success(data: result.data);
    return UiResult.error(error: result.error);
  }

  /// GET /payment/browny-shop/status/{paymentRef} — polling สถานะการชำระเงิน
  Future<UiResult<PaymentStatusCheckResponse>> checkPaymentStatus(
    String paymentRef,
  ) async {
    final result = await _repo.checkPaymentStatus(paymentRef: paymentRef);
    if (result.isSuccess) return UiResult.success(data: result.data);
    return UiResult.error(error: result.error);
  }

  @override
  void dispose() {
    _statusNotifier.dispose();
    super.dispose();
  }
}
