import 'package:json_annotation/json_annotation.dart';

part 'checkout_update_request.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-26
///
/// Body request สำหรับ PATCH /browny-shop/checkout/{orderId}
/// — แก้ไข draft order ที่มีอยู่ (เปลี่ยนคูปอง / วิธีชำระเงิน)
///
/// ทั้ง 2 field nullable — `null` = ไม่ใช้คูปอง / ไม่กำหนดวิธีชำระเงินตอนนี้
@JsonSerializable()
class CheckoutUpdateRequest {
  CheckoutUpdateRequest({
    this.couponCustomerId,
    this.paymentMethod,
  });

  /// id ของคูปองที่ใช้ — null = ไม่ใช้/ยกเลิกคูปอง
  @JsonKey(name: 'coupon_customer_id')
  final int? couponCustomerId;

  /// วิธีการชำระเงิน เช่น "qr", "tp_wallet", "coin"
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;

  factory CheckoutUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckoutUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CheckoutUpdateRequestToJson(this);
}
