// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyOTP _$VerifyOTPFromJson(Map<String, dynamic> json) => VerifyOTP(
  username: json['username'] as String,
  refCode: json['ref_code'] as String,
  otp: json['otp'] as String,
);

Map<String, dynamic> _$VerifyOTPToJson(VerifyOTP instance) => <String, dynamic>{
  'username': instance.username,
  'ref_code': instance.refCode,
  'otp': instance.otp,
};
