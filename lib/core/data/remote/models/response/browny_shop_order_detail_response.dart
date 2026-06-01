import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/browny_shop_receipt_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/checkout_draft_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/shipping_provider_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'browny_shop_order_detail_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-31
///
/// Response สำหรับ GET /browny-shop/orders/{orderId} — รายละเอียดออร์เดอร์ +
/// สถานะ (stepper) ใช้กับหน้า [BrownyShopOrderStatusPage]
@JsonSerializable(explicitToJson: true)
class BrownyShopOrderDetailResponse extends BaseModelResponse {
  BrownyShopOrderDetailResponse({
    super.success,
    super.message,
    super.errorType,
    this.data,
  });

  @JsonKey(name: 'data')
  final BrownyShopOrderDetailData? data;

  factory BrownyShopOrderDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopOrderDetailResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      baseToJson(_$BrownyShopOrderDetailResponseToJson(this));
}

@JsonSerializable(explicitToJson: true)
class BrownyShopOrderDetailData {
  BrownyShopOrderDetailData({
    this.type,
    this.orderId,
    this.paymentRef,
    this.receiptNo,
    this.status,
    this.statusLabel,
    this.statusSteps,
    this.trackingNumber,
    this.shippingProvider,
    this.priceOriginal,
    this.priceFinal,
    this.amount,
    this.discountAmount,
    this.totalQuantity,
    this.itemCount,
    this.paymentMethod,
    this.paymentIcon,
    this.paymentChannel,
    this.paymentDisplay,
    this.createdAt,
    this.paidAt,
    this.shippedAt,
    this.deliveredAt,
    this.deliveryDate,
    this.receiptAt,
    this.reviewScore,
    this.bonus,
    this.qrImage,
    this.shippingAddress,
    this.items,
    this.summary,
    this.callCenter,
    this.lineLink,
  });

  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'order_id')
  final String? orderId;

  @JsonKey(name: 'payment_ref')
  final String? paymentRef;

  @JsonKey(name: 'receipt_no')
  final String? receiptNo;

  /// "pending_payment" | "pending_shipment" | "delivered" | "cancelled"
  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'status_label')
  final ContentLocalizeData? statusLabel;

  @JsonKey(name: 'status_steps')
  final BrownyShopOrderStatusStepsData? statusSteps;

  @JsonKey(name: 'tracking_number')
  final String? trackingNumber;

  /// บริษัทขนส่ง (null = ยังไม่ได้จัดส่ง)
  @JsonKey(name: 'shipping_provider')
  final ShippingProviderData? shippingProvider;

  @JsonKey(name: 'price_original')
  final String? priceOriginal;

  @JsonKey(name: 'price_final')
  final String? priceFinal;

  @JsonKey(name: 'amount')
  final String? amount;

  @JsonKey(name: 'discount_amount')
  final String? discountAmount;

  @JsonKey(name: 'total_quantity')
  final int? totalQuantity;

  @JsonKey(name: 'item_count')
  final int? itemCount;

  /// key วิธีชำระเงิน (qr / coin / tp_wallet / ...)
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;

  /// URL ไอคอนวิธีชำระเงิน
  @JsonKey(name: 'payment_icon')
  final String? paymentIcon;

  /// channel วิธีชำระเงิน (เช่น "qr")
  @JsonKey(name: 'payment_channel')
  final String? paymentChannel;

  @JsonKey(name: 'payment_display')
  final ContentLocalizeData? paymentDisplay;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'paid_at')
  final String? paidAt;

  @JsonKey(name: 'shipped_at')
  final String? shippedAt;

  @JsonKey(name: 'delivered_at')
  final String? deliveredAt;

  @JsonKey(name: 'delivery_date')
  final String? deliveryDate;

  @JsonKey(name: 'receipt_at')
  final String? receiptAt;

  /// คะแนนรีวิว (null = ยังไม่เคยรีวิว)
  @JsonKey(name: 'review_score')
  final int? reviewScore;

  /// Browny Coin โบนัสรวมที่ได้รับ
  @JsonKey(name: 'bonus')
  final String? bonus;

  /// QR สำหรับฝ่าย Browny Support
  @JsonKey(name: 'qr_image')
  final String? qrImage;

  /// ที่อยู่จัดส่ง — reuse [CheckoutShippingAddressData]
  @JsonKey(name: 'shipping_address')
  final CheckoutShippingAddressData? shippingAddress;

  @JsonKey(name: 'items')
  final List<BrownyShopOrderDetailItem>? items;

  /// สรุปยอด — reuse [BrownyShopReceiptSummary] (order detail ส่งมาแค่ total)
  @JsonKey(name: 'summary')
  final BrownyShopReceiptSummary? summary;

  @JsonKey(name: 'call_center')
  final String? callCenter;

  @JsonKey(name: 'line_link')
  final String? lineLink;

  /// ป้ายสถานะตาม locale
  String getStatusLabelDisplay(String locale) {
    return statusLabel?.getByLocaleCode(locale) ?? '';
  }

  /// ชื่อวิธีชำระเงินตาม locale
  String getPaymentDisplay(String locale) {
    return paymentDisplay?.getByLocaleCode(locale) ?? '';
  }

  /// รอชำระเงิน → hero ใช้ browny_warning_transfer + ปุ่มล่าง "ชำระเงิน"
  bool get isPendingPayment => status?.toLowerCase() == 'pending_payment';

  /// ชำระแล้ว รอจัดส่ง
  bool get isPendingShipment => status?.toLowerCase() == 'pending_shipment';

  /// จัดส่งแล้ว
  bool get isDelivered => status?.toLowerCase() == 'delivered';

  /// ยกเลิกคำสั่งซื้อ
  bool get isCancelled => status?.toLowerCase() == 'cancelled';

  /// step "ชำระเงิน" active — อิง status_steps จาก server ก่อน, fallback ตามสถานะ
  bool get isPaymentConfirmed =>
      statusSteps?.paid?.isDone ?? (isPendingShipment || isDelivered);

  /// step "จัดส่ง" active — อิง status_steps จาก server ก่อน, fallback ตามสถานะ
  bool get isShipped => statusSteps?.shipping?.isDone ?? isDelivered;

  bool get hasTrackingNumber =>
      trackingNumber != null && trackingNumber!.isNotEmpty;

  /// Order ID ที่โชว์ให้ลูกค้า — ใช้ receipt_no ถ้ามี ไม่งั้นใช้ order_id (uuid)
  String get orderIdDisplay =>
      (receiptNo != null && receiptNo!.isNotEmpty) ? receiptNo! : (orderId ?? '');

  factory BrownyShopOrderDetailData.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopOrderDetailDataFromJson(json);

  Map<String, dynamic> toJson() => _$BrownyShopOrderDetailDataToJson(this);
}

