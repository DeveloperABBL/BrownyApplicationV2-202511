// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_add_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItemAddRequest _$CartItemAddRequestFromJson(Map<String, dynamic> json) =>
    CartItemAddRequest(
      productId: json['product_id'] as String,
      productSubId: (json['product_sub_id'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$CartItemAddRequestToJson(CartItemAddRequest instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'product_sub_id': instance.productSubId,
      'quantity': instance.quantity,
    };
