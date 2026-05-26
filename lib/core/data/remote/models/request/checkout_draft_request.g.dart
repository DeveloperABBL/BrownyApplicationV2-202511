// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_draft_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckoutDraftRequest _$CheckoutDraftRequestFromJson(
  Map<String, dynamic> json,
) => CheckoutDraftRequest(
  customerId: json['customer_id'] as String,
  couponCustomerId: (json['coupon_customer_id'] as num?)?.toInt(),
  paymentMethod: json['payment_method'] as String,
);

Map<String, dynamic> _$CheckoutDraftRequestToJson(
  CheckoutDraftRequest instance,
) => <String, dynamic>{
  'customer_id': instance.customerId,
  'coupon_customer_id': instance.couponCustomerId,
  'payment_method': instance.paymentMethod,
};
