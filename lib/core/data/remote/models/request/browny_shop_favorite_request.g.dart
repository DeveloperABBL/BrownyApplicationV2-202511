// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browny_shop_favorite_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrownyShopFavoriteRequest _$BrownyShopFavoriteRequestFromJson(
  Map<String, dynamic> json,
) => BrownyShopFavoriteRequest(
  customerId: json['customer_id'] as String,
  productId: json['product_id'] as String,
);

Map<String, dynamic> _$BrownyShopFavoriteRequestToJson(
  BrownyShopFavoriteRequest instance,
) => <String, dynamic>{
  'customer_id': instance.customerId,
  'product_id': instance.productId,
};
