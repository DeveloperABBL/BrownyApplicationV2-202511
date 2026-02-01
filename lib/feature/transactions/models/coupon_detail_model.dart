import 'package:browny_applications_new/core/data/remote/models/response/coupon_detail_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:flutter/material.dart';

class CouponDetailModel extends CouponDetailResponse {
  CouponDetailModel({
    super.success,
    super.message,
    super.errorType,
    super.data,
    super.paymentMethods,
  });

  /// Factory constructor สำหรับแปลง CouponDetailResponse เป็น CouponDetailModel
  factory CouponDetailModel.fromResponse(CouponDetailResponse response) {
    return CouponDetailModel(
      success: response.success,
      message: response.message,
      errorType: response.errorType,
      data: response.data,
      paymentMethods: response.paymentMethods,
    );
  }

  /// ดึงข้อมูล Coupon
  CouponData? get coupon => data?.coupon;

  /// ดึงข้อมูล Packages ทั้งหมด
  List<PackageDetailData> get packages => data?.packages ?? [];

  /// ค้นหา Package ตาม packageId
  PackageDetailData? getPackageById(int packageId) {
    return packages.firstWhere(
      (pkg) => pkg.packageId == packageId,
      orElse: () => PackageDetailData(),
    );
  }

  /// ตรวจสอบว่ามี Package หรือไม่
  bool get hasPackages => packages.isNotEmpty;
}

/// Helper class สำหรับ CouponData พร้อม display methods
extension CouponDataDisplay on CouponData {
  /// ดึง localized usage duration text
  String usageDurationTextDisplay(BuildContext context) {
    final locale = context.languageCode;
    return usageDurationText?.getByLocaleCode(locale) ?? '';
  }

  /// ดึง localized coupon image URL
  String couponImageDisplay(BuildContext context) {
    final locale = context.languageCode;
    return couponImage?.getByLocaleCode(locale) ?? '';
  }

  /// ดึง localized coupon description (HTML)
  String couponDescriptionHTMLDisplay(BuildContext context) {
    final locale = context.languageCode;
    return couponDescription?.getByLocaleCode(locale) ?? '';
  }

  /// ดึง localized coupon description (Non-HTML)
  String couponDescriptionNonHTMLDisplay(BuildContext context) {
    final locale = context.languageCode;
    String content = couponDescription?.getByLocaleCode(locale) ?? '';
    return content
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }
}

/// Helper class สำหรับ PackageDetailData พร้อม display methods
extension PackageDetailDataDisplay on PackageDetailData {
  /// ดึง localized package name
  String packageNameDisplay(BuildContext context) {
    final locale = context.languageCode;
    return packageName?.getByLocaleCode(locale) ?? '';
  }

  /// ดึง localized usage label
  String usageLabelDisplay(BuildContext context) {
    final locale = context.languageCode;
    return usageLabel?.getByLocaleCode(locale) ?? '';
  }

  /// ดึง localized group option
  String groupOptionDisplay(BuildContext context) {
    final locale = context.languageCode;
    return groupOption?.getByLocaleCode(locale) ?? '';
  }

  /// ดึง localized store name
  String storeNameDisplay(BuildContext context) {
    final locale = context.languageCode;
    return store?.name?.getByLocaleCode(locale) ?? '';
  }

  /// แปลง price เป็น double
  double get priceValue => double.tryParse(price ?? '0') ?? 0.0;

  /// แปลง normal price เป็น double
  double get normalPriceValue => double.tryParse(normalPrice ?? '0') ?? 0.0;

  /// แปลง saved เป็น double
  double get savedValue => double.tryParse(saved ?? '0') ?? 0.0;

  /// แปลง discount percent เป็น double
  double get discountPercentValue =>
      double.tryParse(discountPercent ?? '0') ?? 0.0;

  /// แปลง browny coin เป็น int
  int get brownyCoinValue => int.tryParse(brownyCoin ?? '0') ?? 0;

  /// แปลง qty_washer เป็น int
  int get qtyWasherValue => int.tryParse(qtyWasher ?? '0') ?? 0;

  /// แปลง qty_dryer เป็น int
  int get qtyDryerValue => int.tryParse(qtyDryer ?? '0') ?? 0;

  /// แปลง distance meters เป็น double
  double get distanceMetersValue =>
      double.tryParse(store?.distanceMeters ?? '0') ?? 0.0;

  /// แปลง distance เป็น km
  double get distanceKm => distanceMetersValue / 1000;

  /// Format distance display
  String get distanceDisplay {
    if (distanceMetersValue >= 1000) {
      return '${distanceKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceMetersValue.toStringAsFixed(0)} m';
    }
  }

  /// ตรวจสอบว่ามีส่วนลดหรือไม่
  bool get hasDiscount => savedValue > 0 || discountPercentValue > 0;

  /// คำนวณเปอร์เซ็นต์ส่วนลดจากราคา
  double get calculatedDiscountPercentage {
    if (normalPriceValue <= 0) return 0.0;
    return ((normalPriceValue - priceValue) / normalPriceValue) * 100;
  }
}
