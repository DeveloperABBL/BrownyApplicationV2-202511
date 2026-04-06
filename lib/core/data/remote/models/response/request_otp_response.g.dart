// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_otp_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestOTPResponse _$RequestOTPResponseFromJson(Map<String, dynamic> json) =>
    RequestOTPResponse(
      success: json['success'] as bool?,
      errorType: json['error_type'] as String?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : OTPData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RequestOTPResponseToJson(RequestOTPResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'error_type': instance.errorType,
      'data': instance.data?.toJson(),
    };

OTPData _$OTPDataFromJson(Map<String, dynamic> json) => OTPData(
  refCode: json['ref_code'] as String?,
  username: json['usename'] as String?,
  expiredIn: (json['expired_in'] as num?)?.toInt(),
);

Map<String, dynamic> _$OTPDataToJson(OTPData instance) => <String, dynamic>{
  'ref_code': instance.refCode,
  'usename': instance.username,
  'expired_in': instance.expiredIn,
};
