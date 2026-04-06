// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_menu_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeMenuResponse _$HomeMenuResponseFromJson(Map<String, dynamic> json) =>
    HomeMenuResponse(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => HomeMenuItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HomeMenuResponseToJson(HomeMenuResponse instance) =>
    <String, dynamic>{'data': instance.data?.map((e) => e.toJson()).toList()};

HomeMenuItem _$HomeMenuItemFromJson(Map<String, dynamic> json) => HomeMenuItem(
  mode: json['mode'] as String?,
  image: json['image'] as String?,
  url: json['url'] as String?,
);

Map<String, dynamic> _$HomeMenuItemToJson(HomeMenuItem instance) =>
    <String, dynamic>{
      'mode': instance.mode,
      'image': instance.image,
      'url': instance.url,
    };
