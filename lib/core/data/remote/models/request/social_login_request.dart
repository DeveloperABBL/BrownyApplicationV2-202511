import 'package:json_annotation/json_annotation.dart';

part 'social_login_request.g.dart';

/// DONG 2026-02-08
///
/// Model สำหรับ Social Login Request (Google, Facebook)
@JsonSerializable()
class SocialLoginRequest {
  /// provider: google, facebook เท่านั้น
  @JsonKey(name: 'provider')
  final String provider;

  /// app_id จาก social provider
  @JsonKey(name: 'app_id')
  final String appId;

  /// ชื่อผู้ใช้
  @JsonKey(name: 'name')
  final String name;

  /// อีเมล์
  @JsonKey(name: 'email')
  final String email;

  /// URL รูปโปรไฟล์
  @JsonKey(name: 'profile_image')
  final String profileImage;

  SocialLoginRequest({
    required this.provider,
    required this.appId,
    required this.name,
    required this.email,
    required this.profileImage,
  });

  factory SocialLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$SocialLoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SocialLoginRequestToJson(this);
}
