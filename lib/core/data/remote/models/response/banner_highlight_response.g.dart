// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_highlight_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BannerHighlightResponse _$BannerHighlightResponseFromJson(
  Map<String, dynamic> json,
) => BannerHighlightResponse(
  success: json['success'] as bool?,
  errorType: json['error_type'] as String?,
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => BannerHighlightData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BannerHighlightResponseToJson(
  BannerHighlightResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'data': instance.data,
};

BannerHighlightData _$BannerHighlightDataFromJson(
  Map<String, dynamic> json,
) => BannerHighlightData(
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

Map<String, dynamic> _$BannerHighlightDataToJson(
  BannerHighlightData instance,
) => <String, dynamic>{
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
