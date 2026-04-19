import 'package:browny_applications_new/core/const/app_constants.dart';
import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coupon_receipt_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:flutter/material.dart';

class CouponReceiptModel extends CouponReceiptData {
  CouponReceiptModel({
    super.receiptAt,
    super.totalPrice,
    super.netPrice,
    super.savePrice,
    super.receiptNo,
    super.paymentMethod,
    super.paymentIcon,
    super.packageName,
    super.luckyNo,
    super.luckyImage,
    super.qrImage,
    super.bonus,
  });

  /// Factory constructor สำหรับแปลง CouponReceiptData เป็น CouponReceiptModel
  factory CouponReceiptModel.fromCouponReceiptData(CouponReceiptData data) {
    return CouponReceiptModel(
      receiptAt: data.receiptAt,
      totalPrice: data.totalPrice,
      netPrice: data.netPrice,
      savePrice: data.savePrice,
      receiptNo: data.receiptNo,
      paymentMethod: data.paymentMethod,
      paymentIcon: data.paymentIcon,
      packageName: data.packageName,
      luckyNo: data.luckyNo,
      luckyImage: data.luckyImage,
      qrImage: data.qrImage,
      bonus: data.bonus,
    );
  }

  /// Copy with method
  CouponReceiptModel copyWith({
    DateTime? receiptAt,
    String? totalPrice,
    String? netPrice,
    String? savePrice,
    String? receiptNo,
    String? paymentMethod,
    String? paymentIcon,
    ContentLocalizeData? packageName,
    String? luckyNo,
    String? luckyImage,
    String? qrImage,
    String? bonus,
  }) {
    return CouponReceiptModel(
      receiptAt: receiptAt ?? this.receiptAt,
      totalPrice: totalPrice ?? this.totalPrice,
      netPrice: netPrice ?? this.netPrice,
      savePrice: savePrice ?? this.savePrice,
      receiptNo: receiptNo ?? this.receiptNo,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentIcon: paymentIcon ?? this.paymentIcon,
      packageName: packageName ?? this.packageName,
      luckyNo: luckyNo ?? this.luckyNo,
      luckyImage: luckyImage ?? this.luckyImage,
      qrImage: qrImage ?? this.qrImage,
      bonus: bonus ?? this.bonus,
    );
  }
}

/// Extension สำหรับ CouponReceiptData/CouponReceiptModel พร้อม display methods
extension CouponReceiptDataDisplay on CouponReceiptData {
  /// แสดงวันที่ตาม locale
  /// th: 31 ส.ค. 68 16:20 น.
  /// en: 31 Aug 26 16:20
  String receiptDateDisplay(BuildContext context) {
    if (receiptAt == null) return '';

    final locale = context.languageCode;
    return receiptAt!.formatDateDDMMMMyyyyHHmmMinText(
      locale,
      pattern: 'dd MMM yy HH:mm',
      thYear: locale == 'th',
    );
  }

  /// แปลง payment method เป็น brand name ตาม locale
  String paymentMethodNameDisplay(BuildContext context) {
    if (paymentMethod == null) return '';
    final locale = context.languageCode;
    switch (paymentMethod) {
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
      case 'shopee_pay':
        return 'ShopeePay';
      case 'wechat':
        return 'WeChat Pay';
      case 'rabbit_line':
        return 'Rabbit LinePay';
      case 'tp_wallet':
        return 'TP+ Wallet';
      default:
        return paymentMethod ?? '';
    }
  }

  /// ดึง localized package name
  String packageNameDisplay(BuildContext context) {
    final locale = context.languageCode;
    return packageName?.getTextByLocale(locale) ?? '';
  }

  /// Format total price เป็น String พร้อมสกุลเงิน
  String get totalPriceFormatted =>
      formatCurrency(string: totalPrice, leadingSign: '฿ ');

  /// Format net price เป็น String พร้อมสกุลเงิน
  String get netPriceFormatted =>
      formatCurrency(string: netPrice, leadingSign: '฿ ');

  /// Format save price เป็น String พร้อมสกุลเงิน
  String get savePriceFormatted =>
      formatCurrency(string: savePrice, leadingSign: '฿ ');

  /// ตรวจสอบว่า payment method เป็น TP+ Wallet หรือไม่
  bool get isTpWalletPayment => paymentMethod?.toLowerCase() == 'tp_wallet';

  /// ตรวจสอบว่า payment method เป็น QR Promptpay หรือไม่
  bool get isQrPayment => paymentMethod?.toLowerCase() == 'qr';

  /// ตรวจสอบว่ามี lucky number หรือไม่
  bool get hasLuckyNumber => luckyNo != null && luckyNo!.isNotEmpty;

  /// ตรวจสอบว่ามี QR image หรือไม่
  bool get hasQrImage => qrImage != null && qrImage!.isNotEmpty;
}
