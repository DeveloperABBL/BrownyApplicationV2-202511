import 'package:json_annotation/json_annotation.dart';

part 'cart_item_quantity_request.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-19
///
/// Request body สำหรับ API PATCH /customer/{id}/cart/items/{itemId}
/// — ตั้งจำนวนสินค้าในตะกร้าโดยตรง (ส่งจำนวนสุดท้ายที่ user ปรับ)
@JsonSerializable()
class CartItemQuantityRequest {
  CartItemQuantityRequest({required this.quantity});

  @JsonKey(name: 'quantity')
  final int quantity;

  factory CartItemQuantityRequest.fromJson(Map<String, dynamic> json) =>
      _$CartItemQuantityRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemQuantityRequestToJson(this);
}
