// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_order_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CouponOrderRequest _$CouponOrderRequestFromJson(Map<String, dynamic> json) =>
    CouponOrderRequest(
      customerId: json['customer_id'] as String,
      couponPackageId: (json['coupon_package_id'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      paymentMethod: json['payment_method'] as String,
      useCoin: json['use_coin'] as bool?,
    );

Map<String, dynamic> _$CouponOrderRequestToJson(CouponOrderRequest instance) =>
    <String, dynamic>{
      'customer_id': instance.customerId,
      'coupon_package_id': instance.couponPackageId,
      'quantity': instance.quantity,
      'payment_method': instance.paymentMethod,
      'use_coin': ?instance.useCoin,
    };
