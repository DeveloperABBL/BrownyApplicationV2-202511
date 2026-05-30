import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/checkout_draft_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cart_summary_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-30
///
/// Response สำหรับ GET/POST /browny-shop/cart/summary
/// — preview ยอด/ส่วนลด/คูปอง ก่อน confirm (ใช้ [CheckoutSummaryData] ร่วมกัน)
///
/// ส่ง coupon_customer_id + คูปองใช้ได้ → `data.coupon` มีค่า
/// คูปองใช้ไม่ได้ → server ตอบ 422 (จัดการที่ชั้น repo)
@JsonSerializable()
class CartSummaryResponse extends BaseModelResponse {
  CartSummaryResponse({
    super.success,
    super.message,
    super.errorType,
    this.data,
  });

  @JsonKey(name: 'data')
  final CheckoutSummaryData? data;

  factory CartSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$CartSummaryResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      baseToJson(_$CartSummaryResponseToJson(this));
}
