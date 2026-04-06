import 'package:json_annotation/json_annotation.dart';

part 'store_location_request.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class StoreLocationRequest {
  StoreLocationRequest({
    required this.latitude,
    required this.longitude,
  });

  @JsonKey(name: 'latitude')
  final String? latitude;

  @JsonKey(name: 'longitude')
  final String? longitude;

  factory StoreLocationRequest.fromJson(Map<String, dynamic> json) =>
      _$StoreLocationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$StoreLocationRequestToJson(this);
}
