import 'package:json_annotation/json_annotation.dart';

part 'browny_shop_review_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-31
///
/// Response สำหรับ POST /browny-shop/orders/{orderId}/review — รีวิวร้าน
/// รูปแบบ `{ status, message }` (ไม่ใช่ wrapper success ปกติ)
@JsonSerializable()
class BrownyShopReviewResponse {
  BrownyShopReviewResponse({this.status, this.message});

  /// "success" เมื่อรีวิวสำเร็จ
  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'message')
  final String? message;

  /// รีวิวสำเร็จหรือไม่
  bool get isSuccess => status?.toLowerCase() == 'success';

  factory BrownyShopReviewResponse.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopReviewResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BrownyShopReviewResponseToJson(this);
}
