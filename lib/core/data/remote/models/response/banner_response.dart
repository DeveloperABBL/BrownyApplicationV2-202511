import 'package:browny_applications_new/core/data/remote/models/response/introductions_response.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';

part 'banner_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable(explicitToJson: true)
class BannerResponse extends BaseModelResponse {
  BannerResponse({
    super.success,
    super.errorType,
    super.message,
    this.id,
    this.name,
    this.type,
    this.target,
    this.image,
    this.title,
    this.subtitle,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'target')
  final String? target;

  @JsonKey(name: 'image')
  final ContentLocalizeData? image;

  @JsonKey(name: 'title')
  final ContentLocalizeData? title;

  @JsonKey(name: 'subtitle')
  final ContentLocalizeData? subtitle;

  factory BannerResponse.fromJson(Map<String, dynamic> json) =>
      _$BannerResponseFromJson(json);
  Map<String, dynamic> toJson() => baseToJson(_$BannerResponseToJson(this));
}
