// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browny_shop_title_image_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrownyShopTitleImageResponse _$BrownyShopTitleImageResponseFromJson(
  Map<String, dynamic> json,
) => BrownyShopTitleImageResponse(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  errorType: json['error_type'] as String?,
  data: json['data'] == null
      ? null
      : BrownyShopTitleImageData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BrownyShopTitleImageResponseToJson(
  BrownyShopTitleImageResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'data': instance.data,
};

BrownyShopTitleImageData _$BrownyShopTitleImageDataFromJson(
  Map<String, dynamic> json,
) => BrownyShopTitleImageData(imageUrl: json['image_url'] as String?);

Map<String, dynamic> _$BrownyShopTitleImageDataToJson(
  BrownyShopTitleImageData instance,
) => <String, dynamic>{'image_url': instance.imageUrl};
