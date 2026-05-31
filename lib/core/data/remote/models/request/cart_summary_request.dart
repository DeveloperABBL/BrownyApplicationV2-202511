import 'package:json_annotation/json_annotation.dart';

part 'cart_summary_request.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-30
///
/// Body request สำหรับ POST /browny-shop/cart/summary
/// — คำนวณ summary จาก items ที่ส่งมาเอง (แทนการอ่านจากตะกร้า)
///
/// field ที่เป็น null จะไม่ถูกส่ง (includeIfNull: false)
@JsonSerializable(includeIfNull: false)
class CartSummaryRequest {
  CartSummaryRequest({
    required this.customerId,
    required this.items,
    this.couponCustomerId,
    this.paymentMethod,
    this.customerAddressId,
  });

  @JsonKey(name: 'customer_id')
  final String customerId;

  @JsonKey(name: 'coupon_customer_id')
  final int? couponCustomerId;

  /// id ที่อยู่จัดส่ง — ใช้ประเมินค่าจัดส่ง (shipping_total) ก่อน checkout
  @JsonKey(name: 'customer_address_id')
  final int? customerAddressId;

  /// "qr", "coin", "tp_wallet" — มีผลกับ coin_amount_required
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;

  @JsonKey(name: 'items')
  final List<CartSummaryItemRequest> items;

  factory CartSummaryRequest.fromJson(Map<String, dynamic> json) =>
      _$CartSummaryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CartSummaryRequestToJson(this);
}

@JsonSerializable()
class CartSummaryItemRequest {
  CartSummaryItemRequest({
    required this.productSubId,
    required this.quantity,
  });

  @JsonKey(name: 'product_sub_id')
  final int productSubId;

  @JsonKey(name: 'quantity')
  final int quantity;

  factory CartSummaryItemRequest.fromJson(Map<String, dynamic> json) =>
      _$CartSummaryItemRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CartSummaryItemRequestToJson(this);
}
