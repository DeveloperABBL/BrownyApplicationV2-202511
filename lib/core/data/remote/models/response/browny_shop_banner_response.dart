import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:browny_applications_new/core/utils/json_converters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'browny_shop_banner_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-27
///
/// Response สำหรับ GET /browny-shop/banners
/// — รายการ banner ของหน้า Browny Shop (ตามช่วงเวลา + first_login_only filter)
@JsonSerializable()
class BrownyShopBannerResponse extends BaseModelResponse {
  BrownyShopBannerResponse({
    super.success,
    super.message,
    super.errorType,
    this.data,
  });

  @JsonKey(name: 'data')
  final List<BrownyShopBannerData>? data;

  factory BrownyShopBannerResponse.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopBannerResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      baseToJson(_$BrownyShopBannerResponseToJson(this));
}

@JsonSerializable()
class BrownyShopBannerData {
  BrownyShopBannerData({
    this.id,
    this.title,
    this.imageUrl,
    this.firstLoginOnly,
    this.startAt,
    this.endAt,
    this.sortOrder,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @JsonKey(name: 'first_login_only')
  final bool? firstLoginOnly;

  @DateTimeConverter()
  @JsonKey(name: 'start_at')
  final DateTime? startAt;

  @DateTimeConverter()
  @JsonKey(name: 'end_at')
  final DateTime? endAt;

  @JsonKey(name: 'sort_order')
  final int? sortOrder;

  factory BrownyShopBannerData.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopBannerDataFromJson(json);

  Map<String, dynamic> toJson() => _$BrownyShopBannerDataToJson(this);
}
