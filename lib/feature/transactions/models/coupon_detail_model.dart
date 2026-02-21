import 'package:browny_applications_new/core/data/remote/models/response/coupon_detail_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/res/icons/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  List<PaymentMethodModel> paymentMethodsAvailable(String locale) {
    try {
      Map<String, dynamic> methodMap = super.paymentMethods!.toJson();
      List<PaymentMethodModel> result = [];
      String name = '';
      Widget? icon;
      for (final method in methodMap.keys) {
        switch (method) {
          case 'qr':
            {
              switch (locale) {
                case 'en':
                case 'zh':
                  name = 'QR Promptpay';
                  break;
                default:
                  name = 'QR พร้อมเพย์';
                  break;
              }
              icon = Assets.icPayment.icPromptpay.image(
                width: 22.w,
                height: 22.h,
              );
              break;
            }
          case 'credit_card':
            icon = null;
            name = 'Credit Card';
            break;
          case 'true_money':
            icon = Assets.icPayment.icTruemoney.image(
              width: 22.w,
              height: 22.h,
            );
            name = 'TrueMoney Wallet';
            break;
          case 'shopee_pay':
            icon = Assets.icPayment.icShopeepay.image(
              width: 22.w,
              height: 22.h,
            );
            name = 'ShopeePay';
            break;
          case 'wechat':
            icon = Assets.icPayment.icWechat.image(
              width: 22.w,
              height: 22.h,
            );
            name = 'WeChat Pay';
            break;
          case 'rabbit_line':
            icon = Assets.icPayment.icRabbitLinepay.image(
              width: 22.w,
              height: 22.h,
            );
            name = 'Rabbit LinePay';
            break;
          case 'tp_wallet':
            icon = Assets.svg.icTpWallet.svg(
              width: 22.w,
              height: 22.h,
            );
            name = 'TP+ Wallet';
            break;
        }
        result.add(
          PaymentMethodModel(
            method: method,
            name: name,
            isSelected: false,
            isActive: methodMap[method] as bool,
            icon: icon,
          ),
        );
      }

      return result.where((e) => e.isActive).toList().mapIndex((index, e) {
        // select ตัวแรก ที่ active
        if (index == 0) {
          return e.copyWith(isSelected: true);
        }
        return e;
      }).toList();
    } catch (_) {
      return [];
    }
  }
}

class PaymentMethodModel {
  final String method;
  final String name;
  final Widget? icon;
  final bool isSelected;
  final bool isActive;

  PaymentMethodModel({
    required this.method,
    required this.isSelected,
    required this.isActive,
    required this.name,
    this.icon,
  });

  PaymentMethodModel copyWith({
    String? method,
    String? name,
    Widget? icon,
    bool? isSelected,
    bool? isActive,
  }) => PaymentMethodModel(
    method: method ?? this.method,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    isSelected: isSelected ?? this.isSelected,
    isActive: isActive ?? this.isActive,
  );

  bool get isTpWallet => method == 'tp_wallet';
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
