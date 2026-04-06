import 'package:json_annotation/json_annotation.dart';

part 'coupon_collect_request.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// Request model สำหรับ collect coupon
@JsonSerializable()
class CouponCollectRequest {
  /// ประเภทของ coupon (code, qr)
  @JsonKey(name: 'type')
  final String type;

  /// ข้อมูล coupon (URL, QR code data)
  @JsonKey(name: 'data')
  final String data;

  /// รหัสลูกค้า (UUID)
  @JsonKey(name: 'customer_id')
  final String customerId;

  CouponCollectRequest({
    required this.type,
    required this.data,
    required this.customerId,
  });

  factory CouponCollectRequest.fromJson(Map<String, dynamic> json) =>
      _$CouponCollectRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CouponCollectRequestToJson(this);
}
