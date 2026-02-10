// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactResponse _$ContactResponseFromJson(Map<String, dynamic> json) =>
    ContactResponse(
      problemLink: json['problem_link'] as String?,
      facebookLink: json['facebook_link'] as String?,
      lineLink: json['Line_link'] as String?,
      youtubeLink: json['youtube_link'] as String?,
      tiktokLink: json['tiktok_link'] as String?,
    );

Map<String, dynamic> _$ContactResponseToJson(ContactResponse instance) =>
    <String, dynamic>{
      'problem_link': instance.problemLink,
      'facebook_link': instance.facebookLink,
      'Line_link': instance.lineLink,
      'youtube_link': instance.youtubeLink,
      'tiktok_link': instance.tiktokLink,
    };
