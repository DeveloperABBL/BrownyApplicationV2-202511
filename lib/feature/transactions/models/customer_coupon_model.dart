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
  });

  /// Factory constructor สำหรับแปลง CouponData เป็น CustomerCouponModel
  factory CustomerCouponModel.fromCouponData(CouponData data) {
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
    );
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

  /// ดึง localized image URL ตาม locale ปัจจุบัน
  String imageUrlDisplay(BuildContext context) {
    final locale = context.languageCode;
    return imageUrl?.getByLocaleCode(locale) ?? '';
  }

  /// ดึง localized type label ตาม locale ปัจจุบัน
  String typeLabelDisplay(BuildContext context) {
    final locale = context.languageCode;
    return typeLabel?.getByLocaleCode(locale) ?? '';
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
