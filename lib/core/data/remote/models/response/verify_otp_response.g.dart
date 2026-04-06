// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyOTPResponse _$VerifyOTPResponseFromJson(Map<String, dynamic> json) =>
    VerifyOTPResponse(
      success: json['success'] as bool?,
      errorType: json['error_type'] as String?,
      message: json['message'] as String?,
      customerId: json['customer_id'] as String?,
    );

Map<String, dynamic> _$VerifyOTPResponseToJson(VerifyOTPResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'error_type': instance.errorType,
      'customer_id': instance.customerId,
    };
