import 'package:json_annotation/json_annotation.dart';

part 'shipping_provider_data.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-30
///
/// บริษัทขนส่งของออร์เดอร์ Browny Shop — ใช้คู่กับ `tracking_number`
/// ปรากฏใน order history, order detail และ receipt
///
/// `null` เมื่อยังไม่ได้จัดส่ง (pending_shipment)
@JsonSerializable()
class ShippingProviderData {
  ShippingProviderData({
    this.id,
    this.code,
    this.name,
    this.logoUrl,
    this.trackUrl,
  });

  @JsonKey(name: 'id')
  final int? id;

  /// รหัสขนส่ง (เช่น "flash")
  @JsonKey(name: 'code')
  final String? code;

  /// ชื่อขนส่ง (เช่น "Flash Express")
  @JsonKey(name: 'name')
  final String? name;

  /// URL โลโก้ขนส่ง
  @JsonKey(name: 'logo_url')
  final String? logoUrl;

  /// URL หน้า track พัสดุ (null = ไม่มีลิงก์ track โดยตรง)
  @JsonKey(name: 'track_url')
  final String? trackUrl;

  bool get hasTrackUrl => trackUrl != null && trackUrl!.isNotEmpty;

  factory ShippingProviderData.fromJson(Map<String, dynamic> json) =>
      _$ShippingProviderDataFromJson(json);

  Map<String, dynamic> toJson() => _$ShippingProviderDataToJson(this);
}
