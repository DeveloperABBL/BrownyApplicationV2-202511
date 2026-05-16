import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/cart_item_add_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cart_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-16
///
/// Response model สำหรับ API GET /customer/{id}/cart (ตะกร้าสินค้า Browny Shop)
@JsonSerializable()
class CartResponse extends BaseModelResponse {
  CartResponse({
    this.data,
    super.success,
    super.message,
    super.errorType,
  });

  @JsonKey(name: 'data')
  final CartData? data;

  factory CartResponse.fromJson(Map<String, dynamic> json) =>
      _$CartResponseFromJson(json);

  Map<String, dynamic> toJson() => baseToJson(_$CartResponseToJson(this));
}

/// ข้อมูลตะกร้า — รายการสินค้า + ยอดรวม
@JsonSerializable()
class CartData {
  CartData({this.items, this.totals});

  /// รายการสินค้าในตะกร้า (reuse [CartItemData] จาก cart_item_add_response)
  @JsonKey(name: 'items')
  final List<CartItemData>? items;

  @JsonKey(name: 'totals')
  final CartTotalsData? totals;

  /// จำนวนบรรทัดในตะกร้า
  int get itemCount => items?.length ?? 0;

  /// เช็คว่าตะกร้าว่างหรือไม่
  bool get isEmpty => itemCount == 0;

  factory CartData.fromJson(Map<String, dynamic> json) =>
      _$CartDataFromJson(json);

  Map<String, dynamic> toJson() => _$CartDataToJson(this);
}

/// ยอดรวมของตะกร้า
@JsonSerializable()
class CartTotalsData {
  CartTotalsData({
    this.totalLineCoin,
    this.totalLineMoney,
    this.computedFrom,
  });

  /// ยอดรวมทั้งตะกร้า — coin
  @JsonKey(name: 'total_line_coin')
  final num? totalLineCoin;

  /// ยอดรวมทั้งตะกร้า — money
  @JsonKey(name: 'total_line_money')
  final num? totalLineMoney;

  /// แหล่งที่มาของการคำนวณราคา (เช่น "snapshot_unit_prices")
  @JsonKey(name: 'computed_from')
  final String? computedFrom;

  factory CartTotalsData.fromJson(Map<String, dynamic> json) =>
      _$CartTotalsDataFromJson(json);

  Map<String, dynamic> toJson() => _$CartTotalsDataToJson(this);
}
