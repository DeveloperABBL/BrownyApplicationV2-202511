import 'package:json_annotation/json_annotation.dart';

part 'cart_item_add_request.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-12
///
/// Request body สำหรับ API POST /customer/{id}/cart/items (เพิ่มสินค้าลงตะกร้า)
@JsonSerializable()
class CartItemAddRequest {
  CartItemAddRequest({
    required this.productId,
    required this.productSubId,
    required this.quantity,
  });

  @JsonKey(name: 'product_id')
  final String productId;

  @JsonKey(name: 'product_sub_id')
  final int productSubId;

  @JsonKey(name: 'quantity')
  final int quantity;

  factory CartItemAddRequest.fromJson(Map<String, dynamic> json) =>
      _$CartItemAddRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemAddRequestToJson(this);
}
