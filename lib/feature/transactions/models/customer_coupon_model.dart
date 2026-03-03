import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coupon_data_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
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
    super.remainWasher,
    super.remainDryer,
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
      remainWasher: data.remainWasher,
      remainDryer: data.remainDryer,
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
    String? remainWasher,
    String? remainDryer,
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
      remainWasher: remainWasher ?? this.remainWasher,
      remainDryer: remainDryer ?? this.remainDryer,
      totalUses: totalUses ?? this.totalUses,
      redemptionLimit: redemptionLimit ?? this.redemptionLimit,
      redeemPrice: redeemPrice ?? this.redeemPrice,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      appliesTo: appliesTo ?? this.appliesTo,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// ดึง localized package name ตาม locale ปัจจุบัน
  String nameDisplay(BuildContext context) {
    final locale = context.languageCode;
    return name?.getByLocaleCode(locale) ?? '';
  }

  /// ดึง localized package name ตาม locale ปัจจุบัน
  String packageNameDisplay(BuildContext context) {
    final locale = context.languageCode;
    return packageName?.getByLocaleCode(locale) ?? '';
  }

  /// ดึง localized usage label ตาม locale ปัจจุบัน
  String usageLabelDisplay(BuildContext context) {
    final locale = context.languageCode;
    return usageLabel?.getByLocaleCode(locale) ?? '';
  }

  /// ดึง localized store name ตาม locale ปัจจุบัน
  String storeNameDisplay(BuildContext context) {
    final locale = context.languageCode;
    return store?.name?.getByLocaleCode(locale) ?? '';
  }

  /// ดึง localized description ตาม locale ปัจจุบัน
  String descriptionDisplay(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return description?.getByLocaleCode(locale) ?? '';
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

  /// แสดงจำนวนการใช้งาน Washer/Dryer
  String get washRemainDisplay {
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
