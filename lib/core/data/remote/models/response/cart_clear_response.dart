import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cart_clear_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-16
///
/// Response model สำหรับ API DELETE /customer/{id}/cart (ล้างตะกร้าทั้งหมด)
@JsonSerializable()
class CartClearResponse extends BaseModelResponse {
  CartClearResponse({
    this.data,
    super.success,
    super.message,
    super.errorType,
  });

  @JsonKey(name: 'data')
  final CartClearData? data;

  factory CartClearResponse.fromJson(Map<String, dynamic> json) =>
      _$CartClearResponseFromJson(json);

  Map<String, dynamic> toJson() => baseToJson(_$CartClearResponseToJson(this));
}

/// ผลลัพธ์การล้างตะกร้า
@JsonSerializable()
class CartClearData {
  CartClearData({this.deletedCount});

  /// จำนวนรายการที่ถูกลบออกจากตะกร้า
  @JsonKey(name: 'deleted_count')
  final int? deletedCount;

  factory CartClearData.fromJson(Map<String, dynamic> json) =>
      _$CartClearDataFromJson(json);

  Map<String, dynamic> toJson() => _$CartClearDataToJson(this);
}
