// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_login_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocialLoginRequest _$SocialLoginRequestFromJson(Map<String, dynamic> json) =>
    SocialLoginRequest(
      provider: json['provider'] as String,
      appId: json['app_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImage: json['profile_image'] as String,
    );

Map<String, dynamic> _$SocialLoginRequestToJson(SocialLoginRequest instance) =>
    <String, dynamic>{
      'provider': instance.provider,
      'app_id': instance.appId,
      'name': instance.name,
      'email': instance.email,
      'profile_image': instance.profileImage,
    };
