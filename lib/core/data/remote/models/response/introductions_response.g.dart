// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'introductions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntroductionsResponse _$IntroductionsResponseFromJson(
  Map<String, dynamic> json,
) => IntroductionsResponse(
  imageUrl: json['image_url'] as String?,
  title: json['title'] == null
      ? null
      : ContentLocalizeData.fromJson(json['title'] as Map<String, dynamic>),
  subtitle: json['subtitle'] == null
      ? null
      : ContentLocalizeData.fromJson(json['subtitle'] as Map<String, dynamic>),
  success: json['success'] as bool?,
  errorType: json['error_type'] as String?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$IntroductionsResponseToJson(
  IntroductionsResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'image_url': instance.imageUrl,
  'title': instance.title?.toJson(),
  'subtitle': instance.subtitle?.toJson(),
};
