import 'package:json_annotation/json_annotation.dart';

part 'change_password_request.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// Request model สำหรับเปลี่ยนรหัสผ่าน
@JsonSerializable()
class ChangePasswordRequest {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'old_password')
  final String oldPassword;

  @JsonKey(name: 'new_password')
  final String newPassword;

  ChangePasswordRequest({
    required this.id,
    required this.oldPassword,
    required this.newPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePasswordRequestToJson(this);
}
