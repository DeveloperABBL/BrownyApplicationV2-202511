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

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

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

  @JsonKey(name: 'qty_total')
  final String? qtyTotal;

  @JsonKey(name: 'qty_shared')
  final String? qtyShared;

  @JsonKey(name: 'remain_washer')
  final String? remainWasher;

  @JsonKey(name: 'remain_dryer')
  final String? remainDryer;

  @JsonKey(name: 'remain_total')
  final String? remainTotal;

  @JsonKey(name: 'remain_shared')
  final String? remainShared;

  @JsonKey(name: 'usage_mode')
  final String? usageMode;

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

  @JsonKey(name: 'applies_to')
  final String? appliesTo;

  // ฟิลด์พิเศษสำหรับ Browny Shop coupon
  /// "product" / "shipping" — เป้าหมายของส่วนลด
  @JsonKey(name: 'discount_target')
  final String? discountTarget;

  /// "fixed" / "percent" — ประเภทส่วนลด
  @JsonKey(name: 'discount_type')
  final String? discountType;

  /// มูลค่าส่วนลด (เช่น "50.00" สำหรับ fixed, "10.00" สำหรับ percent)
  @JsonKey(name: 'value')
  final String? value;

  /// เพดานส่วนลด (เฉพาะ discount_type = percent) — null = ไม่จำกัด
  @JsonKey(name: 'max_discount')
  final String? maxDiscount;

  /// ยอดสั่งซื้อขั้นต่ำที่ใช้คูปองได้
  @JsonKey(name: 'min_order_amount')
  final String? minOrderAmount;

  /// ใช้คู่กับโปรโมชั่นอื่นได้หรือไม่ (เช่น Flash Sale)
  @JsonKey(name: 'allow_with_promotion')
  final bool? allowWithPromotion;

  /// ใช้คู่กับส่วนลดสินค้าได้หรือไม่
  @JsonKey(name: 'allow_with_product_discount')
  final bool? allowWithProductDiscount;

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
    this.name,
    this.packageName,
    this.description,
    this.imageUrl,
    this.store,
    this.qtyWasher,
    this.qtyDryer,
    this.qtyTotal,
    this.qtyShared,
    this.remainWasher,
    this.remainDryer,
    this.remainTotal,
    this.remainShared,
    this.usageMode,
    this.totalUses,
    this.redemptionLimit,
    this.redeemPrice,
    this.deliveryFee,
    this.appliesTo,
    this.discountTarget,
    this.discountType,
    this.value,
    this.maxDiscount,
    this.minOrderAmount,
    this.allowWithPromotion,
    this.allowWithProductDiscount,
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
    if (customerCouponId is String) {
      return int.tryParse(customerCouponId as String);
    }
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

/// Response สำหรับคูปอง Browny Shop ของลูกค้า
@JsonSerializable()
class CouponBrownyShopResponse {
  @JsonKey(name: 'data')
  final List<CouponData>? data;

  CouponBrownyShopResponse({this.data});

  factory CouponBrownyShopResponse.fromJson(Map<String, dynamic> json) =>
      _$CouponBrownyShopResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CouponBrownyShopResponseToJson(this);
}
