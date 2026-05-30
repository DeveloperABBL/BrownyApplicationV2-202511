import 'package:browny_applications_new/core/const/app_constants.dart';
import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coupon_data_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/res/strings/app_strings.dart';
import 'package:flutter/material.dart';

class CustomerCouponModel extends CouponData {
  CustomerCouponModel({
    required super.couponId,
    super.customerCouponId,
    required super.assignedQuantity,
    required super.usedQuantity,
    required super.remaining,
    required super.expiresAt,
    required super.isExpired,
    required super.isAvailable,
    required super.typeLabel,
    super.usageLabel,
    required super.icon,
    super.name,
    required super.packageName,
    required super.description,
    required super.imageUrl,
    super.store,
    super.qtyWasher,
    super.qtyDryer,
    super.qtyTotal,
    super.qtyShared,
    super.remainWasher,
    super.remainDryer,
    super.remainTotal,
    super.remainShared,
    super.usageMode,
    super.totalUses,
    super.redemptionLimit,
    super.redeemPrice,
    super.deliveryFee,
    super.appliesTo,
    this.isSelected = false,
  });

  final bool isSelected;

  /// Factory constructor สำหรับแปลง CouponData เป็น CustomerCouponModel
  factory CustomerCouponModel.fromCouponData(
    CouponData data, [
    bool isSelected = false,
  ]) {
    return CustomerCouponModel(
      couponId: data.couponId,
      customerCouponId: data.customerCouponId,
      assignedQuantity: data.assignedQuantity,
      usedQuantity: data.usedQuantity,
      remaining: data.remaining,
      expiresAt: data.expiresAt,
      isExpired: data.isExpired,
      isAvailable: data.isAvailable,
      typeLabel: data.typeLabel,
      usageLabel: data.usageLabel,
      icon: data.icon,
      name: data.name,
      packageName: data.packageName,
      description: data.description,
      imageUrl: data.imageUrl,
      store: data.store,
      qtyWasher: data.qtyWasher,
      qtyDryer: data.qtyDryer,
      qtyTotal: data.qtyTotal,
      qtyShared: data.qtyShared,
      remainWasher: data.remainWasher,
      remainDryer: data.remainDryer,
      remainTotal: data.remainTotal,
      remainShared: data.remainShared,
      usageMode: data.usageMode,
      totalUses: data.totalUses,
      redemptionLimit: data.redemptionLimit,
      redeemPrice: data.redeemPrice,
      deliveryFee: data.deliveryFee,
      appliesTo: data.appliesTo,
      isSelected: isSelected,
    );
  }

