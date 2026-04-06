import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';

part 'coupon_store_list_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class CouponStoreListResponse extends BaseModelResponse {
  @JsonKey(name: 'data')
  final List<CouponStoreData>? data;

  CouponStoreListResponse({
    super.success,
    super.errorType,
    super.message,
    this.data,
  });

  factory CouponStoreListResponse.fromJson(Map<String, dynamic> json) =>
      _$CouponStoreListResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      baseToJson(_$CouponStoreListResponseToJson(this));
}

@JsonSerializable()
class CouponStoreData {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  CouponStoreData({
    this.id,
    this.name,
  });

  factory CouponStoreData.fromJson(Map<String, dynamic> json) =>
      _$CouponStoreDataFromJson(json);

  Map<String, dynamic> toJson() => _$CouponStoreDataToJson(this);
}
