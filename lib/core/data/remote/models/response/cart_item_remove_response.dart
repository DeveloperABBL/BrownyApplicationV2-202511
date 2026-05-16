import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cart_item_remove_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-16
///
/// Response model สำหรับ API DELETE /customer/{id}/cart/items/{itemId}
/// (ลบสินค้า 1 รายการออกจากตะกร้า)
@JsonSerializable()
class CartItemRemoveResponse extends BaseModelResponse {
  CartItemRemoveResponse({
    this.data,
    super.success,
    super.message,
    super.errorType,
  });

  @JsonKey(name: 'data')
  final CartItemRemoveData? data;

  factory CartItemRemoveResponse.fromJson(Map<String, dynamic> json) =>
      _$CartItemRemoveResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      baseToJson(_$CartItemRemoveResponseToJson(this));
}

/// ผลลัพธ์การลบรายการในตะกร้า
@JsonSerializable()
class CartItemRemoveData {
  CartItemRemoveData({this.removed, this.id});

  /// true เมื่อลบสำเร็จ
  @JsonKey(name: 'removed')
  final bool? removed;

  /// id ของ cart item ที่ถูกลบ
  @JsonKey(name: 'id')
  final int? id;

  factory CartItemRemoveData.fromJson(Map<String, dynamic> json) =>
      _$CartItemRemoveDataFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemRemoveDataToJson(this);
}
