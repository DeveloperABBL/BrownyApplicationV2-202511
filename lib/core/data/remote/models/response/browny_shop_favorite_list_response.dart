import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/products_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'browny_shop_favorite_list_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-30
///
/// Response สำหรับ GET /browny-shop/favorites — รายการสินค้าโปรดของลูกค้า
/// items[] รูปแบบเดียวกับ product list (ProductData) ทุกตัว favorite_status = true
@JsonSerializable()
class BrownyShopFavoriteListResponse extends BaseModelResponse {
  BrownyShopFavoriteListResponse({
    super.success,
    super.message,
    super.errorType,
    this.data,
  });

  @JsonKey(name: 'data')
  final BrownyShopFavoriteListData? data;

  factory BrownyShopFavoriteListResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$BrownyShopFavoriteListResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      baseToJson(_$BrownyShopFavoriteListResponseToJson(this));
}

@JsonSerializable()
class BrownyShopFavoriteListData {
  BrownyShopFavoriteListData({this.customerId, this.items});

  @JsonKey(name: 'customer_id')
  final String? customerId;

  @JsonKey(name: 'items')
  final List<ProductData>? items;

  factory BrownyShopFavoriteListData.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopFavoriteListDataFromJson(json);

  Map<String, dynamic> toJson() => _$BrownyShopFavoriteListDataToJson(this);
}
