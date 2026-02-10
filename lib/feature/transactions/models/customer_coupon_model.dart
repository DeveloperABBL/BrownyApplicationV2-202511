import 'package:browny_applications_new/core/data/remote/models/response/coupon_data_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:flutter/material.dart';

class CustomerCouponModel extends CouponData {
  CustomerCouponModel({
    required super.couponId,
    required super.assignedQuantity,
    required super.usedQuantity,
    required super.remaining,
    required super.expiresAt,
    required super.isExpired,
    required super.isAvailable,
    required super.typeLabel,
    required super.icon,
    required super.name,
    required super.description,
    required super.imageUrl,
    super.totalUses,
    super.redemptionLimit,
    super.redeemPrice,
    super.deliveryFee,
  });

  /// Factory constructor สำหรับแปลง CouponData เป็น EVoucherModel
  factory CustomerCouponModel.fromCouponData(CouponData data) {
    return CustomerCouponModel(
      couponId: data.couponId,
      assignedQuantity: data.assignedQuantity,
      usedQuantity: data.usedQuantity,
      remaining: data.remaining,
      expiresAt: data.expiresAt,
      isExpired: data.isExpired,
      isAvailable: data.isAvailable,
      typeLabel: data.typeLabel,
      icon: data.icon,
      name: data.name,
      description: data.description,
      imageUrl: data.imageUrl,
      totalUses: data.totalUses,
      redemptionLimit: data.redemptionLimit,
      redeemPrice: data.redeemPrice,
      deliveryFee: data.deliveryFee,
    );
  }

  /// ดึง localized name ตาม locale ปัจจุบัน
  String nameDisplay(BuildContext context) {
    final locale = context.languageCode;
    return name?.getByLocaleCode(locale) ?? '';
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
}
