import 'package:json_annotation/json_annotation.dart';

part 'checkout_draft_request.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-26
///
/// Body request สำหรับ POST /browny-shop/checkout/draft — สร้างใบสั่งซื้อ draft
@JsonSerializable()
class CheckoutDraftRequest {
  CheckoutDraftRequest({
    required this.customerId,
    this.couponCustomerId,
    required this.paymentMethod,
  });

  @JsonKey(name: 'customer_id')
  final String customerId;

  /// id ของคูปองที่ใช้ — null ถ้าไม่ได้ใช้คูปอง
  @JsonKey(name: 'coupon_customer_id')
  final int? couponCustomerId;

  /// วิธีการชำระเงิน เช่น "qr", "tp_wallet", "coin"
  @JsonKey(name: 'payment_method')
  final String paymentMethod;

  factory CheckoutDraftRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckoutDraftRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CheckoutDraftRequestToJson(this);
}
