import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/products_response.dart';
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
    this.productName,
    this.variantName,
    this.currentUnitCoinPrice,
    this.currentUnitMoneyPrice,
    this.currentIsFlashSale,
    this.currentFlashSaleId,
    this.product,
    this.variant,
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

  /// ชื่อสินค้า (มีเฉพาะใน endpoint GET /cart)
  @JsonKey(name: 'product_name')
  final String? productName;

  /// ชื่อตัวเลือกย่อย (product_sub) — มีเฉพาะใน endpoint GET /cart
  @JsonKey(name: 'variant_name')
  final String? variantName;

  /// ราคาต่อหน่วยปัจจุบัน (coin) — ราคาล่าสุด เทียบกับ snapshot ตอนหยิบใส่ตะกร้า
  @JsonKey(name: 'current_unit_coin_price')
  final num? currentUnitCoinPrice;

  /// ราคาต่อหน่วยปัจจุบัน (money) — ราคาล่าสุด เทียบกับ snapshot ตอนหยิบใส่ตะกร้า
  @JsonKey(name: 'current_unit_money_price')
  final num? currentUnitMoneyPrice;

  /// สถานะ flash sale ปัจจุบันของสินค้า
  @JsonKey(name: 'current_is_flash_sale')
  final bool? currentIsFlashSale;

  /// id flash sale ปัจจุบันของสินค้า (null = ไม่อยู่ใน flash sale)
  @JsonKey(name: 'current_flash_sale_id')
  final int? currentFlashSaleId;

  /// ข้อมูลสินค้าเต็ม — translations, รูปหลัก, is_free_shipping, has_flash_sale
  @JsonKey(name: 'product')
  final ProductData? product;

  /// ตัวเลือกย่อย (product_sub) ของรายการนี้ — API nest มาให้ตรง ๆ
  @JsonKey(name: 'variant')
  final ProductSubData? variant;

  /// เช็คว่าราคาเปลี่ยนไปจากตอนหยิบใส่ตะกร้าหรือไม่
  bool get hasPriceChanged => priceChanged == true;

  /// product_sub (variant) ของรายการนี้
  ///
  /// API ใหม่ nest `variant` มาตรง ๆ — ใช้ก่อน, fallback ค้นใน [product]
  ProductSubData? get matchedSub {
    if (variant != null) return variant;
    final subs = product?.productSubs;
    if (subs == null) return null;
    for (final s in subs) {
      if (s.id == productSubId) return s;
    }
    return null;
  }

  /// URL รูปของรายการนี้ — variant image ก่อน, fallback เป็นรูปหลักของสินค้า
  String? get imageUrl => matchedSub?.imageUrl ?? product?.mainImageUrl;

  factory CartItemData.fromJson(Map<String, dynamic> json) =>
      _$CartItemDataFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemDataToJson(this);
}
