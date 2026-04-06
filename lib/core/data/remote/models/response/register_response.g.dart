// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterResponse _$RegisterResponseFromJson(Map<String, dynamic> json) =>
    RegisterResponse(
      success: json['success'] as bool?,
      errorType: json['error_type'] as String?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : RegisterResponseData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RegisterResponseToJson(RegisterResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'error_type': instance.errorType,
      'data': instance.data?.toJson(),
    };

RegisterResponseData _$RegisterResponseDataFromJson(
  Map<String, dynamic> json,
) => RegisterResponseData(
  id: json['id'] as String?,
  name: json['name'] as String?,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  profileImage: json['profile_image'] as String?,
);

Map<String, dynamic> _$RegisterResponseDataToJson(
  RegisterResponseData instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'profile_image': instance.profileImage,
};
