import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'browny_shop_pending_payment_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-30
///
/// Response สำหรับ GET /browny-shop/pending-payment
/// — เช็คว่าลูกค้ามีคำสั่งซื้อรอชำระเงินล่าสุดค้างอยู่ไหม (ตอนเปิดแอป)
/// ได้ order_id แล้วเรียก GET /browny-shop/checkout/{orderId} ต่อเพื่อดึง QR เต็ม
@JsonSerializable()
class BrownyShopPendingPaymentResponse extends BaseModelResponse {
  BrownyShopPendingPaymentResponse({
    super.success,
    super.message,
    super.errorType,
    this.data,
  });

  @JsonKey(name: 'data')
  final BrownyShopPendingPaymentData? data;

  factory BrownyShopPendingPaymentResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$BrownyShopPendingPaymentResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      baseToJson(_$BrownyShopPendingPaymentResponseToJson(this));
}

@JsonSerializable()
class BrownyShopPendingPaymentData {
  BrownyShopPendingPaymentData({
    this.hasPending,
    this.orderId,
    this.paymentRef,
    this.status,
  });

  /// true = มี order รอชำระ, false = ไม่มี (field order_* จะเป็น null)
  @JsonKey(name: 'has_pending')
  final bool? hasPending;

  @JsonKey(name: 'order_id')
  final String? orderId;

  @JsonKey(name: 'payment_ref')
  final String? paymentRef;

  @JsonKey(name: 'status')
  final String? status;

  factory BrownyShopPendingPaymentData.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopPendingPaymentDataFromJson(json);

  Map<String, dynamic> toJson() =>
      _$BrownyShopPendingPaymentDataToJson(this);
}
