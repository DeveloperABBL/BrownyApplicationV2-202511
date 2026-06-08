import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/data/remote/models/response/checkout_draft_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/shipping_provider_data.dart';
import 'package:browny_applications_new/core/utils/json_converters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'browny_shop_receipt_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-27
///
/// Response สำหรับ GET /browny-shop/orders/{orderId}/receipt
/// — ใบเสร็จคำสั่งซื้อ Browny Shop (มีรายละเอียดสินค้า, ที่อยู่จัดส่ง, breakdown ราคา)
@JsonSerializable(explicitToJson: true)
class BrownyShopReceiptResponse {
  BrownyShopReceiptResponse({
    this.type,
    this.orderId,
    this.paymentRef,
    this.receiptNo,
    this.total,
    this.priceOriginal,
    this.priceFinal,
    this.discountAmount,
    this.totalQuantity,
    this.paymentIcon,
    this.paymentChannel,
    this.paymentDisplay,
    this.paidAt,
    this.receiptAt,
    this.coinAmountUsed,
    this.coinValue,
    this.luckyNo,
    this.luckyImage,
    this.shippingAddress,
    this.summary,
    this.items,
    this.callCenter,
    this.lineLink,
    this.qrImage,
    this.reviewScore,
    this.bonus,
    this.trackingNumber,
    this.shippingProvider,
  });

  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'order_id')
  final String? orderId;

  @JsonKey(name: 'payment_ref')
  final String? paymentRef;

  @JsonKey(name: 'receipt_no')
  final String? receiptNo;

  @JsonKey(name: 'total')
  final String? total;

  @JsonKey(name: 'price_original')
  final String? priceOriginal;

  @JsonKey(name: 'price_final')
  final String? priceFinal;

  @JsonKey(name: 'discount_amount')
  final String? discountAmount;

  @JsonKey(name: 'total_quantity')
  final int? totalQuantity;

  @JsonKey(name: 'payment_icon')
  final String? paymentIcon;

  @JsonKey(name: 'payment_channel')
  final String? paymentChannel;

  @JsonKey(name: 'payment_display')
  final ContentLocalizeData? paymentDisplay;

  @DateTimeConverter()
  @JsonKey(name: 'paid_at')
  final DateTime? paidAt;

  @DateTimeConverter()
  @JsonKey(name: 'receipt_at')
  final DateTime? receiptAt;

  /// จำนวน coin ที่ใช้ (เฉพาะ payment_channel == 'coin')
  @JsonKey(name: 'coin_amount_used')
  final String? coinAmountUsed;

  /// มูลค่าเงินที่แลกได้จาก coin (เฉพาะ payment_channel == 'coin')
  @JsonKey(name: 'coin_value')
  final num? coinValue;

  @JsonKey(name: 'lucky_no')
  final String? luckyNo;

  @JsonKey(name: 'lucky_image')
  final String? luckyImage;

  @JsonKey(name: 'shipping_address')
  final CheckoutShippingAddressData? shippingAddress;

  @JsonKey(name: 'summary')
  final BrownyShopReceiptSummary? summary;

  @JsonKey(name: 'items')
  final List<BrownyShopReceiptItem>? items;

  @JsonKey(name: 'call_center')
  final String? callCenter;

  @JsonKey(name: 'line_link')
  final String? lineLink;

  @JsonKey(name: 'qr_image')
  final String? qrImage;

  /// คะแนนรีวิว (null = ยังไม่เคยรีวิว) — server ส่งเป็นตัวเลข
  @JsonKey(name: 'review_score')
  final int? reviewScore;

  @JsonKey(name: 'bonus')
  final String? bonus;

  /// เลขพัสดุ (null/ว่าง = ยังไม่ได้จัดส่ง) — รูปแบบเดียวกับ order detail
  @JsonKey(name: 'tracking_number')
  final String? trackingNumber;

  /// บริษัทขนส่ง (null = ยังไม่ได้จัดส่ง)
  @JsonKey(name: 'shipping_provider')
  final ShippingProviderData? shippingProvider;

  factory BrownyShopReceiptResponse.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopReceiptResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BrownyShopReceiptResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BrownyShopReceiptSummary {
  BrownyShopReceiptSummary({
    this.quantity,
    this.subtotal,
    this.discount,
    this.flashSaleDiscount,
    this.productDiscount,
    this.couponDiscount,
    this.shipping,
    this.total,
  });

  @JsonKey(name: 'quantity')
  final BrownyShopReceiptSummaryItem? quantity;

  @JsonKey(name: 'subtotal')
  final BrownyShopReceiptSummaryItem? subtotal;

  @JsonKey(name: 'discount')
  final BrownyShopReceiptSummaryItem? discount;

  @JsonKey(name: 'flash_sale_discount')
  final BrownyShopReceiptSummaryItem? flashSaleDiscount;

  @JsonKey(name: 'product_discount')
  final BrownyShopReceiptSummaryItem? productDiscount;

  /// `coupon_discount` มี field พิเศษ (code, coupon_name) นอกเหนือจาก wording/amount
  @JsonKey(name: 'coupon_discount')
  final BrownyShopReceiptSummaryItem? couponDiscount;

  @JsonKey(name: 'shipping')
  final BrownyShopReceiptSummaryItem? shipping;

  @JsonKey(name: 'total')
  final BrownyShopReceiptSummaryItem? total;

  factory BrownyShopReceiptSummary.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopReceiptSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$BrownyShopReceiptSummaryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BrownyShopReceiptSummaryItem {
  BrownyShopReceiptSummaryItem({
    this.wording,
    this.amount,
    this.code,
    this.couponName,
  });

  @JsonKey(name: 'wording')
  final ContentLocalizeData? wording;

  @JsonKey(name: 'amount')
  final String? amount;

  /// เฉพาะ coupon_discount — โค้ดคูปองที่ใช้ (เช่น "PROMO2026")
  @JsonKey(name: 'code')
  final String? code;

  /// เฉพาะ coupon_discount — ชื่อคูปอง (multi-language)
  @JsonKey(name: 'coupon_name')
  final ContentLocalizeData? couponName;

  factory BrownyShopReceiptSummaryItem.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopReceiptSummaryItemFromJson(json);

  Map<String, dynamic> toJson() => _$BrownyShopReceiptSummaryItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BrownyShopReceiptItem {
  BrownyShopReceiptItem({
    this.productId,
    this.productSubId,
    this.quantity,
    this.name,
    this.unit,
    this.imageUrl,
    this.unitMoneyPrice,
    this.originalMoneyPrice,
    this.lineSubtotal,
    this.flashSaleDiscount,
    this.productDiscount,
    this.unitShippingFee,
    this.isFlashSale,
  });

  @JsonKey(name: 'product_id')
  final String? productId;

  @JsonKey(name: 'product_sub_id')
  final int? productSubId;

  @JsonKey(name: 'quantity')
  final int? quantity;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  @JsonKey(name: 'unit')
  final ContentLocalizeData? unit;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @JsonKey(name: 'unit_money_price')
  final num? unitMoneyPrice;

  @JsonKey(name: 'original_money_price')
  final num? originalMoneyPrice;

  @JsonKey(name: 'line_subtotal')
  final num? lineSubtotal;

  @JsonKey(name: 'flash_sale_discount')
  final num? flashSaleDiscount;

  @JsonKey(name: 'product_discount')
  final num? productDiscount;

  @JsonKey(name: 'unit_shipping_fee')
  final num? unitShippingFee;

  @JsonKey(name: 'is_flash_sale')
  final bool? isFlashSale;

  factory BrownyShopReceiptItem.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopReceiptItemFromJson(json);

  Map<String, dynamic> toJson() => _$BrownyShopReceiptItemToJson(this);
}
