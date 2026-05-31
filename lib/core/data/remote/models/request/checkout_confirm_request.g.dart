// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_confirm_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckoutConfirmRequest _$CheckoutConfirmRequestFromJson(
  Map<String, dynamic> json,
) => CheckoutConfirmRequest(
  customerId: json['customer_id'] as String,
  customerAddressId: (json['customer_address_id'] as num).toInt(),
  paymentMethod: json['payment_method'] as String?,
  couponCustomerId: (json['coupon_customer_id'] as num?)?.toInt(),
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => CartSummaryItemRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CheckoutConfirmRequestToJson(
  CheckoutConfirmRequest instance,
) => <String, dynamic>{
  'customer_id': instance.customerId,
  'customer_address_id': instance.customerAddressId,
  'payment_method': ?instance.paymentMethod,
  'coupon_customer_id': ?instance.couponCustomerId,
  'items': ?instance.items,
};
