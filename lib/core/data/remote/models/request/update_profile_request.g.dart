// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProfileRequest _$UpdateProfileRequestFromJson(
  Map<String, dynamic> json,
) => UpdateProfileRequest(
  id: json['id'] as String,
  name: json['name'] as String?,
  gender: json['gender'] as String?,
  birthdate: json['birthdate'] as String?,
  profileImageBase64: json['profile_image_base64'] as String?,
  profileImageUrl: json['profile_image_url'] as String?,
);

Map<String, dynamic> _$UpdateProfileRequestToJson(
  UpdateProfileRequest instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'gender': instance.gender,
  'birthdate': instance.birthdate,
  'profile_image_base64': instance.profileImageBase64,
  'profile_image_url': instance.profileImageUrl,
};