  CustomerCouponModel copyWith({
    int? couponId,
    int? customerCouponId,
    String? assignedQuantity,
    String? usedQuantity,
    String? remaining,
    String? expiresAt,
    bool? isExpired,
    bool? isAvailable,
    ContentLocalizeData? typeLabel,
    ContentLocalizeData? usageLabel,
    String? icon,
    ContentLocalizeData? name,
    ContentLocalizeData? packageName,
    ContentLocalizeData? description,
    ContentLocalizeData? imageUrl,
    CouponStoreData? store,
    String? qtyWasher,
    String? qtyDryer,
    String? qtyTotal,
    String? qtyShared,
    String? remainWasher,
    String? remainDryer,
    String? remainTotal,
    String? remainShared,
    String? usageMode,
    String? totalUses,
    String? redemptionLimit,
    String? redeemPrice,
    String? deliveryFee,
    String? appliesTo,
    bool? isSelected,
  }) {
    return CustomerCouponModel(
      couponId: couponId ?? this.couponId,
      customerCouponId: customerCouponId ?? this.customerCouponId,
      assignedQuantity: assignedQuantity ?? this.assignedQuantity,
      usedQuantity: usedQuantity ?? this.usedQuantity,
      remaining: remaining ?? this.remaining,
      expiresAt: expiresAt ?? this.expiresAt,
      isExpired: isExpired ?? this.isExpired,
      isAvailable: isAvailable ?? this.isAvailable,
      typeLabel: typeLabel ?? this.typeLabel,
      usageLabel: usageLabel ?? this.usageLabel,
      icon: icon ?? this.icon,
      name: name ?? this.name,
      packageName: packageName ?? this.packageName,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      store: store ?? this.store,
      qtyWasher: qtyWasher ?? this.qtyWasher,
      qtyDryer: qtyDryer ?? this.qtyDryer,
      qtyTotal: qtyTotal ?? this.qtyTotal,
      qtyShared: qtyShared ?? this.qtyShared,
      remainWasher: remainWasher ?? this.remainWasher,
      remainDryer: remainDryer ?? this.remainDryer,
      remainTotal: remainTotal ?? this.remainTotal,
      remainShared: remainShared ?? this.remainShared,
      usageMode: usageMode ?? this.usageMode,
      totalUses: totalUses ?? this.totalUses,
      redemptionLimit: redemptionLimit ?? this.redemptionLimit,
      redeemPrice: redeemPrice ?? this.redeemPrice,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      appliesTo: appliesTo ?? this.appliesTo,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// ใช้สำหรับปั้น wording แสดงที่ AppBar หน้า [CouponVoucherSelected]
  String getSelectedTitleDisplay(BuildContext context) {
    final typeText = typeLabel?.en ?? '';
    final locales = context.languageCode;
    if (typeText == 'E-Voucher') {
      return context.wording.eVoucherDetails;
    }

    context.wording.details;

    if (typeText == 'Discount') {
      if (appliesTo.orEmpty.toLowerCase() == 'both') {
        if (locales == 'en' || locales == 'zh') {
          return '${context.wording.washerDryerCoupon} ${context.wording.details}';
        }
        return '${context.wording.details} ${context.wording.washerDryerCoupon}';
      }
      if (appliesTo.orEmpty.toLowerCase() == 'dryer') {
        if (locales == 'en' || locales == 'zh') {
          return '${context.wording.dryerCoupon} ${context.wording.details}';
        }
        return '${context.wording.details} ${context.wording.dryerCoupon}';
      }
      if (appliesTo.orEmpty.toLowerCase() == 'washer') {
        if (locales == 'en' || locales == 'zh') {
          return '${context.wording.washerCoupon} ${context.wording.details}';
        }
        return '${context.wording.details} ${context.wording.washerCoupon}';
      }
    }
    return typeLabelDisplay(context);
  }

  String getSelectedTypeDisplay(BuildContext context) {
    final typeText = typeLabel?.en ?? '';
    final locales = context.languageCode;
    if (typeText == 'E-Voucher') {
      return context.wording.eVoucherDetails;
    }

    context.wording.details;

    if (typeText == 'Discount') {
      if (appliesTo.orEmpty.toLowerCase() == 'both') {
        if (locales == 'en' || locales == 'zh') {
          return context.wording.washerDryerCoupon;
        }
        return context.wording.washerDryerCoupon;
      }
      if (appliesTo.orEmpty.toLowerCase() == 'dryer') {
        if (locales == 'en' || locales == 'zh') {
          return context.wording.details;
        }
        return context.wording.dryerCoupon;
      }
      if (appliesTo.orEmpty.toLowerCase() == 'washer') {
        if (locales == 'en' || locales == 'zh') {
          return context.wording.washerCoupon;
        }
        return context.wording.washerCoupon;
      }
    }
    return typeLabelDisplay(context);
  }

  String getSelectedTypeNoDetailWordingDisplay(BuildContext context) {
    final typeText = typeLabel?.en ?? '';
    final locales = context.languageCode;
    if (typeText == 'E-Voucher') {
      return 'E-Voucher';
    }

    context.wording.details;

    if (typeText == 'Discount') {
      if (appliesTo.orEmpty.toLowerCase() == 'both') {
        if (locales == 'en' || locales == 'zh') {
          return context.wording.washerDryerCoupon;
        }
        return context.wording.washerDryerCoupon;
      }
      if (appliesTo.orEmpty.toLowerCase() == 'dryer') {
        return context.wording.dryerCoupon;
      }
      if (appliesTo.orEmpty.toLowerCase() == 'washer') {
        return context.wording.washerCoupon;
      }
    }
    return typeLabelDisplay(context);
  }

  /// ดึง localized package name ตาม locale ปัจจุบัน
  String nameDisplay(BuildContext context) {
    final locale = context.languageCode;
    return name?.getByLocaleCode(locale) ?? '';
  }

  /// ดึง localized package name ตาม locale ปัจจุบัน
  String packageNameDisplay(BuildContext context) {
    final locale = context.languageCode;
    return packageName?.getByLocaleCode(locale) ?? nameDisplay(context);
  }

  /// ดึง localized usage label ตาม locale ปัจจุบัน
  String usageLabelDisplay(BuildContext context) {
    final locale = context.languageCode;
    return usageLabel?.getByLocaleCode(locale) ?? '';
  }

  /// ดึง localized usage label ตาม locale ปัจจุบัน
  String brownyUsageLabelDisplay(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return description?.getByLocaleCode(locale) ?? '';
  }

  /// ดึง localized store name ตาม locale ปัจจุบัน
  String storeNameDisplay(BuildContext context) {
    final locale = context.languageCode;
    return store?.name?.getByLocaleCode(locale) ??
        context.wording.participatingStoresOnly;
  }

  /// ดึง localized description ตาม locale ปัจจุบัน
  String descriptionDisplay(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return description?.getByLocaleCode(locale) ?? '';
  }

  /// ดึง localized description ตาม locale ปัจจุบัน
  String brownyDescriptionDisplay(BuildContext context) {
    return context.wording.onlyParticipatingItems;
  }

  /// ดึง localized description
  String couponDescriptionNonHTMLDisplay(BuildContext context) {
    final locale = context.languageCode;
    String content = description?.getByLocaleCode(locale) ?? '';
    return content
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  /// ดึง localized image URL ตาม locale ปัจจุบัน
  String imageUrlDisplay(BuildContext context) {
    final locale = context.languageCode;
    return imageUrl?.getByLocaleCode(locale) ?? '';
  }

  /// ดึง localized type label ตาม locale ปัจจุบัน
  /// [mineText] - คำว่า "ของฉัน/Mine/我的" ที่ localized แล้ว จะถูกเพิ่มตาวโครงสร้างภาษา
  String typeLabelDisplay(BuildContext context, {String? mineText}) {
    final locale = context.languageCode;
    final typeText = typeLabel?.getByLocaleCode(locale) ?? '';

    if (mineText == null || mineText.isEmpty || typeText.isEmpty) {
      return typeText;
    }

    // จัดการตำแหน่งของ "mine" ตามโครงสร้างภาษา
    switch (locale) {
      case 'en':
        // ภาษาอังกฤษ: "My" + type (prefix with space)
        return '$mineText ${typeLabel!.en.orEmpty}';
      case 'zh':
        // ภาษาจีน: "我的" + type (prefix without space)
        return '$mineText${typeLabel!.en.orEmpty}';
      default:
        // ภาษาไทย: type + "ของฉัน" (postfix with space)
        return '${typeLabel!.en.orEmpty} $mineText';
    }
  }

  String detailUsingDisplay(BuildContext context) {
    final locale = context.languageCode;
    switch (locale) {
      case 'en':
        return 'Remaining $remainingCount/$assignedCount';
      case 'zh':
        return '其余的 $remainingCount/$assignedCount';
      default:
        return 'จำนวนที่เหลือ $remainingCount/$assignedCount';
    }
  }

  String expireDateDisplay(BuildContext context) {
    final locale = context.languageCode;
    if (expiryDate != null) {
      int dif = (DateTime.now().difference(expiryDate!).inDays * -1);
      switch (locale) {
        case 'en':
          return '$dif days left';
        case 'zh':
          return '剩余 $dif 天';
        default:
          return 'เหลือ $dif วัน';
      }
    } else {
      return '';
    }
  }

  /// แสดงวันหมดอายุคูปอง Browny Shop — เช่น "คูปองหมดอายุ 26 มิ.ย. 2026"
  /// (ต่างจาก [expireDateDisplay] ที่แสดงเป็น "เหลือ N วัน")
  String expiresAtBrownyShopDisplay(BuildContext context) {
    final locale = context.languageCode;
    final date = expiryDate;
    if (date == null) return '';
    return '${context.wording.couponExpiresLabel} '
        '${date.formatDateLocale(locale, pattern: 'dd MMM yyyy')}';
  }

  // ========== Browny Shop coupon (discount target/condition) ==========

  /// ยอดสั่งซื้อขั้นต่ำที่ใช้คูปองได้ (แปลงจาก string)
  num get minOrderAmountValue => double.tryParse(minOrderAmount ?? '0') ?? 0;

  /// มูลค่าส่วนลด (fixed = บาท, percent = เปอร์เซ็นต์)
  num get couponValue => double.tryParse(value ?? '0') ?? 0;

  /// เพดานส่วนลด (เฉพาะ percent) — null = ไม่จำกัด
  num? get maxDiscountValue => (maxDiscount == null || maxDiscount!.isEmpty)
      ? null
      : double.tryParse(maxDiscount!);

  bool get isPercentDiscount => discountType?.toLowerCase() == 'percent';
  bool get isFixedDiscount => discountType?.toLowerCase() == 'fixed';

  /// คำนวณส่วนลดที่คูปองนี้ให้ เทียบกับยอด [orderAmount]
  /// (percent คิด % แล้ว cap ด้วย max_discount, fixed คืนค่าคงที่ —
  /// ทั้งคู่ไม่เกินยอดสั่งซื้อ)
  num computeBrownyShopDiscount(num orderAmount) {
    if (orderAmount <= 0) return 0;
    if (isPercentDiscount) {
      final raw = orderAmount * couponValue / 100;
      final cap = maxDiscountValue;
      final discount = (cap != null && raw > cap) ? cap : raw;
      return discount > orderAmount ? orderAmount : discount;
    }
    // fixed (และ type อื่นที่เป็นจำนวนเงินคงที่)
    return couponValue > orderAmount ? orderAmount : couponValue;
  }

  /// ตรวจเงื่อนไขคูปอง Browny Shop แบบไม่ผูก context (ใช้ใน ViewModel)
  /// — true = ใช้ได้กับยอด/สถานะที่ส่งเข้ามา
  bool isUsableForBrownyShop({
    required num orderAmount,
    bool hasFlashSale = false,
    bool hasProductDiscount = false,
  }) {
    if (remainingCount <= 0) return false;
    if (orderAmount < minOrderAmountValue) return false;
    if (hasFlashSale && allowWithPromotion == false) return false;
    if (hasProductDiscount && allowWithProductDiscount == false) return false;
    return true;
  }

  /// ตรวจเงื่อนไขคูปอง Browny Shop กับยอด/สถานะสินค้าปัจจุบัน
  /// คืน error message (localized) ถ้าใช้ไม่ได้, null = ใช้ได้
  ///
  /// - [orderAmount]: ยอดที่ใช้เทียบ min_order_amount
  /// - [hasFlashSale]: สินค้ามี Flash Sale (ใช้กับ allow_with_promotion)
  /// - [hasProductDiscount]: สินค้ามีส่วนลด (ใช้กับ allow_with_product_discount)
  String? validBrownyShopCouponMessage(
    BuildContext context, {
    required num orderAmount,
    bool hasFlashSale = false,
    bool hasProductDiscount = false,
  }) {
    
    // สิทธิ์คงเหลือ
    if (remainingCount <= 0) {
      return context.wording.couponFullyRedeemed;
    }
    // ยอดขั้นต่ำ
    if (orderAmount < minOrderAmountValue) {
      return context.wording.couponMinimumAmountRequired(
        formatCurrency(leadingSign: '฿', value: minOrderAmountValue),
      );
    }
    // ใช้ร่วมกับ Flash Sale / โปรโมชั่น
    if (hasFlashSale && allowWithPromotion == false) {
      return context.wording.couponCannotUseWithPromotion;
    }
    // ใช้ร่วมกับส่วนลดสินค้า
    if (hasProductDiscount && allowWithProductDiscount == false) {
      return context.wording.couponCannotUseWithProductDiscount;
    }
    return null;
  }

  String dateLeftDisplay(BuildContext context) {
    final locale = context.languageCode;
    if (expiryDate != null) {
      int dif = (DateTime.now().difference(expiryDate!).inDays * -1);
      switch (locale) {
        case 'en':
          return '$dif days';
        case 'zh':
          return '$dif 天';
        default:
          return '$dif วัน';
      }
    } else {
      return '';
    }
  }

  /// ตัวช่วยตรวจสอบว่าคูปองใช้ได้หรือไม่
  bool get canUse => (isAvailable ?? false) && !(isExpired ?? true);

  bool get brownyCanUse => remainingCount > 0;

  /// แปลง remaining เป็น int สำหรับแสดงผล
  int get remainingCount => int.tryParse(remaining ?? '0') ?? 0;

  /// แปลง assignedQuantity เป็น int
  int get assignedCount => int.tryParse(assignedQuantity ?? '0') ?? 0;

  /// แปลง usedQuantity เป็น int
  int get usedCount => int.tryParse(usedQuantity ?? '0') ?? 0;

  /// สร้าง DateTime object จาก expiresAt string
  DateTime? get expiryDate {
    if (expiresAt == null || expiresAt!.isEmpty) return null;
    try {
      return DateTime.parse(expiresAt!);
    } catch (e) {
      return null;
    }
  }

  /// ตรวจสอบว่าจะหมดอายุเร็วๆนี้ (ภายใน 7 วัน)
  bool get isExpiringSoon {
    final expiry = expiryDate;
    if (expiry == null) return false;
    final now = DateTime.now();
    final difference = expiry.difference(now);
    return difference.inDays <= 7 && difference.inDays >= 0;
  }

  /// จำนวนเครื่องซักที่มี
  int get qtyWasherCount => int.tryParse(qtyWasher ?? '0') ?? 0;

  /// จำนวนเครื่องอบที่มี
  int get qtyDryerCount => int.tryParse(qtyDryer ?? '0') ?? 0;

  /// จำนวนเครื่องซักที่เหลือ
  int get remainWasherCount => int.tryParse(remainWasher ?? '0') ?? 0;

  /// จำนวนเครื่องอบที่เหลือ
  int get remainDryerCount => int.tryParse(remainDryer ?? '0') ?? 0;

  /// จำนวนรวมทั้งหมด (washer + dryer)
  int get qtyTotalCount => int.tryParse(qtyTotal ?? '0') ?? 0;

  /// จำนวนที่แชร์ออกไป
  int get qtySharedCount => int.tryParse(qtyShared ?? '0') ?? 0;

  /// จำนวนรวมที่เหลือ
  int get remainTotalCount => int.tryParse(remainTotal ?? '0') ?? 0;

  /// จำนวนที่แชร์ที่เหลือ
  int get remainSharedCount => int.tryParse(remainShared ?? '0') ?? 0;

  /// ตรวจสอบว่าเป็น split mode (แยกซัก/อบ) หรือไม่
  bool get isSplitMode => usageMode == 'split';

  /// แสดงจำนวนการใช้งาน Washer/Dryer
  String washDryDisplay(BuildContext context) {
    final locale = context.languageCode;
    final washer = qtyWasherCount;
    final dryer = qtyDryerCount;

    switch (locale) {
      case 'en':
        return 'Wash $washer / Dry $dryer times';
      case 'zh':
        return '洗 $washer / 烘干 $dryer 次';
      default:
        return 'ซัก $washer / อบ $dryer ครั้ง';
    }
  }

  String sharedOrApplieBothWordingDisplay(BuildContext context) {
    final typeText = typeLabel?.en ?? '';
    if (typeText == 'E-Voucher' || appliesTo.orEmpty == 'both') {
      return context.wording.washAndDryTimesLabel(
        washRemainDisplay,
      );
    }

    if (appliesTo.orEmpty == 'washer') {
      return context.wording.washTimesLabel(
        washRemainDisplay,
      );
    }

    return context.wording.dryTimesLabel(
      washRemainDisplay,
    );
  }

  /// แสดงจำนวนการใช้งาน Washer/Dryer
  String get washRemainDisplay {
    if (!isSplitMode) {
      return remainSharedCount > 0
          ? '$remainSharedCount'
          : remaining.ifNullOrEmpty('0');
    }
    final washer = qtyWasherCount;
    final remain = remainWasher;

    return '$washer / $remain';
  }

  /// แสดงจำนวนการใช้งาน Washer/Dryer
  String get dryRemainDisplay {
    final dryer = qtyDryerCount;
    final remain = remainDryer;

    return '$dryer / $remain';
  }

  /// แสดงจำนวนที่เหลือของ Washer/Dryer
  String remainWashDryDisplay(BuildContext context) {
    final locale = context.languageCode;
    final washer = remainWasherCount;
    final dryer = remainDryerCount;

    switch (locale) {
      case 'en':
        return 'Remaining: Wash $washer / Dry $dryer';
      case 'zh':
        return '剩余：洗 $washer / 烘干 $dryer';
      default:
        return 'เหลือ: ซัก $washer / อบ $dryer';
    }
  }
}
