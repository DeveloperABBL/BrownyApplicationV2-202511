import 'package:browny_applications_new/core/data/remote/models/response/machine_order_receipt_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:flutter/material.dart';

/// Extension สำหรับ MachineOrderReceiptResponse เพื่อใช้แสดงผล UI
extension MachineOrderReceiptResponseDisplay on MachineOrderReceiptResponse {
  /// แสดงวันที่ตาม locale
  /// th: 31 ส.ค. 68 16:20 น.
  /// en: 31 Aug 26 16:20
  String receiptDateDisplay(BuildContext context) {
    if (paidAt == null) return '';

    final locale = context.languageCode;
    return paidAt!.formatDateDDMMMMyyyyHHmmMinText(
      locale,
      pattern: 'dd MMM yy - HH:mm',
      thYear: locale == 'th',
    );
  }

  /// แปลง payment channel เป็น brand name ตาม locale
  String paymentMethodNameDisplay(BuildContext context) {
    if (paymentChannel == null) return '';

    // ใช้ paymentDisplay ถ้ามี (backend ส่งมาตาม locale)
    if (paymentDisplay != null) {
      return paymentDisplay!.getTextByLocale(context.languageCode);
    }

    // Fallback: แปลงจาก paymentChannel เอง
    final locale = context.languageCode;
    switch (paymentChannel) {
      case 'qr':
        switch (locale) {
          case 'en':
          case 'zh':
            return 'QR Promptpay';
          default:
            return 'QR พร้อมเพย์';
        }
      case 'credit_card':
        return 'Credit Card';
      case 'true_money':
        return 'TrueMoney Wallet';
      case 'tp_wallet':
        return 'TP Wallet';
      case 'shopee_pay':
        return 'ShopeePay';
      default:
        return paymentChannel!;
    }
  }

  /// แสดงชื่อสาขาตาม locale
  String branchNameDisplay(BuildContext context) {
    if (branch == null) return '';
    return branch!.getTextByLocale(context.languageCode);
  }

  /// แสดงประเภทเครื่องตาม locale
  String machineTypeDisplay(BuildContext context) {
    if (machineType == null) return '';
    return machineType!.getTextByLocale(context.languageCode);
  }

  /// แสดงราคารวม (formatted)
  String get totalFormatted {
    if (total == null) return '฿0.00';
    return '฿$total';
  }

  /// แสดงหมายเลขเครื่อง
  String get machineNoDisplay {
    if (machineNo == null) return '-';
    return machineNo.toString();
  }

  /// ตรวจสอบว่ามี summary item หรือไม่
  bool get hasSummary => summary != null;

  /// แสดงราคา program
  String get programPrice {
    if (summary?.program?.amount == null) return '';
    return '฿${summary!.program!.amount}';
  }

  /// แสดงชื่อ program ตาม locale
  String programNameDisplay(BuildContext context) {
    if (summary?.program?.wording == null) return '0.00';
    return summary!.program!.wording!.getTextByLocale(context.languageCode);
  }

  /// แสดงส่วนลด
  String get discountAmount {
    if (summary?.discount?.amount == null) return '0.00';
    return '฿${summary!.discount!.amount.ifNullOrEmpty('0.00')}';
  }

  /// แสดงชื่อส่วนลดตาม locale
  String discountNameDisplay(BuildContext context) {
    if (summary?.discount?.wording == null) return '0.00';
    return summary!.discount!.wording!.getTextByLocale(context.languageCode);
  }

  /// แสดง coupon discount amount
  String get couponDiscountAmount {
    if (summary?.couponDiscount?.amount == null) return '0.00';
    return '฿${summary!.couponDiscount!.amount.ifNullOrEmpty('0.00')}';
  }

  /// แสดงชื่อ coupon discount ตาม locale
  String couponDiscountNameDisplay(BuildContext context) {
    if (summary?.couponDiscount?.wording == null) return '';
    return summary!.couponDiscount!.wording!.getTextByLocale(
      context.languageCode,
    );
  }

  /// แสดง e-voucher amount
  String get couponEvoucherAmount {
    if (summary?.couponEvoucher?.amount == null) return '0.00';
    return '฿${summary!.couponEvoucher!.amount.ifNullOrEmpty('0.00')}';
  }

  /// แสดงชื่อ e-voucher ตาม locale
  String couponEvoucherNameDisplay(BuildContext context) {
    if (summary?.couponEvoucher?.wording == null) return '';
    return summary!.couponEvoucher!.wording!.getTextByLocale(
      context.languageCode,
    );
  }

  /// ตรวจสอบว่ามี discount หรือไม่
  bool get hasDiscount =>
      summary?.discount != null && summary?.discount!.amount.orEmpty != '';

  /// ตรวจสอบว่ามี coupon discount หรือไม่
  bool get hasCouponDiscount =>
      summary?.couponDiscount != null &&
      summary?.couponDiscount?.amount.orEmpty != '';

  /// ตรวจสอบว่ามี e-voucher หรือไม่
  bool get hasCouponEvoucher =>
      summary?.couponEvoucher != null &&
      summary?.couponEvoucher?.amount.orEmpty != '';

  /// ตรวจสอบว่ามี lucky number หรือไม่
  bool get hasLuckyNo => luckyNo != null && luckyNo!.isNotEmpty;

  /// ตรวจสอบว่ามี lucky image หรือไม่
  bool get hasLuckyImage => luckyImage != null && luckyImage!.isNotEmpty;
}
