import 'package:json_annotation/json_annotation.dart';
import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';

part 'register_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable(explicitToJson: true)
class RegisterResponse extends BaseModelResponse {
  RegisterResponse({
    super.success,
    super.errorType,
    super.message,
    this.data,
  });

  @JsonKey(name: 'data')
  final RegisterResponseData? data;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);
  Map<String, dynamic> toJson() => baseToJson(_$RegisterResponseToJson(this));
}

@JsonSerializable()
class RegisterResponseData {
  RegisterResponseData({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
  });

  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'phone')
  final String? phone;

  @JsonKey(name: 'profile_image')
  final String? profileImage;

  factory RegisterResponseData.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseDataToJson(this);
}
