import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coupon_data_response.dart';
import 'package:browny_applications_new/core/utils/json_converters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'checkout_draft_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-26
///
/// Response model สำหรับ POST /browny-shop/checkout/draft — สร้าง draft order
/// ก่อนชำระเงิน (รวมยอด, ส่วนลด, ที่อยู่จัดส่ง, รายการสินค้า)
@JsonSerializable()
class CheckoutDraftResponse extends BaseModelResponse {
  CheckoutDraftResponse({
    this.data,
    super.success,
    super.message,
    super.errorType,
  });

  @JsonKey(name: 'data')
  final CheckoutDraftData? data;

  factory CheckoutDraftResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckoutDraftResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      baseToJson(_$CheckoutDraftResponseToJson(this));
}

/// ข้อมูล draft order
@JsonSerializable()
class CheckoutDraftData {
  CheckoutDraftData({
    this.id,
    this.customerId,
    this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.paymentRef,
    this.subtotal,
    this.shippingTotal,
    this.flashSaleDiscount,
    this.productDiscount,
    this.couponDiscount,
    this.discountAmount,
    this.priceOriginal,
    this.priceFinal,
    this.coinAmountUsed,
    this.coinValue,
    this.expiresAt,
    this.paidAt,
    this.receiptNo,
    this.customerAddressId,
    this.shippingAddress,
    this.items,
    this.summary,
    this.paymentUrl,
    this.responsePayload,
  });

  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'customer_id')
  final String? customerId;

  /// "draft", "confirmed", "paid", ...
  @JsonKey(name: 'status')
  final String? status;

  /// "qr", "tp_wallet", "coin", ...
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;

  /// "pending", "paid", "failed", ...
  @JsonKey(name: 'payment_status')
  final String? paymentStatus;

  @JsonKey(name: 'payment_ref')
  final String? paymentRef;

  /// ยอดรวมสินค้าก่อนหักส่วนลด
  @JsonKey(name: 'subtotal')
  final num? subtotal;

  /// ค่าจัดส่งรวม
  @JsonKey(name: 'shipping_total')
  final num? shippingTotal;

  /// ส่วนลดจาก Flash Sale
  @JsonKey(name: 'flash_sale_discount')
  final num? flashSaleDiscount;

  /// ส่วนลดสินค้า
  @JsonKey(name: 'product_discount')
  final num? productDiscount;

  /// ส่วนลดจากคูปอง
  @JsonKey(name: 'coupon_discount')
  final num? couponDiscount;

  /// ผลรวมส่วนลดทั้งหมด
  @JsonKey(name: 'discount_amount')
  final num? discountAmount;

  /// ราคาก่อนหักส่วนลด
  @JsonKey(name: 'price_original')
  final num? priceOriginal;

  /// ยอดที่ต้องชำระจริง
  @JsonKey(name: 'price_final')
  final num? priceFinal;

  /// จำนวน coin ที่ใช้ในการชำระ
  @JsonKey(name: 'coin_amount_used')
  final num? coinAmountUsed;

  /// อัตราแลกเปลี่ยน coin → เงิน (เช่น 10 coin = 1 บาท)
  @JsonKey(name: 'coin_value')
  final num? coinValue;

  /// เวลาที่ draft order นี้จะหมดอายุ
  @JsonKey(name: 'expires_at')
  @DateTimeConverter()
  final DateTime? expiresAt;

  /// เวลาที่ชำระเงินสำเร็จ (null ถ้ายังไม่ชำระ)
  @JsonKey(name: 'paid_at')
  @DateTimeConverter()
  final DateTime? paidAt;

  /// เลขที่ใบเสร็จ (มีเมื่อชำระสำเร็จ)
  @JsonKey(name: 'receipt_no')
  final String? receiptNo;

  /// id ของที่อยู่จัดส่งที่ใช้
  @JsonKey(name: 'customer_address_id')
  final int? customerAddressId;

  /// ข้อมูลที่อยู่จัดส่ง (snapshot ตอนสร้าง order)
  @JsonKey(name: 'shipping_address')
  final CheckoutShippingAddressData? shippingAddress;

  /// รายการสินค้าใน order
  @JsonKey(name: 'items')
  final List<CheckoutItemData>? items;

  /// สรุปยอด + breakdown ต่อบรรทัด — มีเฉพาะ GET /checkout/{orderId}
  /// (POST /checkout/draft จะเป็น null)
  @JsonKey(name: 'summary')
  final CheckoutSummaryData? summary;

  /// URL สำหรับเปิดหน้าจ่ายเงิน (null เมื่อชำระทันที เช่น coin/wallet/free)
  @JsonKey(name: 'payment_url')
  final String? paymentUrl;

  /// payload การชำระเงิน — QR (qrcode/wechat) หรือ ข้อมูล coin/wallet/free
  @JsonKey(name: 'response_payload')
  final CheckoutResponsePayload? responsePayload;

  factory CheckoutDraftData.fromJson(Map<String, dynamic> json) =>
      _$CheckoutDraftDataFromJson(json);

  Map<String, dynamic> toJson() => _$CheckoutDraftDataToJson(this);
}

