import 'package:browny_applications_new/core/data/remote/models/response/products_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_detail_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-09
///
/// Response model สำหรับ API GET /products/{id} (Browny Shop product detail)
/// Reuse [ProductData] จาก products_response.dart
@JsonSerializable()
class ProductDetailResponse {
  ProductDetailResponse({this.product});

  @JsonKey(name: 'product')
  final ProductData? product;

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDetailResponseToJson(this);
}
