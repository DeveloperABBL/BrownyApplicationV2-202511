// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_collect_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CouponCollectResponse _$CouponCollectResponseFromJson(
  Map<String, dynamic> json,
) => CouponCollectResponse(
  message: json['message'] as String,
  couponCustomer: json['coupon_customer'] == null
      ? null
      : CouponCustomerData.fromJson(
          json['coupon_customer'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$CouponCollectResponseToJson(
  CouponCollectResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'coupon_customer': instance.couponCustomer,
};

CouponCustomerData _$CouponCustomerDataFromJson(Map<String, dynamic> json) =>
    CouponCustomerData(
      customerId: json['customer_id'] as String,
      couponId: (json['coupon_id'] as num).toInt(),
      couponDiscountId: (json['coupon_discount_id'] as num?)?.toInt(),
      couponCodeId: (json['coupon_code_id'] as num?)?.toInt(),
      quantity: (json['quantity'] as num).toInt(),
      remaining: (json['remaining'] as num).toInt(),
      assignedAt: json['assigned_at'] as String,
      usedAt: json['used_at'] as String?,
      expiresAt: json['expires_at'] as String,
      source: json['source'] as String,
      updatedAt: json['updated_at'] as String,
      createdAt: json['created_at'] as String,
      id: (json['id'] as num).toInt(),
    );

Map<String, dynamic> _$CouponCustomerDataToJson(CouponCustomerData instance) =>
    <String, dynamic>{
      'customer_id': instance.customerId,
      'coupon_id': instance.couponId,
      'coupon_discount_id': instance.couponDiscountId,
      'coupon_code_id': instance.couponCodeId,
      'quantity': instance.quantity,
      'remaining': instance.remaining,
      'assigned_at': instance.assignedAt,
      'used_at': instance.usedAt,
      'expires_at': instance.expiresAt,
      'source': instance.source,
      'updated_at': instance.updatedAt,
      'created_at': instance.createdAt,
      'id': instance.id,
    };
