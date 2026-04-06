import 'package:json_annotation/json_annotation.dart';

part 'request_otp.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class RequestOTP {
  RequestOTP({
    required this.username,
  });

  @JsonKey(name: 'username')
  final String username;

  factory RequestOTP.fromJson(Map<String, dynamic> json) =>
      _$RequestOTPFromJson(json);

  Map<String, dynamic> toJson() => _$RequestOTPToJson(this);
}
