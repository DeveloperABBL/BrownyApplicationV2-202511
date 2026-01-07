import 'package:browny_applications_new/core/data/cache/biometric_helper.dart';
import 'package:browny_applications_new/core/data/repo/app_repository.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';
import 'package:browny_applications_new/feature/authentication/error/pin_biometric_exception.dart';

/// Mixin สำหรับจัดการข้อมูล PIN และ Biometric
mixin PinBiometricDataSourceMixin {
  /// บันทึก PIN
  /// - Hash + Salt ก่อนบันทึก
  /// - เก็บใน Secure Storage
  Future<RepoResult<bool>> savePin(String pin);

  /// ตรวจสอบ PIN
  /// - Hash PIN ที่กรอกแล้วเทียบกับที่เก็บไว้
  Future<RepoResult<bool>> verifyPin(String pin);

  /// ตรวจสอบว่ามี PIN หรือยัง
  Future<RepoResult<bool>> hasPin();

  /// ลบ PIN
  Future<RepoResult<bool>> clearPin();

  /// เปิดใช้งาน Biometric
  Future<RepoResult<bool>> setBiometricEnabled(bool enabled);

  /// ตรวจสอบว่าเปิดใช้งาน Biometric หรือไม่
  Future<RepoResult<bool>> isBiometricEnabled();

  /// ลบการตั้งค่า Biometric
  Future<RepoResult<bool>> clearBiometric();

  /// ตรวจสอบว่าอุปกรณ์รองรับ Biometric หรือไม่
  Future<RepoResult<bool>> isBiometricAvailable();

  /// ทำการ Authenticate ด้วย Biometric
  Future<RepoResult<BiometricAuthResult>> authenticateWithBiometric({
    String? reason,
  });

  /// ตรวจสอบว่ามี Strong Biometric หรือไม่
  Future<RepoResult<bool>> hasStrongBiometric();
}

/// Repository สำหรับจัดการ PIN และ Biometric
/// - ติดต่อกับ AppLocalStorageSecure
/// - จัดการ Business Logic ของ PIN
/// - รองรับ Biometric ในอนาคต
class PinBioMetricRepository extends AppRepository
    with PinBiometricDataSourceMixin {
  final BiometricHelper _biometricHelper;

  PinBioMetricRepository({
    BiometricHelper? biometricHelper,
  }) : _biometricHelper = biometricHelper ?? BiometricHelper.instance();

  @override
  Future<RepoResult<bool>> savePin(String pin) async {
    try {
      // Validate PIN format
      if (!_isValidPin(pin)) {
        return RepoResult.error(
          error: InvalidPinFormat(),
        );
      }

      await requireSecureStorage.savePin(pin);
      return RepoResult.success(data: true);
    } catch (e) {
      return RepoResult.error(error: Exception(e.toString()));
    }
  }

  @override
  Future<RepoResult<bool>> verifyPin(String pin) async {
    try {
      final isValid = await requireSecureStorage.verifyPin(pin);
      return RepoResult.success(data: isValid);
    } catch (e) {
      return RepoResult.error(error: Exception(e.toString()));
    }
  }

  @override
  Future<RepoResult<bool>> hasPin() async {
    try {
      final hasPinValue = await requireSecureStorage.hasPin();
      return RepoResult.success(data: hasPinValue);
    } catch (e) {
      return RepoResult.error(error: Exception(e.toString()));
    }
  }

  @override
  Future<RepoResult<bool>> clearPin() async {
    try {
      await requireSecureStorage.clearPin();
      return RepoResult.success(data: true);
    } catch (e) {
      return RepoResult.error(error: Exception(e.toString()));
    }
  }

  @override
  Future<RepoResult<bool>> setBiometricEnabled(bool enabled) async {
    try {
      await requireSecureStorage.setBiometricEnabled(enabled);
      return RepoResult.success(data: true);
    } catch (e) {
      return RepoResult.error(error: Exception(e.toString()));
    }
  }

  @override
  Future<RepoResult<bool>> isBiometricEnabled() async {
    try {
      final enabled = await requireSecureStorage.isBiometricEnabled();
      return RepoResult.success(data: enabled);
    } catch (e) {
      return RepoResult.error(error: Exception(e.toString()));
    }
  }

  @override
  Future<RepoResult<bool>> clearBiometric() async {
    try {
      await requireSecureStorage.clearBiometric();
      return RepoResult.success(data: true);
    } catch (e) {
      return RepoResult.error(error: Exception(e.toString()));
    }
  }

  @override
  Future<RepoResult<bool>> isBiometricAvailable() async {
    try {
      final isAvailable = await _biometricHelper.isBiometricAvailable();
      return RepoResult.success(data: isAvailable);
    } catch (e) {
      return RepoResult.error(error: Exception(e.toString()));
    }
  }

  @override
  Future<RepoResult<BiometricAuthResult>> authenticateWithBiometric({
    String? reason,
  }) async {
    try {
      // ตรวจสอบว่าเปิดใช้งาน Biometric หรือไม่
      final enabledResult = await isBiometricEnabled();
      if (!enabledResult.isSuccess || enabledResult.data != true) {
        return RepoResult.error(
          error: BiometricNotEnabled(),
        );
      }

      // ตรวจสอบว่ามี PIN หรือไม่ (ต้องมี PIN ก่อนถึงจะใช้ Biometric ได้)
      final hasPinResult = await hasPin();
      if (!hasPinResult.isSuccess || hasPinResult.data != true) {
        return RepoResult.error(
          error: BiometricRequiresPin(),
        );
      }

      // ทำการ Authenticate
      final result = await _biometricHelper.authenticateWithBiometric(
        localizedReason: reason ?? 'กรุณายืนยันตัวตนเพื่อเข้าใช้งาน',
      );

      if (!result.isSuccess) {
        if (result.exception is BiometricAuthFailed) {
          RepoResult.empty(error: result.exception);
        }
      }

      return RepoResult.success(data: result);
    } catch (e) {
      return RepoResult.error(error: Exception(e.toString()));
    }
  }

  @override
  Future<RepoResult<bool>> hasStrongBiometric() async {
    try {
      final hasStrong = await _biometricHelper.hasStrongBiometric();
      return RepoResult.success(data: hasStrong);
    } catch (e) {
      return RepoResult.error(error: Exception(e.toString()));
    }
  }

  // ========== Private Helper Methods ==========

  /// Validate PIN format
  /// - ต้องเป็นตัวเลข 6 หลัก
  bool _isValidPin(String pin) {
    final regex = RegExp(r'^\d{6}$');
    return regex.hasMatch(pin);
  }
}