/// 3 ขั้นของ stepper สถานะออร์เดอร์ (สั่งซื้อ → ชำระเงิน → จัดส่ง)
@JsonSerializable(explicitToJson: true)
class BrownyShopOrderStatusStepsData {
  BrownyShopOrderStatusStepsData({this.ordered, this.paid, this.shipping});

  @JsonKey(name: 'ordered')
  final BrownyShopOrderStatusStepData? ordered;

  @JsonKey(name: 'paid')
  final BrownyShopOrderStatusStepData? paid;

  @JsonKey(name: 'shipping')
  final BrownyShopOrderStatusStepData? shipping;

  factory BrownyShopOrderStatusStepsData.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopOrderStatusStepsDataFromJson(json);

  Map<String, dynamic> toJson() =>
      _$BrownyShopOrderStatusStepsDataToJson(this);
}

@JsonSerializable()
class BrownyShopOrderStatusStepData {
  BrownyShopOrderStatusStepData({this.done, this.at});

  /// ขั้นนี้ผ่านแล้วหรือยัง (active/inactive)
  @JsonKey(name: 'done')
  final bool? done;

  /// เวลาที่ขั้นนี้เกิดขึ้น (null = ยังไม่ถึง)
  @JsonKey(name: 'at')
  final String? at;

  bool get isDone => done ?? false;

  factory BrownyShopOrderStatusStepData.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopOrderStatusStepDataFromJson(json);

  Map<String, dynamic> toJson() =>
      _$BrownyShopOrderStatusStepDataToJson(this);
}

