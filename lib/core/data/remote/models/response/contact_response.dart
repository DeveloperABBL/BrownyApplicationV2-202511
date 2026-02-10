import 'package:json_annotation/json_annotation.dart';

part 'contact_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class ContactResponse {
  @JsonKey(name: 'problem_link')
  final String? problemLink;

  @JsonKey(name: 'facebook_link')
  final String? facebookLink;

  @JsonKey(name: 'Line_link')
  final String? lineLink;

  @JsonKey(name: 'youtube_link')
  final String? youtubeLink;

  @JsonKey(name: 'tiktok_link')
  final String? tiktokLink;

  ContactResponse({
    this.problemLink,
    this.facebookLink,
    this.lineLink,
    this.youtubeLink,
    this.tiktokLink,
  });

  factory ContactResponse.fromJson(Map<String, dynamic> json) =>
      _$ContactResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ContactResponseToJson(this);
}
