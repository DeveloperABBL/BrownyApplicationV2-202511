import 'package:json_annotation/json_annotation.dart';

part 'checkout_confirm_request.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-30
///
/// Body request สำหรับยืนยันคำสั่งซื้อ Browny Shop — ใช้ได้ทั้ง 2 endpoint:
/// - `POST /browny-shop/checkout/confirm` (แนะนำ) — ส่งครบ customer_id,
///   payment_method, customer_address_id (+ coupon_customer_id ถ้ามี)
/// - `POST /browny-shop/checkout/{orderId}/confirm` (legacy) — ส่งแค่
///   customer_id + customer_address_id (coupon/payment อยู่ใน order แล้ว)
///
/// field ที่เป็น null จะไม่ถูกส่ง (includeIfNull: false)
@JsonSerializable(includeIfNull: false)
class CheckoutConfirmRequest {
  CheckoutConfirmRequest({
    required this.customerId,
    required this.customerAddressId,
    this.paymentMethod,
    this.couponCustomerId,
  });

  /// UUID ลูกค้า — ใช้ verify ownership
  @JsonKey(name: 'customer_id')
  final String customerId;

  /// id ของที่อยู่จัดส่งที่ลูกค้าเลือก
  @JsonKey(name: 'customer_address_id')
  final int customerAddressId;

  /// วิธีการชำระเงิน เช่น "qr", "wechat", "coin", "tp_wallet"
  /// (จำเป็นสำหรับ POST /checkout/confirm)
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;

  /// id ของคูปองที่ใช้ — null = ไม่ใช้คูปอง
  @JsonKey(name: 'coupon_customer_id')
  final int? couponCustomerId;

  factory CheckoutConfirmRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckoutConfirmRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CheckoutConfirmRequestToJson(this);
}
