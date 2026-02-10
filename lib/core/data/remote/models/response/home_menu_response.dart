import 'package:json_annotation/json_annotation.dart';

part 'home_menu_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable(explicitToJson: true)
class HomeMenuResponse {
  @JsonKey(name: 'data')
  final List<HomeMenuItem>? data;

  HomeMenuResponse({this.data});

  factory HomeMenuResponse.fromJson(Map<String, dynamic> json) =>
      _$HomeMenuResponseFromJson(json);
  Map<String, dynamic> toJson() => _$HomeMenuResponseToJson(this);
}

@JsonSerializable()
class HomeMenuItem {
  @JsonKey(name: 'mode')
  final String? mode;

  @JsonKey(name: 'image')
  final String? image;

  @JsonKey(name: 'url')
  final String? url;

  HomeMenuItem({
    this.mode,
    this.image,
    this.url,
  });

  factory HomeMenuItem.fromJson(Map<String, dynamic> json) =>
      _$HomeMenuItemFromJson(json);
  Map<String, dynamic> toJson() => _$HomeMenuItemToJson(this);
}
