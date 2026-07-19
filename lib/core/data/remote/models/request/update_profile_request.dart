import 'package:json_annotation/json_annotation.dart';

part 'update_profile_request.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class UpdateProfileRequest {
  UpdateProfileRequest({
    required this.id,
    this.name,
    this.gender,
    this.birthdate,
    this.profileImageBase64,
    this.profileImageUrl,
    this.email,
    this.phone,
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'name', includeIfNull: false)
  final String? name;

  @JsonKey(name: 'gender', includeIfNull: false)
  final String? gender;

  @JsonKey(name: 'birthdate', includeIfNull: false)
  final String? birthdate;

  @JsonKey(name: 'profile_image_base64', includeIfNull: false)
  final String? profileImageBase64;

  @JsonKey(name: 'profile_image_url', includeIfNull: false)
  final String? profileImageUrl;

  @JsonKey(name: 'email', includeIfNull: false)
  final String? email;

  @JsonKey(name: 'phone', includeIfNull: false)
  final String? phone;

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}
