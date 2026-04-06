import 'package:json_annotation/json_annotation.dart';

part 'coupon_collect_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// Response model สำหรับ collect coupon
@JsonSerializable()
class CouponCollectResponse {
  /// ข้อความแสดงผลลัพธ์
  @JsonKey(name: 'message')
  final String message;

  /// ข้อมูล coupon ที่ collect สำเร็จ
  @JsonKey(name: 'coupon_customer')
  final CouponCustomerData? couponCustomer;

  CouponCollectResponse({
    required this.message,
    this.couponCustomer,
  });

  factory CouponCollectResponse.fromJson(Map<String, dynamic> json) =>
      _$CouponCollectResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CouponCollectResponseToJson(this);
}

/// ข้อมูล coupon ที่ลูกค้าได้รับ
@JsonSerializable()
class CouponCustomerData {
  /// รหัสลูกค้า (UUID)
  @JsonKey(name: 'customer_id')
  final String customerId;

  /// รหัส coupon
  @JsonKey(name: 'coupon_id')
  final int couponId;

  /// รหัส discount coupon
  @JsonKey(name: 'coupon_discount_id')
  final int? couponDiscountId;

  /// รหัส coupon code
  @JsonKey(name: 'coupon_code_id')
  final int? couponCodeId;

  /// จำนวนที่ได้รับ
  @JsonKey(name: 'quantity')
  final int quantity;

  /// จำนวนที่เหลือ
  @JsonKey(name: 'remaining')
  final int remaining;

  /// วันที่ได้รับ coupon
  @JsonKey(name: 'assigned_at')
  final String assignedAt;

  /// วันที่ใช้ coupon (nullable)
  @JsonKey(name: 'used_at')
  final String? usedAt;

  /// วันที่หมดอายุ
  @JsonKey(name: 'expires_at')
  final String expiresAt;

  /// แหล่งที่มา (manual_code, qr_code, etc.)
  @JsonKey(name: 'source')
  final String source;

  /// วันที่อัพเดทล่าสุด
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  /// วันที่สร้าง
  @JsonKey(name: 'created_at')
  final String createdAt;

  /// รหัส customer coupon
  @JsonKey(name: 'id')
  final int id;

  CouponCustomerData({
    required this.customerId,
    required this.couponId,
    this.couponDiscountId,
    this.couponCodeId,
    required this.quantity,
    required this.remaining,
    required this.assignedAt,
    this.usedAt,
    required this.expiresAt,
    required this.source,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory CouponCustomerData.fromJson(Map<String, dynamic> json) =>
      _$CouponCustomerDataFromJson(json);

  Map<String, dynamic> toJson() => _$CouponCustomerDataToJson(this);
}
