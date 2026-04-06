import 'package:browny_applications_new/feature/authentication/error/pin_biometric_exception.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Mixin สำหรับ Biometric Authentication operations
mixin BiometricHelperMixin {
  /// ตรวจสอบว่าอุปกรณ์รองรับ Biometric หรือไม่
  Future<bool> canCheckBiometrics();

  /// ตรวจสอบว่ามี Biometric ที่พร้อมใช้งานหรือไม่
  Future<bool> isBiometricAvailable();

  /// ดึงรายการ Biometric types ที่มี
  Future<List<BiometricType>> getAvailableBiometrics();

  /// ทำการ Authenticate ด้วย Biometric
  Future<BiometricAuthResult> authenticateWithBiometric({
    String localizedReason = 'กรุณายืนยันตัวตนเพื่อดำเนินการต่อ',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  });

  /// ตรวจสอบว่ามี Strong Biometric หรือไม่ (เช่น Face ID, Fingerprint)
  /// ไม่รวม Weak Biometric เช่น Smart Lock
  Future<bool> hasStrongBiometric();
}

/// ผลลัพธ์จาก Biometric Authentication
class BiometricAuthResult {
  final bool isSuccess;
  final BiometricExceptions? exception;

  const BiometricAuthResult({
    required this.isSuccess,
    this.exception,
  });

  factory BiometricAuthResult.success() =>
      const BiometricAuthResult(isSuccess: true);

  factory BiometricAuthResult.failure(BiometricExceptions exception) =>
      BiometricAuthResult(
        isSuccess: false,
        exception: exception,
      );
}

/// Helper class สำหรับ Biometric Authentication
/// ใช้ Singleton pattern เพื่อให้มี instance เดียวทั้งแอป
class BiometricHelper with BiometricHelperMixin {
  static BiometricHelper? _instance;
  final LocalAuthentication _localAuth;

  BiometricHelper._({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  /// Singleton instance
  factory BiometricHelper.instance({LocalAuthentication? localAuth}) {
    _instance ??= BiometricHelper._(localAuth: localAuth);
    return _instance!;
  }

  @override
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await canCheckBiometrics();
      if (!canCheck) return false;

      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<BiometricAuthResult> authenticateWithBiometric({
    String localizedReason = 'กรุณายืนยันตัวตนเพื่อดำเนินการต่อ',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      // ตรวจสอบว่ามี Biometric พร้อมใช้งานหรือไม่
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return BiometricAuthResult.failure(
          BiometricNotAvailable(),
        );
      }

      // ทำการ Authenticate
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true, // ใช้เฉพาะ Biometric ไม่รวม PIN/Pattern ของเครื่อง
      );

      if (didAuthenticate) {
        return BiometricAuthResult.success();
      } else {
        return BiometricAuthResult.failure(
          BiometricAuthFailed(),
        );
      }
    } on PlatformException catch (e) {
      // จัดการ Error แบบละเอียด
      return _handlePlatformException(e);
    } catch (e) {
      return BiometricAuthResult.failure(
        BiometricAuthFailed(e.toString()),
      );
    }
  }

  @override
  Future<bool> hasStrongBiometric() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();

      // ตรวจสอบว่ามี Strong Biometric หรือไม่
      // Strong Biometric คือ Face, Fingerprint, Iris
      final strongBiometrics = availableBiometrics.where((type) {
        return type == BiometricType.face ||
            type == BiometricType.fingerprint ||
            type == BiometricType.iris;
      });

      return strongBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// จัดการ PlatformException จาก local_auth
  BiometricAuthResult _handlePlatformException(PlatformException e) {
    BiometricExceptions exception;

    switch (e.code) {
      case 'NotAvailable':
      case 'notAvailable':
        exception = BiometricNotAvailable(e.message);
        break;

      case 'NotEnrolled':
      case 'notEnrolled':
        exception = BiometricNotEnrolled(e.message);
        break;

      case 'LockedOut':
      case 'lockedOut':
        exception = BiometricLockedOut(e.message);
        break;

      case 'PermanentlyLockedOut':
      case 'permanentlyLockedOut':
        exception = BiometricPermanentlyLockedOut(e.message);
        break;

      case 'UserCanceled':
      case 'GestureRejected':
        exception = BiometricUserCanceled(e.message);
        break;

      default:
        exception = BiometricAuthFailed(e.message ?? e.code);
        break;
    }

    return BiometricAuthResult.failure(exception);
  }

  /// ดึงชื่อ Biometric Type ที่เป็นภาษาไทย
  static String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID / Face Recognition';
      case BiometricType.fingerprint:
        return 'Fingerprint / ลายนิ้วมือ';
      case BiometricType.iris:
        return 'Iris / ม่านตา';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric (Smart Lock)';
    }
  }

  /// ดึงคำอธิบายของ Biometric ที่มีในอุปกรณ์
  Future<String> getBiometricDescription() async {
    final biometrics = await getAvailableBiometrics();

    if (biometrics.isEmpty) {
      return 'ไม่มี Biometric ที่ลงทะเบียนไว้';
    }

    final names = biometrics.map((type) => getBiometricTypeName(type)).toList();
    return names.join(', ');
  }
}
