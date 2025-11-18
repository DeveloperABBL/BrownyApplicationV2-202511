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
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      type: json['type'] as String?,
      target: json['target'] as String?,
      image: json['image'] == null
          ? null
          : ContentLocalizeData.fromJson(json['image'] as Map<String, dynamic>),
      title: json['title'] == null
          ? null
          : ContentLocalizeData.fromJson(json['title'] as Map<String, dynamic>),
      subtitle: json['subtitle'] == null
          ? null
          : ContentLocalizeData.fromJson(
              json['subtitle'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$BannerResponseToJson(BannerResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'error_type': instance.errorType,
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'target': instance.target,
      'image': instance.image?.toJson(),
      'title': instance.title?.toJson(),
      'subtitle': instance.subtitle?.toJson(),
    };