/// payload การชำระเงินที่ได้จาก confirm / get order
/// - QR/WeChat: ใช้ [qrcode]/[wechat] render QR โดยตรง (เหมือน machine-order)
/// - coin/wallet/free: ใช้ [method], [amount], [coinAmountUsed]
@JsonSerializable()
class CheckoutResponsePayload {
  CheckoutResponsePayload({
    this.qrcode,
    this.wechat,
    this.method,
    this.amount,
    this.coinAmountUsed,
  });

  @JsonKey(name: 'qrcode')
  final String? qrcode;

  @JsonKey(name: 'wechat')
  final String? wechat;

  @JsonKey(name: 'method')
  final String? method;

  @JsonKey(name: 'amount')
  final num? amount;

  @JsonKey(name: 'coin_amount_used')
  final num? coinAmountUsed;

  factory CheckoutResponsePayload.fromJson(Map<String, dynamic> json) =>
      _$CheckoutResponsePayloadFromJson(json);

  Map<String, dynamic> toJson() => _$CheckoutResponsePayloadToJson(this);
}

/// ที่อยู่จัดส่ง — snapshot ใน checkout (มี recipient_name, country เพิ่มจาก
/// AddressData ปกติ จึงแยก class ออกมา)
@JsonSerializable()
class CheckoutShippingAddressData {
  CheckoutShippingAddressData({
    this.id,
    this.recipientName,
    this.firstName,
    this.lastName,
    this.phone,
    this.zipcode,
    this.province,
    this.district,
    this.subdistrict,
    this.address,
    this.fullAddress,
    this.country,
    this.note,
  });

  @JsonKey(name: 'id')
  final int? id;

  /// ชื่อ-นามสกุลผู้รับรวม
  @JsonKey(name: 'recipient_name')
  final String? recipientName;

  @JsonKey(name: 'first_name')
  final String? firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  @JsonKey(name: 'phone')
  final String? phone;

  @JsonKey(name: 'zipcode')
  final String? zipcode;

  @JsonKey(name: 'province')
  final String? province;

  @JsonKey(name: 'district')
  final String? district;

  @JsonKey(name: 'subdistrict')
  final String? subdistrict;

  /// เลขที่/บ้านเลขที่
  @JsonKey(name: 'address')
  final String? address;

  /// ที่อยู่แบบเต็มที่ server format มาให้
  @JsonKey(name: 'full_address')
  final String? fullAddress;

  @JsonKey(name: 'country')
  final String? country;

  @JsonKey(name: 'note')
  final String? note;

  factory CheckoutShippingAddressData.fromJson(Map<String, dynamic> json) =>
      _$CheckoutShippingAddressDataFromJson(json);

  Map<String, dynamic> toJson() => _$CheckoutShippingAddressDataToJson(this);
}

/// 1 รายการสินค้าใน draft order
@JsonSerializable()
class CheckoutItemData {
  CheckoutItemData({
    this.productId,
    this.productSubId,
    this.quantity,
    this.unitCoinPrice,
    this.unitMoneyPrice,
    this.lineSubtotal,
    this.unitShippingFee,
    this.isFlashSale,
  });

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

  /// ยอดรวมของบรรทัดนี้
  @JsonKey(name: 'line_subtotal')
  final num? lineSubtotal;

  /// ค่าจัดส่งต่อหน่วย
  @JsonKey(name: 'unit_shipping_fee')
  final num? unitShippingFee;

  @JsonKey(name: 'is_flash_sale')
  final bool? isFlashSale;

  factory CheckoutItemData.fromJson(Map<String, dynamic> json) =>
      _$CheckoutItemDataFromJson(json);

  Map<String, dynamic> toJson() => _$CheckoutItemDataToJson(this);
}

