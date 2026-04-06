import 'package:json_annotation/json_annotation.dart';

part 'coupon_list_request.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class CouponListRequest {
  @JsonKey(name: 'latitude')
  final String? latitude;

  @JsonKey(name: 'longitude')
  final String? longitude;

  @JsonKey(name: 'customer_id')
  final String? customerId;

  CouponListRequest({
    this.latitude,
    this.longitude,
    this.customerId,
  });

  factory CouponListRequest.fromJson(Map<String, dynamic> json) =>
      _$CouponListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CouponListRequestToJson(this);
}
