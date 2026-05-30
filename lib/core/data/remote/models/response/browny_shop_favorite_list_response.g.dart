// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browny_shop_favorite_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrownyShopFavoriteListResponse _$BrownyShopFavoriteListResponseFromJson(
  Map<String, dynamic> json,
) => BrownyShopFavoriteListResponse(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  errorType: json['error_type'] as String?,
  data: json['data'] == null
      ? null
      : BrownyShopFavoriteListData.fromJson(
          json['data'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$BrownyShopFavoriteListResponseToJson(
  BrownyShopFavoriteListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'data': instance.data,
};

BrownyShopFavoriteListData _$BrownyShopFavoriteListDataFromJson(
  Map<String, dynamic> json,
) => BrownyShopFavoriteListData(
  customerId: json['customer_id'] as String?,
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => ProductData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BrownyShopFavoriteListDataToJson(
  BrownyShopFavoriteListData instance,
) => <String, dynamic>{
  'customer_id': instance.customerId,
  'items': instance.items,
};