/// สรุปยอด + breakdown ต่อบรรทัด — มีเฉพาะใน GET /checkout/{orderId}
///
/// แยกจาก [CheckoutDraftData] เพราะ field ไม่เหมือนกันทั้งหมด
/// (เช่น `final_price` vs `price_final`, มี `total_discount`, แต่ละ item
/// มี breakdown ราคาเดิม + ส่วนลด)
@JsonSerializable()
class CheckoutSummaryData {
  CheckoutSummaryData({
    this.success,
    this.subtotal,
    this.shippingTotal,
    this.flashSaleDiscount,
    this.productDiscount,
    this.couponDiscount,
    this.totalDiscount,
    this.priceOriginal,
    this.finalPrice,
    this.coinAmountRequired,
    this.coinValue,
    this.couponCustomerId,
    this.paymentMethod,
    this.coupon,
    this.items,
  });

  @JsonKey(name: 'success')
  final bool? success;

  @JsonKey(name: 'subtotal')
  final num? subtotal;

  @JsonKey(name: 'shipping_total')
  final num? shippingTotal;

  @JsonKey(name: 'flash_sale_discount')
  final num? flashSaleDiscount;

  @JsonKey(name: 'product_discount')
  final num? productDiscount;

  @JsonKey(name: 'coupon_discount')
  final num? couponDiscount;

  /// รวมส่วนลดทั้งหมด
  @JsonKey(name: 'total_discount')
  final num? totalDiscount;

  @JsonKey(name: 'price_original')
  final num? priceOriginal;

  /// ยอดที่ต้องชำระจริง (ใน summary ใช้ key `final_price`)
  @JsonKey(name: 'final_price')
  final num? finalPrice;

  /// จำนวน coin ที่ต้องใช้ (null ถ้าไม่ได้จ่ายด้วย coin)
  @JsonKey(name: 'coin_amount_required')
  final num? coinAmountRequired;

  @JsonKey(name: 'coin_value')
  final num? coinValue;

  /// id คูปองที่ใช้ — null ถ้าไม่ใช้คูปอง
  @JsonKey(name: 'coupon_customer_id')
  final int? couponCustomerId;

  @JsonKey(name: 'payment_method')
  final String? paymentMethod;

  /// ข้อมูลคูปองที่ใช้ (มีเฉพาะเมื่อส่ง coupon_customer_id และคูปองใช้ได้)
  @JsonKey(name: 'coupon')
  final CouponData? coupon;

  @JsonKey(name: 'items')
  final List<CheckoutSummaryItemData>? items;

  factory CheckoutSummaryData.fromJson(Map<String, dynamic> json) =>
      _$CheckoutSummaryDataFromJson(json);

  Map<String, dynamic> toJson() => _$CheckoutSummaryDataToJson(this);
}

/// 1 รายการใน [CheckoutSummaryData.items] — ละเอียดกว่า [CheckoutItemData]
/// (มีราคาเดิม + ส่วนลดต่อบรรทัด)
@JsonSerializable()
class CheckoutSummaryItemData {
  CheckoutSummaryItemData({
    this.productId,
    this.productSubId,
    this.quantity,
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
  });

  @JsonKey(name: 'product_id')
  final String? productId;

  @JsonKey(name: 'product_sub_id')
  final int? productSubId;

  @JsonKey(name: 'quantity')
  final int? quantity;

  /// ราคาต่อหน่วยปัจจุบัน — coin
  @JsonKey(name: 'unit_coin_price')
  final num? unitCoinPrice;

  /// ราคาต่อหน่วยปัจจุบัน — money
  @JsonKey(name: 'unit_money_price')
  final num? unitMoneyPrice;

  /// ราคาเดิม (ก่อนส่วนลด) — coin
  @JsonKey(name: 'original_coin_price')
  final num? originalCoinPrice;

  /// ราคาเดิม (ก่อนส่วนลด) — money
  @JsonKey(name: 'original_money_price')
  final num? originalMoneyPrice;

  @JsonKey(name: 'is_flash_sale')
  final bool? isFlashSale;

  /// id Flash Sale ที่ active กับสินค้านี้ (null ถ้าไม่อยู่ใน flash sale)
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

  factory CheckoutSummaryItemData.fromJson(Map<String, dynamic> json) =>
      _$CheckoutSummaryItemDataFromJson(json);

  Map<String, dynamic> toJson() => _$CheckoutSummaryItemDataToJson(this);
}
