// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_summary_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartSummaryRequest _$CartSummaryRequestFromJson(Map<String, dynamic> json) =>
    CartSummaryRequest(
      customerId: json['customer_id'] as String,
      items: (json['items'] as List<dynamic>)
          .map(
            (e) => CartSummaryItemRequest.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      couponCustomerId: (json['coupon_customer_id'] as num?)?.toInt(),
      paymentMethod: json['payment_method'] as String?,
      customerAddressId: (json['customer_address_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CartSummaryRequestToJson(CartSummaryRequest instance) =>
    <String, dynamic>{
      'customer_id': instance.customerId,
      'coupon_customer_id': ?instance.couponCustomerId,
      'customer_address_id': ?instance.customerAddressId,
      'payment_method': ?instance.paymentMethod,
      'items': instance.items,
    };

CartSummaryItemRequest _$CartSummaryItemRequestFromJson(
  Map<String, dynamic> json,
) => CartSummaryItemRequest(
  productSubId: (json['product_sub_id'] as num).toInt(),
  quantity: (json['quantity'] as num).toInt(),
);

Map<String, dynamic> _$CartSummaryItemRequestToJson(
  CartSummaryItemRequest instance,
) => <String, dynamic>{
  'product_sub_id': instance.productSubId,
  'quantity': instance.quantity,
};
