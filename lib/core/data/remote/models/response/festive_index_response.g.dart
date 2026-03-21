// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'festive_index_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FestiveIndexResponse _$FestiveIndexResponseFromJson(
  Map<String, dynamic> json,
) => FestiveIndexResponse(
  hasEvent: json['has_event'] as bool?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => FestiveData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FestiveIndexResponseToJson(
  FestiveIndexResponse instance,
) => <String, dynamic>{'has_event': instance.hasEvent, 'data': instance.data};

FestiveData _$FestiveDataFromJson(Map<String, dynamic> json) => FestiveData(
  id: (json['id'] as num?)?.toInt(),
  banner: json['banner'] == null
      ? null
      : ContentLocalizeData.fromJson(json['banner'] as Map<String, dynamic>),
  thumbnail: json['thumbnail'] == null
      ? null
      : ContentLocalizeData.fromJson(json['thumbnail'] as Map<String, dynamic>),
  title: json['title'] == null
      ? null
      : ContentLocalizeData.fromJson(json['title'] as Map<String, dynamic>),
  message: json['message'] == null
      ? null
      : ContentLocalizeData.fromJson(json['message'] as Map<String, dynamic>),
  remain: json['remain'] == null
      ? null
      : ContentLocalizeData.fromJson(json['remain'] as Map<String, dynamic>),
  expired: json['expired'] == null
      ? null
      : ContentLocalizeData.fromJson(json['expired'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FestiveDataToJson(FestiveData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'banner': instance.banner,
      'thumbnail': instance.thumbnail,
      'title': instance.title,
      'message': instance.message,
      'remain': instance.remain,
      'expired': instance.expired,
    };
