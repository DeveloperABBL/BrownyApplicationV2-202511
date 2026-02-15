// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_pin_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyPinResponse _$VerifyPinResponseFromJson(Map<String, dynamic> json) =>
    VerifyPinResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      token: json['token'] as String?,
      expire: json['expire'] as String?,
      errorType: json['error_type'] as String?,
      errors: json['errors'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$VerifyPinResponseToJson(VerifyPinResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'token': instance.token,
      'expire': instance.expire,
      'error_type': instance.errorType,
      'errors': instance.errors,
    };
