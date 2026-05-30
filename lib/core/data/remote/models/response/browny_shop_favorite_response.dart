import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'browny_shop_favorite_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-30
///
/// Response สำหรับ POST /browny-shop/favorites (เพิ่ม)
/// และ DELETE /browny-shop/favorites/{productId} (ลบ)
@JsonSerializable()
class BrownyShopFavoriteResponse extends BaseModelResponse {
  BrownyShopFavoriteResponse({
    super.success,
    super.message,
    super.errorType,
    this.data,
  });

  @JsonKey(name: 'data')
  final BrownyShopFavoriteData? data;

  factory BrownyShopFavoriteResponse.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopFavoriteResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      baseToJson(_$BrownyShopFavoriteResponseToJson(this));
}

@JsonSerializable()
class BrownyShopFavoriteData {
  BrownyShopFavoriteData({
    this.customerId,
    this.productId,
    this.favoriteStatus,
  });

  @JsonKey(name: 'customer_id')
  final String? customerId;

  @JsonKey(name: 'product_id')
  final String? productId;

  /// สถานะหลังทำรายการ — true = เป็นรายการโปรด, false = ถูกลบแล้ว
  @JsonKey(name: 'favorite_status')
  final bool? favoriteStatus;

  factory BrownyShopFavoriteData.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopFavoriteDataFromJson(json);

  Map<String, dynamic> toJson() => _$BrownyShopFavoriteDataToJson(this);
}
