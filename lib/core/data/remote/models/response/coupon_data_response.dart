import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'coupon_data_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// Base model สำหรับคูปองทุกประเภท (Redemption, Discount, E-Voucher)
@JsonSerializable()
class CouponData {
  // ฟิลด์ร่วมกันทุกประเภท
  @JsonKey(name: 'coupon_id')
  final int? couponId; // รองรับทั้ง int และ String

  @JsonKey(name: 'customer_coupon_id')
  final int? customerCouponId;

  @JsonKey(name: 'assigned_quantity')
  final String? assignedQuantity;

  @JsonKey(name: 'used_quantity')
  final String? usedQuantity;

  @JsonKey(name: 'remaining')
  final String? remaining;

  @JsonKey(name: 'expires_at')
  final String? expiresAt;

  @JsonKey(name: 'is_expired')
  final bool? isExpired;

  @JsonKey(name: 'is_available')
  final bool? isAvailable;

  @JsonKey(name: 'type_label')
  final ContentLocalizeData? typeLabel;

  @JsonKey(name: 'usage_label')
  final ContentLocalizeData? usageLabel;

  @JsonKey(name: 'icon')
  final String? icon;

  @JsonKey(name: 'package_name')
  final ContentLocalizeData? packageName;

  @JsonKey(name: 'description')
  final ContentLocalizeData? description;

  @JsonKey(name: 'image_url')
  final ContentLocalizeData? imageUrl;

  @JsonKey(name: 'store')
  final CouponStoreData? store;

  @JsonKey(name: 'qty_washer')
  final String? qtyWasher;

  @JsonKey(name: 'qty_dryer')
  final String? qtyDryer;

  @JsonKey(name: 'remain_washer')
  final String? remainWasher;

  @JsonKey(name: 'remain_dryer')
  final String? remainDryer;

  // ฟิลด์พิเศษสำหรับ Discount
  @JsonKey(name: 'total_uses')
  final String? totalUses;

  // ฟิลด์พิเศษสำหรับ Redemption
  @JsonKey(name: 'redemption_limit')
  final String? redemptionLimit;

  @JsonKey(name: 'redeem_price')
  final String? redeemPrice;

  @JsonKey(name: 'delivery_fee')
  final String? deliveryFee;

  CouponData({
    this.couponId,
    this.customerCouponId,
    this.assignedQuantity,
    this.usedQuantity,
    this.remaining,
    this.expiresAt,
    this.isExpired,
    this.isAvailable,
    this.typeLabel,
    this.usageLabel,
    this.icon,
    this.packageName,
    this.description,
    this.imageUrl,
    this.store,
    this.qtyWasher,
    this.qtyDryer,
    this.remainWasher,
    this.remainDryer,
    this.totalUses,
    this.redemptionLimit,
    this.redeemPrice,
    this.deliveryFee,
  });

  factory CouponData.fromJson(Map<String, dynamic> json) =>
      _$CouponDataFromJson(json);

  Map<String, dynamic> toJson() => _$CouponDataToJson(this);

  /// Helper: แปลง couponId เป็น String
  String get couponIdString => couponId?.toString() ?? '';

  /// Helper: แปลง couponId เป็น int
  int? get couponIdInt {
    if (couponId is int) return couponId as int;
    if (couponId is String) return int.tryParse(couponId as String);
    return null;
  }

  /// Helper: แปลง customerCouponId เป็น String
  String get customerCouponIdString => customerCouponId?.toString() ?? '';

  /// Helper: แปลง customerCouponId เป็น int
  int? get customerCouponIdInt {
    if (customerCouponId is int) return customerCouponId as int;
    if (customerCouponId is String)
      return int.tryParse(customerCouponId as String);
    return null;
  }
}

/// Store data สำหรับคูปอง
@JsonSerializable()
class CouponStoreData {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  CouponStoreData({
    this.id,
    this.name,
  });

  factory CouponStoreData.fromJson(Map<String, dynamic> json) =>
      _$CouponStoreDataFromJson(json);

  Map<String, dynamic> toJson() => _$CouponStoreDataToJson(this);
}

/// Response สำหรับคูปองแลกซื้อ
@JsonSerializable()
class CouponRedemptionResponse {
  @JsonKey(name: 'data')
  final List<CouponData>? data;

  CouponRedemptionResponse({this.data});

  factory CouponRedemptionResponse.fromJson(Map<String, dynamic> json) =>
      _$CouponRedemptionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CouponRedemptionResponseToJson(this);
}

/// Response สำหรับคูปองส่วนลด
@JsonSerializable()
class CouponDiscountResponse {
  @JsonKey(name: 'data')
  final List<CouponData>? data;

  CouponDiscountResponse({this.data});

  factory CouponDiscountResponse.fromJson(Map<String, dynamic> json) =>
      _$CouponDiscountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CouponDiscountResponseToJson(this);
}

/// Response สำหรับ E-Voucher
@JsonSerializable()
class CouponEVoucherResponse {
  @JsonKey(name: 'data')
  final List<CouponData>? data;

  CouponEVoucherResponse({this.data});

  factory CouponEVoucherResponse.fromJson(Map<String, dynamic> json) =>
      _$CouponEVoucherResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CouponEVoucherResponseToJson(this);
}
