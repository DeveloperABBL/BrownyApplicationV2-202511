import 'package:json_annotation/json_annotation.dart';

part 'referral_status_request.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class ReferralStatusRequest {
  ReferralStatusRequest({
    this.phone,
  });

  @JsonKey(name: 'phone')
  final String? phone;

  factory ReferralStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$ReferralStatusRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralStatusRequestToJson(this);
}
