import 'package:json_annotation/json_annotation.dart';

part 'verify_otp.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class VerifyOTP {
  VerifyOTP({
    required this.username,
    required this.refCode,
    required this.otp,
  });

  @JsonKey(name: 'username')
  final String username;

  @JsonKey(name: 'ref_code')
  final String refCode;

  @JsonKey(name: 'otp')
  final String otp;

  factory VerifyOTP.fromJson(Map<String, dynamic> json) =>
      _$VerifyOTPFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOTPToJson(this);
}
