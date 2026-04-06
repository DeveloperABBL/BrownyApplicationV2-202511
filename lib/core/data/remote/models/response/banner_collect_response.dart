import 'package:json_annotation/json_annotation.dart';

part 'banner_collect_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class BannerCollectResponse {
  BannerCollectResponse({
    this.status,
    this.message,
  });

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'message')
  final String? message;

  factory BannerCollectResponse.fromJson(Map<String, dynamic> json) =>
      _$BannerCollectResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BannerCollectResponseToJson(this);
}
