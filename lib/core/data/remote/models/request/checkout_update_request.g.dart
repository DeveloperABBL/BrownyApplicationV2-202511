// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckoutUpdateRequest _$CheckoutUpdateRequestFromJson(
  Map<String, dynamic> json,
) => CheckoutUpdateRequest(
  couponCustomerId: (json['coupon_customer_id'] as num?)?.toInt(),
  paymentMethod: json['payment_method'] as String?,
);

Map<String, dynamic> _$CheckoutUpdateRequestToJson(
  CheckoutUpdateRequest instance,
) => <String, dynamic>{
  'coupon_customer_id': instance.couponCustomerId,
  'payment_method': instance.paymentMethod,
};
