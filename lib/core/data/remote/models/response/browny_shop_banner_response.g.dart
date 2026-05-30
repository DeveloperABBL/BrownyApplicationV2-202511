// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browny_shop_banner_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrownyShopBannerResponse _$BrownyShopBannerResponseFromJson(
  Map<String, dynamic> json,
) => BrownyShopBannerResponse(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  errorType: json['error_type'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => BrownyShopBannerData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BrownyShopBannerResponseToJson(
  BrownyShopBannerResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'data': instance.data,
};

BrownyShopBannerData _$BrownyShopBannerDataFromJson(
  Map<String, dynamic> json,
) => BrownyShopBannerData(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String?,
  imageUrl: json['image_url'] as String?,
  firstLoginOnly: json['first_login_only'] as bool?,
  startAt: const DateTimeConverter().fromJson(json['start_at'] as String?),
  endAt: const DateTimeConverter().fromJson(json['end_at'] as String?),
  sortOrder: (json['sort_order'] as num?)?.toInt(),
);

Map<String, dynamic> _$BrownyShopBannerDataToJson(
  BrownyShopBannerData instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'image_url': instance.imageUrl,
  'first_login_only': instance.firstLoginOnly,
  'start_at': const DateTimeConverter().toJson(instance.startAt),
  'end_at': const DateTimeConverter().toJson(instance.endAt),
  'sort_order': instance.sortOrder,
};
