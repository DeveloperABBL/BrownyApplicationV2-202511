import 'package:json_annotation/json_annotation.dart';

part 'browny_shop_favorite_request.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-30
///
/// Body request สำหรับ POST /browny-shop/favorites — เพิ่มสินค้าโปรด
@JsonSerializable()
class BrownyShopFavoriteRequest {
  BrownyShopFavoriteRequest({
    required this.customerId,
    required this.productId,
  });

  @JsonKey(name: 'customer_id')
  final String customerId;

  @JsonKey(name: 'product_id')
  final String productId;

  factory BrownyShopFavoriteRequest.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopFavoriteRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BrownyShopFavoriteRequestToJson(this);
}
