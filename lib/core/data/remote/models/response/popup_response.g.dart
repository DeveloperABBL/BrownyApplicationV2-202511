// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'popup_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PopupData _$PopupDataFromJson(Map<String, dynamic> json) => PopupData(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  showOn: (json['show_on'] as List<dynamic>).map((e) => e as String).toList(),
  active: json['active'] as String,
  programAction: json['program_action'] as String,
  programTarget: json['program_target'] as String,
  autoClickTarget: json['auto_click_target'] as String,
  startDate: json['start_date'] as String,
  endDate: json['end_date'] as String,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  text: ContentLocalizeData.fromJson(json['text'] as Map<String, dynamic>),
  image: ContentLocalizeData.fromJson(json['image'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PopupDataToJson(PopupData instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'show_on': instance.showOn,
  'active': instance.active,
  'program_action': instance.programAction,
  'program_target': instance.programTarget,
  'auto_click_target': instance.autoClickTarget,
  'start_date': instance.startDate,
  'end_date': instance.endDate,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'text': instance.text,
  'image': instance.image,
};
