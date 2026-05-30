// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browny_shop_favorite_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrownyShopFavoriteResponse _$BrownyShopFavoriteResponseFromJson(
  Map<String, dynamic> json,
) => BrownyShopFavoriteResponse(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  errorType: json['error_type'] as String?,
  data: json['data'] == null
      ? null
      : BrownyShopFavoriteData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BrownyShopFavoriteResponseToJson(
  BrownyShopFavoriteResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'data': instance.data,
};

BrownyShopFavoriteData _$BrownyShopFavoriteDataFromJson(
  Map<String, dynamic> json,
) => BrownyShopFavoriteData(
  customerId: json['customer_id'] as String?,
  productId: json['product_id'] as String?,
  favoriteStatus: json['favorite_status'] as bool?,
);

Map<String, dynamic> _$BrownyShopFavoriteDataToJson(
  BrownyShopFavoriteData instance,
) => <String, dynamic>{
  'customer_id': instance.customerId,
  'product_id': instance.productId,
  'favorite_status': instance.favoriteStatus,
};
