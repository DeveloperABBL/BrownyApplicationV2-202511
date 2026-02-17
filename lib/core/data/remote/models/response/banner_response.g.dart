// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BannerResponse _$BannerResponseFromJson(Map<String, dynamic> json) =>
    BannerResponse(
      success: json['success'] as bool?,
      errorType: json['error_type'] as String?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => BannerData.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => CategoryData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BannerResponseToJson(BannerResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'error_type': instance.errorType,
      'data': instance.data,
      'categories': instance.categories,
    };

BannerData _$BannerDataFromJson(Map<String, dynamic> json) => BannerData(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  type: json['type'] as String?,
  target: json['target'] as String?,
  category: json['category'] == null
      ? null
      : CategoryData.fromJson(json['category'] as Map<String, dynamic>),
  image: json['image'] == null
      ? null
      : ContentLocalizeData.fromJson(json['image'] as Map<String, dynamic>),
  title: json['title'] == null
      ? null
      : ContentLocalizeData.fromJson(json['title'] as Map<String, dynamic>),
  subtitle: json['subtitle'] == null
      ? null
      : ContentLocalizeData.fromJson(json['subtitle'] as Map<String, dynamic>),
  dateTime: const DateTimeConverter().fromJson(json['date_time'] as String?),
);

Map<String, dynamic> _$BannerDataToJson(BannerData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'target': instance.target,
      'category': instance.category,
      'image': instance.image,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'date_time': const DateTimeConverter().toJson(instance.dateTime),
    };

CategoryData _$CategoryDataFromJson(Map<String, dynamic> json) => CategoryData(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] == null
      ? null
      : ContentLocalizeData.fromJson(json['name'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CategoryDataToJson(CategoryData instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
