// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_data_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CouponData _$CouponDataFromJson(Map<String, dynamic> json) => CouponData(
  couponId: json['coupon_id'],
  customerCouponId: json['customer_coupon_id'],
  assignedQuantity: json['assigned_quantity'] as String?,
  usedQuantity: json['used_quantity'] as String?,
  remaining: json['remaining'] as String?,
  expiresAt: json['expires_at'] as String?,
  isExpired: json['is_expired'] as bool?,
  isAvailable: json['is_available'] as bool?,
  typeLabel: json['type_label'] == null
      ? null
      : ContentLocalizeData.fromJson(
          json['type_label'] as Map<String, dynamic>,
        ),
  usageLabel: json['usage_label'] == null
      ? null
      : ContentLocalizeData.fromJson(
          json['usage_label'] as Map<String, dynamic>,
        ),
  icon: json['icon'] as String?,
  packageName: json['package_name'] == null
      ? null
      : ContentLocalizeData.fromJson(
          json['package_name'] as Map<String, dynamic>,
        ),
  description: json['description'] == null
      ? null
      : ContentLocalizeData.fromJson(
          json['description'] as Map<String, dynamic>,
        ),
  imageUrl: json['image_url'] == null
      ? null
      : ContentLocalizeData.fromJson(json['image_url'] as Map<String, dynamic>),
  store: json['store'] == null
      ? null
      : CouponStoreData.fromJson(json['store'] as Map<String, dynamic>),
  qtyWasher: json['qty_washer'] as String?,
  qtyDryer: json['qty_dryer'] as String?,
  remainWasher: json['remain_washer'] as String?,
  remainDryer: json['remain_dryer'] as String?,
  totalUses: json['total_uses'] as String?,
  redemptionLimit: json['redemption_limit'] as String?,
  redeemPrice: json['redeem_price'] as String?,
  deliveryFee: json['delivery_fee'] as String?,
);

Map<String, dynamic> _$CouponDataToJson(CouponData instance) =>
    <String, dynamic>{
      'coupon_id': instance.couponId,
      'customer_coupon_id': instance.customerCouponId,
      'assigned_quantity': instance.assignedQuantity,
      'used_quantity': instance.usedQuantity,
      'remaining': instance.remaining,
      'expires_at': instance.expiresAt,
      'is_expired': instance.isExpired,
      'is_available': instance.isAvailable,
      'type_label': instance.typeLabel,
      'usage_label': instance.usageLabel,
      'icon': instance.icon,
      'package_name': instance.packageName,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'store': instance.store,
      'qty_washer': instance.qtyWasher,
      'qty_dryer': instance.qtyDryer,
      'remain_washer': instance.remainWasher,
      'remain_dryer': instance.remainDryer,
      'total_uses': instance.totalUses,
      'redemption_limit': instance.redemptionLimit,
      'redeem_price': instance.redeemPrice,
      'delivery_fee': instance.deliveryFee,
    };

CouponStoreData _$CouponStoreDataFromJson(Map<String, dynamic> json) =>
    CouponStoreData(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] == null
          ? null
          : ContentLocalizeData.fromJson(json['name'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CouponStoreDataToJson(CouponStoreData instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

CouponRedemptionResponse _$CouponRedemptionResponseFromJson(
  Map<String, dynamic> json,
) => CouponRedemptionResponse(
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => CouponData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CouponRedemptionResponseToJson(
  CouponRedemptionResponse instance,
) => <String, dynamic>{'data': instance.data};

CouponDiscountResponse _$CouponDiscountResponseFromJson(
  Map<String, dynamic> json,
) => CouponDiscountResponse(
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => CouponData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CouponDiscountResponseToJson(
  CouponDiscountResponse instance,
) => <String, dynamic>{'data': instance.data};

CouponEVoucherResponse _$CouponEVoucherResponseFromJson(
  Map<String, dynamic> json,
) => CouponEVoucherResponse(
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => CouponData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CouponEVoucherResponseToJson(
  CouponEVoucherResponse instance,
) => <String, dynamic>{'data': instance.data};
