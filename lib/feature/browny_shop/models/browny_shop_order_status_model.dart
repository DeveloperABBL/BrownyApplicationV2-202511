import 'package:flutter/foundation.dart';

/// สถานะรวมของคำสั่งซื้อ Browny Shop — ขับ hero image (Frame 2087326612) +
/// stepper (Frame 2087326634)
///
/// TODO(api): ยังไม่มี API สถานะคำสั่งซื้อ Browny Shop — เมื่อ API พร้อมให้ map
/// flag จริง (รอชำระเงิน / ชำระแล้ว / จัดส่งแล้ว) มาที่ enum นี้
enum BrownyShopOrderStatusType {
  /// รอชำระเงิน — hero = browny_warning_transfer, step ชำระเงิน/จัดส่ง inactive
  pendingPayment,

  /// ชำระเงินแล้ว รอจัดส่ง — hero = browny_thank_you, step ชำระเงิน active
  paid,

  /// จัดส่งแล้ว — hero = browny_thank_you, step ชำระเงิน + จัดส่ง active
  delivered,
}

/// ข้อมูลสถานะคำสั่งซื้อสำหรับ render หน้า [BrownyShopOrderStatusPage]
@immutable
class BrownyShopOrderStatusModel {
  const BrownyShopOrderStatusModel({
    required this.orderId,
    required this.orderIdDisplay,
    required this.status,
    this.trackingNumber,
    required this.recipientName,
    required this.phone,
    required this.fullAddress,
    required this.products,
    required this.orderTotal,
    required this.paymentChannelName,
    this.paymentLogoUrl,
    this.orderTime,
    this.paymentTime,
    this.deliveryTime,
    this.qrImage,
  });

  /// id ดิบที่ใช้ fetch (UUID)
  final String orderId;

  /// Order ID ที่โชว์ให้ลูกค้า (เช่น "BB33O3O4O82O221xx")
  final String orderIdDisplay;

  final BrownyShopOrderStatusType status;

  /// เลขพัสดุ (null/ว่าง = ยังไม่ออกเลขพัสดุ → โชว์ปุ่มคัดลอกเปล่า)
  final String? trackingNumber;

  final String recipientName;
  final String phone;
  final String fullAddress;

  final List<BrownyShopOrderStatusProduct> products;

  /// ยอดรวมคำสั่งซื้อ
  final num orderTotal;

  final String paymentChannelName;
  final String? paymentLogoUrl;

  final String? orderTime;
  final String? paymentTime;
  final String? deliveryTime;

  /// QR สำหรับฝ่าย Browny Support
  final String? qrImage;

  /// รอชำระเงิน → hero ใช้ browny_warning_transfer (ตาม locale)
  bool get isPending => status == BrownyShopOrderStatusType.pendingPayment;

  /// step "ชำระเงิน" active เมื่อชำระเงินแล้ว
  bool get isPaymentConfirmed =>
      status != BrownyShopOrderStatusType.pendingPayment;

  /// step "จัดส่ง" active เมื่อจัดส่งแล้ว
  bool get isDelivered => status == BrownyShopOrderStatusType.delivered;

  bool get hasTrackingNumber =>
      trackingNumber != null && trackingNumber!.isNotEmpty;
}

/// 1 รายการสินค้าในหน้าสถานะคำสั่งซื้อ
@immutable
class BrownyShopOrderStatusProduct {
  const BrownyShopOrderStatusProduct({
    required this.name,
    this.imageUrl,
    required this.moneyPrice,
    this.originalMoneyPrice,
    this.coinPrice,
    this.originalCoinPrice,
    required this.quantity,
    this.isFreeShipping = false,
  });

  final String name;
  final String? imageUrl;

  /// ราคาสุทธิ (money)
  final num moneyPrice;

  /// ราคาเดิมก่อนลด (money) — null/≤ราคาสุทธิ = ไม่โชว์ขีดฆ่า
  final num? originalMoneyPrice;

  /// ราคาสุทธิ (coin)
  final num? coinPrice;
  final num? originalCoinPrice;

  final int quantity;
  final bool isFreeShipping;

  bool get hasMoneyDiscount =>
      originalMoneyPrice != null && originalMoneyPrice! > moneyPrice;
  bool get hasCoinDiscount =>
      originalCoinPrice != null &&
      coinPrice != null &&
      originalCoinPrice! > coinPrice!;
}
