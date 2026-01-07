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
  });

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'gender')
  final String? gender;

  @JsonKey(name: 'birthdate')
  final String? birthdate;

  @JsonKey(name: 'profile_image_base64')
  final String? profileImageBase64;

  @JsonKey(name: 'profile_image_url')
  final String? profileImageUrl;

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}
