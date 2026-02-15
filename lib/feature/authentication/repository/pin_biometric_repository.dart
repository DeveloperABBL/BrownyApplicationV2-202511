import 'package:browny_applications_new/core/data/cache/biometric_helper.dart';
import 'package:browny_applications_new/core/data/remote/models/request/pin_request.dart';
import 'package:browny_applications_new/core/data/repo/app_repository.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';
import 'package:browny_applications_new/feature/authentication/error/pin_biometric_exception.dart';

/// Mixin สำหรับจัดการข้อมูล PIN และ Biometric
mixin PinBiometricDataSourceMixin {
  /// บันทึก PIN
  /// - Call API setPin และ getPin
  /// - เก็บ Hash + Salt และ Ciphertext ใน Secure Storage
  ///
  /// Parameters:
  /// - pin: PIN ที่ user กรอก
  /// - customerId: ID ของ customer (inject จาก ViewModel)
  Future<RepoResult<bool>> savePin(String pin, {required String customerId});

  /// ตรวจสอบ PIN (Offline)
  /// - Hash PIN ที่กรอกแล้วเทียบกับที่เก็บไว้
  /// - ไม่ต้อง call API
  Future<RepoResult<bool>> verifyPin(String pin);

  /// ตรวจสอบ PIN (Online)
  /// - เรียก API verifyPin เพื่อเช็คกับ server
  /// - ใช้เมื่อต้องการความแม่นยำสูง หรือ offline verify ไม่ผ่าน
  ///
  /// Parameters:
  /// - pin: PIN ที่ user กรอก
  /// - customerId: ID ของ customer (inject จาก ViewModel)
  Future<RepoResult<bool>> verifyPinOnline(
    String pin, {
    required String customerId,
  });

  /// ตรวจสอบว่ามี PIN หรือยัง
  Future<RepoResult<bool>> hasPin();

  /// ดึง Ciphertext ที่เก็บไว้ (สำหรับ use case อื่นๆ)
  Future<RepoResult<String?>> getPinCiphertext();

  /// ดึง Cipher method ที่ใช้
  Future<RepoResult<String?>> getPinCipherMethod();

  /// ดึง PIN จาก Server (API getPin)
  /// - ใช้เมื่อต้องการเช็คว่า server มี PIN หรือไม่
  /// - คืนค่า ciphertext และ cipher method
  ///
  /// Parameters:
  /// - customerId: ID ของ customer (inject จาก ViewModel)
  Future<RepoResult<Map<String, String?>>> getPinFromServer({
    required String customerId,
  });

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
  Future<RepoResult<bool>> savePin(
    String pin, {
    required String customerId,
  }) async {
    try {
      // 1. Validate PIN format
      if (!_isValidPin(pin)) {
        return RepoResult.error(
          error: InvalidPinFormat(),
        );
      }

      // 2. Validate customerId
      if (customerId.isEmpty) {
        return RepoResult.error(
          error: Exception('Customer ID is required'),
        );
      }

      // 3. เรียก API setPin เพื่อเก็บบน Server
      final setPinResponse = await requireRemote.setPin(
        PinRequest(id: customerId, pin: pin),
      );

      // 4. ตรวจสอบ response
      if (!setPinResponse.isSuccessful) {
        return RepoResult.error(
          error: Exception('Failed to set PIN on server'),
        );
      }

      // 4. เรียก API getPin เพื่อดึง encrypted PIN กลับมา
      final getPinResult = await getPinFromServer(customerId: customerId);

      if (!getPinResult.isSuccess) {
        return RepoResult.error(
          error: Exception('Failed to get encrypted PIN from server'),
        );
      }

      // 5. บันทึกลง Secure Storage (Hybrid Security Approach)
      // - เก็บ Hash + Salt สำหรับ offline verify
      // - เก็บ Ciphertext จาก server สำหรับ use case อื่นๆ
      await requireSecureStorage.savePin(
        pin,
        ciphertext: getPinResult.data['ciphertext'],
        cipherMethod: getPinResult.data['cipher'],
      );

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
  Future<RepoResult<bool>> verifyPinOnline(
    String pin, {
    required String customerId,
  }) async {
    try {
      // 1. Validate PIN format
      if (!_isValidPin(pin)) {
        return RepoResult.error(
          error: InvalidPinFormat(),
        );
      }

      // 2. Validate customerId
      if (customerId.isEmpty) {
        return RepoResult.error(
          error: Exception('Customer ID is required'),
        );
      }

      // 3. เรียก API verifyPin
      final response = await requireRemote.verifyPin(
        PinRequest(id: customerId, pin: pin),
      );

      // 4. ตรวจสอบ response ตาม HTTP status code
      if (response.response.isUnprocessable) {
        // HTTP 422: ข้อมูลไม่ถูกต้อง (validation error)
        return RepoResult.error(
          error: ValidationPinError(
            response.data.message ?? 'Invalid PIN format',
          ),
        );
      }

      if (response.response.isUnauthorized) {
        // HTTP 401: PIN ไม่ถูกต้อง
        return RepoResult.success(data: false);
      }

      if (response.isSuccessful && response.data.success == true) {
        // HTTP 200: PIN ถูกต้อง
        return RepoResult.success(data: true);
      }

      // กรณีอื่นๆ ถือว่า error
      return RepoResult.error(
        error: Exception('Unknown error occurred'),
      );
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
  Future<RepoResult<String?>> getPinCiphertext() async {
    try {
      final ciphertext = await requireSecureStorage.getPinCiphertext();
      return RepoResult.success(data: ciphertext);
    } catch (e) {
      return RepoResult.error(error: Exception(e.toString()));
    }
  }

  @override
  Future<RepoResult<String?>> getPinCipherMethod() async {
    try {
      final method = await requireSecureStorage.getPinCipherMethod();
      return RepoResult.success(data: method);
    } catch (e) {
      return RepoResult.error(error: Exception(e.toString()));
    }
  }

  @override
  Future<RepoResult<Map<String, String?>>> getPinFromServer({
    required String customerId,
  }) async {
    try {
      // 1. Validate customerId
      if (customerId.isEmpty) {
        return RepoResult.error(
          error: Exception('Customer ID is required'),
        );
      }

      // 2. เรียก API getPin
      final response = await requireRemote.getPin(customerId);

      // 3. ตรวจสอบ response
      if (!response.isSuccessful) {
        return RepoResult.error(
          error: Exception('Failed to get PIN from server'),
        );
      }

      // 4. คืนค่า ciphertext และ cipher method
      return RepoResult.success(
        data: {
          'ciphertext': response.data.ciphertext,
          'cipher': response.data.cipher,
        },
      );
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
