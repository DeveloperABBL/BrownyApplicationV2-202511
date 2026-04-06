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
      registerTermsLink: json['register_terms_link'] as String?,
      brownyCareContact: json['browny_care_contact'] as String?,
    );

Map<String, dynamic> _$ContactResponseToJson(ContactResponse instance) =>
    <String, dynamic>{
      'problem_link': instance.problemLink,
      'facebook_link': instance.facebookLink,
      'Line_link': instance.lineLink,
      'youtube_link': instance.youtubeLink,
      'tiktok_link': instance.tiktokLink,
      'register_terms_link': instance.registerTermsLink,
      'browny_care_contact': instance.brownyCareContact,
    };
