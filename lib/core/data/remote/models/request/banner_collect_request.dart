import 'package:json_annotation/json_annotation.dart';

part 'banner_collect_request.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class BannerCollectRequest {
  BannerCollectRequest({
    required this.customerId,
  });

  @JsonKey(name: 'customer_id')
  final String customerId;

  factory BannerCollectRequest.fromJson(Map<String, dynamic> json) =>
      _$BannerCollectRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BannerCollectRequestToJson(this);
}
