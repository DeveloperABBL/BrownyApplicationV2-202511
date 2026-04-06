import 'package:json_annotation/json_annotation.dart';
import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';

part 'request_otp_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable(explicitToJson: true)
class RequestOTPResponse extends BaseModelResponse {
  RequestOTPResponse({
    super.success,
    super.errorType,
    super.message,
    this.data,
  });

  @JsonKey(name: 'data')
  final OTPData? data;

  factory RequestOTPResponse.fromJson(Map<String, dynamic> json) =>
      _$RequestOTPResponseFromJson(json);
  Map<String, dynamic> toJson() => baseToJson(_$RequestOTPResponseToJson(this));
}

@JsonSerializable()
class OTPData {
  OTPData({
    required this.refCode,
    required this.username,
    required this.expiredIn,
  });

  @JsonKey(name: 'ref_code')
  final String? refCode;

  @JsonKey(name: 'usename')
  final String? username;

  @JsonKey(name: 'expired_in')
  final int? expiredIn;

  factory OTPData.fromJson(Map<String, dynamic> json) =>
      _$OTPDataFromJson(json);

  Map<String, dynamic> toJson() => _$OTPDataToJson(this);
}
