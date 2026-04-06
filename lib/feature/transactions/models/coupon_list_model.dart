import 'package:browny_applications_new/core/data/remote/models/response/coupon_package_list_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:flutter/material.dart';

class CouponListModel extends CouponPackageListResponse {
  CouponListModel({
    super.success,
    super.data,
  });

  /// Factory constructor สำหรับแปลง CouponPackageListResponse เป็น CouponListModel
  factory CouponListModel.fromResponse(CouponPackageListResponse response) {
    return CouponListModel(
      success: response.success,
      data: response.data,
    );
  }

  /// ดึงรายการแพ็คเกจที่ใช้งานได้ (ยังไม่หมดอายุ)
  List<CouponPackageItem> getActivePackages() {
    if (data == null) return [];
    final now = DateTime.now();
    return data!
        .where((pkg) {
          final endDate = pkg.endDate;
          if (endDate == null || endDate.isEmpty) return true;
          try {
            final end = DateTime.parse(endDate);
            return end.isAfter(now);
          } catch (e) {
            return true;
          }
        })
        .map((pkg) => CouponPackageItem.fromData(pkg))
        .toList();
  }
}

/// Model สำหรับแพ็คเกจคูปองแต่ละรายการ พร้อม helper methods
class CouponPackageItem {
  final CouponPackageData _data;

  CouponPackageItem.fromData(this._data);

  /// ดึงข้อมูลต้นฉบับ
  CouponPackageData get data => _data;

  /// ดึง localized name/coupon name
  String couponNameDisplay(BuildContext context) {
    final locale = context.languageCode;
    return _data.couponName?.getByLocaleCode(locale) ?? '';
  }

  /// ดึง localized coupon image URL
  String couponImageDisplay(BuildContext context) {
    final locale = context.languageCode;
    return _data.couponImage?.getByLocaleCode(locale) ?? '';
  }

  /// ดึง localized description
  String couponDescriptionNonHTMLDisplay(BuildContext context) {
    final locale = context.languageCode;
    String content = _data.couponDescription?.getByLocaleCode(locale) ?? '';
    return content
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  /// ดึง localized description HTML
  String couponDescriptionHTMLDisplay(BuildContext context) {
    final locale = context.languageCode;
    return _data.couponDescription?.getByLocaleCode(locale) ?? '';
  }

  /// ดึง localized usage label
  String usageLabelDisplay(BuildContext context) {
    final locale = context.languageCode;
    return _data.usageLabel?.getByLocaleCode(locale) ?? '';
  }

  /// ดึง localized store name
  String storeNameDisplay(BuildContext context) {
    final locale = context.languageCode;
    return _data.storeName?.getByLocaleCode(locale) ?? '';
  }

  /// ดึง localized usage duration text
  String usageDurationTextDisplay(BuildContext context) {
    final locale = context.languageCode;
    return _data.usageDurationText?.getByLocaleCode(locale) ?? '';
  }

  // String getDistaceDisplay(
  //   String locale, {
  //   bool needSymbol = false,
  // }) {
  //   if (distance == null) {
  //     return '-';
  //   }
  //   // Unit ที่จะแสดงหน้า UI
  //   String unit;
  //   // symbol < > จากการคำนวณระยะห่างแบบ round แล้ว
  //   String symbol = '';

  //   switch (locale) {
  //     case 'zh':
  //     case 'en':
  //       unit = 'm';
  //       break;
  //     default:
  //       unit = 'ม.';
  //   }
  //   // ดักไว้ถ้าค่าติดลบ(อาจจะไม่เกิด) จะ return 0
  //   if (distance! < 0) {
  //     return '$distance $unit';
  //   }

  //   double distanceRounded = distance!.roundToDouble();
  //   if (needSymbol) {
  //     if (distanceRounded != distance!) {
  //       if (distanceRounded > distance!) {
  //         symbol = "<";
  //       } else {
  //         symbol = ">";
  //       }
  //     }
  //   }

  //   // ถ้าค่าเกิน 1000 เมตร จะคำนวณเป็น กม.
  //   if (distance! > 1000) {
  //     distanceRounded = (distance! / 1000.0);

  //     switch (locale) {
  //       case 'zh':
  //       case 'en':
  //         unit = 'km';
  //         break;
  //       default:
  //         unit = 'กม.';
  //     }
  //   }
  //   return formatDistance(
  //     leadingSign: symbol,
  //     value: distanceRounded,
  //     trailingSign: ' $unit',
  //   );
  //   // return '$symbol${distanceRounded.toInt()} $unit';
  // }

  /// แปลง price เป็น double
  double get priceValue => double.tryParse(_data.price ?? '0') ?? 0.0;

  /// แปลง normal price เป็น double
  double get normalPriceValue =>
      double.tryParse(_data.normalPrice ?? '0') ?? 0.0;

  /// แปลง saved เป็น double
  double get savedValue => double.tryParse(_data.saved ?? '0') ?? 0.0;

  /// แปลง quantity per package เป็น int
  int get quantity => int.tryParse(_data.quantityPerPackage ?? '0') ?? 0;

  /// คำนวณเปอร์เซ็นต์ส่วนลด
  double get discountPercentage {
    if (normalPriceValue <= 0) return 0.0;
    return ((normalPriceValue - priceValue) / normalPriceValue) * 100;
  }

  /// ตรวจสอบว่ามีส่วนลดหรือไม่
  bool get hasDiscount => savedValue > 0 || discountPercentage > 0;

  /// แปลง start date เป็น DateTime
  DateTime? get startDate {
    if (_data.startDate == null || _data.startDate!.isEmpty) return null;
    try {
      return DateTime.parse(_data.startDate!);
    } catch (e) {
      return null;
    }
  }

  /// แปลง end date เป็น DateTime
  DateTime? get endDate {
    if (_data.endDate == null || _data.endDate!.isEmpty) return null;
    try {
      return DateTime.parse(_data.endDate!);
    } catch (e) {
      return null;
    }
  }

  /// ตรวจสอบว่าแพ็คเกจยังใช้งานได้หรือไม่
  bool get isActive {
    final now = DateTime.now();
    final start = startDate;
    final end = endDate;

    if (start != null && now.isBefore(start)) return false;
    if (end != null && now.isAfter(end)) return false;

    return true;
  }

  /// ตรวจสอบว่าจะหมดอายุเร็วๆนี้ (ภายใน 7 วัน)
  bool get isExpiringSoon {
    final end = endDate;
    if (end == null) return false;
    final now = DateTime.now();
    final difference = end.difference(now);
    return difference.inDays <= 7 && difference.inDays >= 0;
  }

  /// คำนวณจำนวนวันที่เหลือก่อนหมดอายุ
  int? get daysRemaining {
    final end = endDate;
    if (end == null) return null;
    final now = DateTime.now();
    final difference = end.difference(now);
    return difference.inDays >= 0 ? difference.inDays : 0;
  }
}