/// 1 รายการสินค้าใน order detail
@JsonSerializable(explicitToJson: true)
class BrownyShopOrderDetailItem {
  BrownyShopOrderDetailItem({
    this.productId,
    this.productSubId,
    this.quantity,
    this.name,
    this.unit,
    this.unitCoinPrice,
    this.unitMoneyPrice,
    this.originalCoinPrice,
    this.originalMoneyPrice,
    this.isFlashSale,
    this.flashSaleId,
    this.flashSaleDiscount,
    this.productDiscount,
    this.lineSubtotal,
    this.unitShippingFee,
    this.lineShippingFee,
    this.bonus,
    this.imageUrl,
  });

  @JsonKey(name: 'product_id')
  final String? productId;

  @JsonKey(name: 'product_sub_id')
  final int? productSubId;

  @JsonKey(name: 'quantity')
  final int? quantity;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  /// หน่วยสินค้า (เช่น ตัว / ใบ)
  @JsonKey(name: 'unit')
  final ContentLocalizeData? unit;

  /// ราคาต่อหน่วยปัจจุบัน — coin
  @JsonKey(name: 'unit_coin_price')
  final num? unitCoinPrice;

  /// ราคาต่อหน่วยปัจจุบัน — money
  @JsonKey(name: 'unit_money_price')
  final num? unitMoneyPrice;

  /// ราคาเดิม (ก่อนลด) — coin
  @JsonKey(name: 'original_coin_price')
  final num? originalCoinPrice;

  /// ราคาเดิม (ก่อนลด) — money
  @JsonKey(name: 'original_money_price')
  final num? originalMoneyPrice;

  @JsonKey(name: 'is_flash_sale')
  final bool? isFlashSale;

  /// id Flash Sale ที่ active (null ถ้าไม่อยู่ใน flash sale)
  @JsonKey(name: 'flash_sale_id')
  final int? flashSaleId;

  /// ส่วนลด Flash Sale ของบรรทัดนี้
  @JsonKey(name: 'flash_sale_discount')
  final num? flashSaleDiscount;

  /// ส่วนลดสินค้าของบรรทัดนี้
  @JsonKey(name: 'product_discount')
  final num? productDiscount;

  /// ยอดรวมของบรรทัดนี้
  @JsonKey(name: 'line_subtotal')
  final num? lineSubtotal;

  /// ค่าจัดส่งต่อหน่วย
  @JsonKey(name: 'unit_shipping_fee')
  final num? unitShippingFee;

  /// ค่าจัดส่งรวมของบรรทัดนี้
  @JsonKey(name: 'line_shipping_fee')
  final num? lineShippingFee;

  /// Browny Coin โบนัสของบรรทัดนี้
  @JsonKey(name: 'bonus')
  final String? bonus;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  /// ดึงชื่อสินค้าตาม locale
  String getNameDisplay(String locale) {
    return name?.getByLocaleCode(locale) ?? '';
  }

  /// ดึงหน่วยสินค้าตาม locale
  String getUnitDisplay(String locale) {
    return unit?.getByLocaleCode(locale) ?? '';
  }

  /// มีส่วนลด money (ราคาเดิม > ราคาขาย) → โชว์ราคาขีดฆ่า
  bool get hasMoneyDiscount =>
      originalMoneyPrice != null &&
      unitMoneyPrice != null &&
      originalMoneyPrice! > unitMoneyPrice!;

  /// มีส่วนลด coin (ราคาเดิม > ราคาขาย) → โชว์ราคาขีดฆ่า
  bool get hasCoinDiscount =>
      originalCoinPrice != null &&
      unitCoinPrice != null &&
      originalCoinPrice! > unitCoinPrice!;

  /// ส่งฟรี — ไม่มีค่าจัดส่งของบรรทัดนี้
  bool get isFreeShipping => (lineShippingFee ?? unitShippingFee ?? 0) <= 0;

  factory BrownyShopOrderDetailItem.fromJson(Map<String, dynamic> json) =>
      _$BrownyShopOrderDetailItemFromJson(json);

  Map<String, dynamic> toJson() => _$BrownyShopOrderDetailItemToJson(this);
}
