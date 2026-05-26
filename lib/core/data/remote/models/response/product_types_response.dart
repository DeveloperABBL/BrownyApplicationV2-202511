import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_types_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-26
///
/// Response model สำหรับ GET /product-types — รายการประเภทสินค้า Browny Shop
@JsonSerializable()
class ProductTypesResponse extends BaseModelResponse {
  ProductTypesResponse({
    this.productType,
    super.success,
    super.message,
    super.errorType,
  });

  @JsonKey(name: 'product_type')
  final List<ProductTypeData>? productType;

  factory ProductTypesResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductTypesResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      baseToJson(_$ProductTypesResponseToJson(this));
}

/// 1 รายการประเภทสินค้า — `id` ใช้เป็น query param ตอน fetch สินค้า
///
/// NOTE: `id` เป็น dynamic เพราะ server ส่งได้ทั้ง String ("all") และ int (1, 2, 3)
@JsonSerializable()
class ProductTypeData {
  ProductTypeData({
    this.id,
    this.name,
  });

  @JsonKey(name: 'id')
  final dynamic id;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  /// ดึงชื่อ product type ตาม locale
  String getNameDisplay(String locale) {
    return name?.getByLocaleCode(locale) ?? '';
  }

  factory ProductTypeData.fromJson(Map<String, dynamic> json) =>
      _$ProductTypeDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProductTypeDataToJson(this);
}
