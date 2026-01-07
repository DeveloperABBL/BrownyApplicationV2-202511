import 'package:json_annotation/json_annotation.dart';
import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';

part 'verify_otp_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class VerifyOTPResponse extends BaseModelResponse {
  VerifyOTPResponse({
    super.success,
    super.errorType,
    super.message,
    this.customerId,
  });

  @JsonKey(name: 'customer_id')
  final String? customerId;

  factory VerifyOTPResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyOTPResponseFromJson(json);
  Map<String, dynamic> toJson() => baseToJson(_$VerifyOTPResponseToJson(this));
}
