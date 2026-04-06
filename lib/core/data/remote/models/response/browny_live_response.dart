import 'package:json_annotation/json_annotation.dart';

part 'browny_live_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class BrownyLiveResponse {
  @JsonKey(name: 'enabled')
  final bool? enabled;

  @JsonKey(name: 'link')
  final String? link;

  BrownyLiveResponse({
    this.enabled,
    this.link,
  });

  factory BrownyLiveResponse.fromJson(Map<String, dynamic> json) =>
      _$BrownyLiveResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BrownyLiveResponseToJson(this);
}
