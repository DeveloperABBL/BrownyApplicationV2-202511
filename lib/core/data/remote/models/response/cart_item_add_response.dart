import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cart_item_add_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-12
///
/// Response model สำหรับ API POST /customer/{id}/cart/items (เพิ่มสินค้าลงตะกร้า)
@JsonSerializable()
class CartItemAddResponse extends BaseModelResponse {
  CartItemAddResponse({
    this.data,
    super.success,
    super.message,
    super.errorType,
  });

  @JsonKey(name: 'data')
  final CartItemData? data;

  factory CartItemAddResponse.fromJson(Map<String, dynamic> json) =>
      _$CartItemAddResponseFromJson(json);

  Map<String, dynamic> toJson() => baseToJson(_$CartItemAddResponseToJson(this));
}

/// 1 รายการสินค้าในตะกร้า
@JsonSerializable()
class CartItemData {
  CartItemData({
    this.id,
    this.customerId,
    this.productId,
    this.productSubId,
    this.quantity,
    this.unitCoinPrice,
    this.unitMoneyPrice,
    this.isFlashSale,
    this.flashSaleId,
    this.lineCoinTotal,
    this.lineMoneyTotal,
    this.priceChanged,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'customer_id')
  final String? customerId;

  @JsonKey(name: 'product_id')
  final String? productId;

  @JsonKey(name: 'product_sub_id')
  final int? productSubId;

  @JsonKey(name: 'quantity')
  final int? quantity;

  /// ราคาต่อหน่วย — coin
  @JsonKey(name: 'unit_coin_price')
  final num? unitCoinPrice;

  /// ราคาต่อหน่วย — money
  @JsonKey(name: 'unit_money_price')
  final num? unitMoneyPrice;

  @JsonKey(name: 'is_flash_sale')
  final bool? isFlashSale;

  @JsonKey(name: 'flash_sale_id')
  final int? flashSaleId;

  /// ยอดรวมของบรรทัดนี้ — coin (= unit_coin_price * quantity)
  @JsonKey(name: 'line_coin_total')
  final num? lineCoinTotal;

  /// ยอดรวมของบรรทัดนี้ — money
  @JsonKey(name: 'line_money_total')
  final num? lineMoneyTotal;

  /// true เมื่อราคาเปลี่ยนระหว่างที่ user กำลังหยิบใส่ตะกร้า
  @JsonKey(name: 'price_changed')
  final bool? priceChanged;

  factory CartItemData.fromJson(Map<String, dynamic> json) =>
      _$CartItemDataFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemDataToJson(this);
}
