import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'browny_shop_title_image_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-27
///
/// Response สำหรับ GET /browny-shop/title-image
/// — รูป title/header ของหน้า Browny Shop
@JsonSerializable()
class BrownyShopTitleImageResponse extends BaseModelResponse {
  BrownyShopTitleImageResponse({
    super.success,
    super.message,
    super.errorType,
    this.data,
  });

  @JsonKey(name: 'data')
  final BrownyShopTitleImageData? data;

  factory BrownyShopTitleImageResponse.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopTitleImageResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      baseToJson(_$BrownyShopTitleImageResponseToJson(this));
}

@JsonSerializable()
class BrownyShopTitleImageData {
  BrownyShopTitleImageData({this.imageUrl});

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  factory BrownyShopTitleImageData.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopTitleImageDataFromJson(json);

  Map<String, dynamic> toJson() => _$BrownyShopTitleImageDataToJson(this);
}
