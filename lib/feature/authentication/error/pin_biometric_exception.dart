import 'package:flutter/widgets.dart';

// ========== PIN Exceptions ==========

sealed class PinExceptions implements Exception {
  final String? message;

  PinExceptions([this.message]);

  String toUiMessage(BuildContext context) {
    return message ?? 'เกิดข้อผิดพลาด';
  }
}

/// PIN format ไม่ถูกต้อง (ต้องเป็นตัวเลข 6 หลัก)
class InvalidPinFormat extends PinExceptions {
  InvalidPinFormat([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    // TODO: Add to localization file
    return 'PIN ต้องเป็นตัวเลข 6 หลัก';
    // return context.wording.invalidPinFormat;
  }
}

/// PIN ไม่ตรงกัน (create vs confirm)
class PinMismatch extends PinExceptions {
  PinMismatch([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    // TODO: Add to localization file
    return 'PIN ไม่ตรงกัน กรุณาลองใหม่';
    // return context.wording.pinMismatch;
  }
}

/// PIN ไม่ถูกต้อง (verify failed)
class InvalidPin extends PinExceptions {
  InvalidPin([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    // TODO: Add to localization file
    return 'PIN ไม่ถูกต้อง';
    // return context.wording.invalidPin;
  }
}

/// ยังไม่มี PIN ตั้งไว้
class PinNotSet extends PinExceptions {
  PinNotSet([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    // TODO: Add to localization file
    return 'กรุณาตั้ง PIN ก่อนใช้งาน';
    // return context.wording.pinNotSet;
  }
}

/// Validation error จาก server (HTTP 422)
class ValidationPinError extends PinExceptions {
  ValidationPinError([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    return message ?? 'ข้อมูล PIN ไม่ถูกต้อง';
  }
}

// ========== Biometric Exceptions ==========

sealed class BiometricExceptions implements Exception {
  final String? message;

  BiometricExceptions([this.message]);

  String toUiMessage(BuildContext context) {
    return message ?? 'เกิดข้อผิดพลาด';
  }
}

/// อุปกรณ์ไม่รองรับ Biometric
class BiometricNotAvailable extends BiometricExceptions {
  BiometricNotAvailable([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    // TODO: Add to localization file
    return 'อุปกรณ์ไม่รองรับ Biometric';
    // return context.wording.biometricNotAvailable;
  }
}

/// ไม่มี Biometric ที่ลงทะเบียนไว้
class BiometricNotEnrolled extends BiometricExceptions {
  BiometricNotEnrolled([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    // TODO: Add to localization file
    return 'ไม่มี Biometric ที่ลงทะเบียนไว้\nกรุณาตั้งค่าในเครื่อง';
    // return context.wording.biometricNotEnrolled;
  }
}

/// ผู้ใช้ยกเลิกการยืนยันตัวตน
class BiometricUserCanceled extends BiometricExceptions {
  BiometricUserCanceled([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    // TODO: Add to localization file
    return 'คุณยกเลิกการยืนยันตัวตน';
    // return context.wording.biometricUserCanceled;
  }
}

/// ล้มเหลวหลายครั้งเกินไป (locked out)
class BiometricLockedOut extends BiometricExceptions {
  BiometricLockedOut([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    // TODO: Add to localization file
    return 'ลองผิดหลายครั้งเกินไป\nกรุณารอสักครู่หรือใช้ PIN';
    // return context.wording.biometricLockedOut;
  }
}

/// ถูกล็อกถาวร (permanently locked out)
class BiometricPermanentlyLockedOut extends BiometricExceptions {
  BiometricPermanentlyLockedOut([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    // TODO: Add to localization file
    return 'Biometric ถูกล็อกถาวร\nกรุณาใช้ PIN';
    // return context.wording.biometricPermanentlyLockedOut;
  }
}

/// การยืนยันตัวตนล้มเหลว
class BiometricAuthFailed extends BiometricExceptions {
  BiometricAuthFailed([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    // TODO: Add to localization file
    return 'การยืนยันตัวตนล้มเหลว';
    // return context.wording.biometricAuthFailed;
  }
}

/// Biometric ยังไม่ได้เปิดใช้งาน
class BiometricNotEnabled extends BiometricExceptions {
  BiometricNotEnabled([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    // TODO: Add to localization file
    return 'กรุณาเปิดใช้งาน Biometric ก่อน';
    // return context.wording.biometricNotEnabled;
  }
}

/// ต้องตั้ง PIN ก่อนถึงจะใช้ Biometric ได้
class BiometricRequiresPin extends BiometricExceptions {
  BiometricRequiresPin([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    // TODO: Add to localization file
    return 'กรุณาตั้ง PIN ก่อนใช้ Biometric';
    // return context.wording.biometricRequiresPin;
  }
}
