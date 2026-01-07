import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Mixin สำหรับจัดการ Secure Storage
/// - ใช้สำหรับข้อมูลที่ sensitive (PIN, Token, Password)
/// - เก็บข้อมูลใน Keychain (iOS) / Keystore (Android)
/// - รองรับ Hardware-backed encryption
mixin AppLocalSecureStoreMixin {
  /// อ่านค่าจาก Secure Storage
  /// - คืนค่าเป็น String (decrypt แล้ว)
  /// - ถ้าไม่มี key → คืนค่า defaultValue
  Future<String?> readSecure({
    required String key,
    String? defaultValue,
  });

  /// เขียนค่าลง Secure Storage
  /// - เข้ารหัสอัตโนมัติก่อนบันทึก
  Future<void> writeSecure({
    required String key,
    required String value,
  });

  /// ลบค่าจาก Secure Storage ตาม key
  Future<void> deleteSecure(String key);

  /// ลบข้อมูลทั้งหมดใน Secure Storage
  Future<void> deleteAllSecure();

  /// ตรวจสอบว่ามี key นี้หรือไม่
  Future<bool> containsKeySecure(String key);
}

/// Singleton class สำหรับจัดการ Secure Storage
/// - ใช้ flutter_secure_storage
/// - เก็บข้อมูล sensitive (PIN, Token, Biometric settings)
/// - Thread-safe และ singleton pattern
class AppLocalSecureStorage with AppLocalSecureStoreMixin {
  AppLocalSecureStorage._();
  static final _instance = AppLocalSecureStorage._();

  factory AppLocalSecureStorage.instance() => _instance;

  /// FlutterSecureStorage instance
  /// - Android: ใช้ EncryptedSharedPreferences
  /// - iOS: ใช้ Keychain
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// อ่านค่าจาก Secure Storage
  @override
  Future<String?> readSecure({
    required String key,
    String? defaultValue,
  }) async {
    try {
      final value = await _storage.read(key: key);
      return value ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// เขียนค่าลง Secure Storage
  @override
  Future<void> writeSecure({
    required String key,
    required String value,
  }) async {
    await _storage.write(key: key, value: value);
  }

  /// ลบค่าจาก Secure Storage
  @override
  Future<void> deleteSecure(String key) async {
    await _storage.delete(key: key);
  }

  /// ลบข้อมูลทั้งหมด
  @override
  Future<void> deleteAllSecure() async {
    await _storage.deleteAll();
  }

  /// ตรวจสอบว่ามี key นี้หรือไม่
  @override
  Future<bool> containsKeySecure(String key) async {
    return await _storage.containsKey(key: key);
  }

  // ========== Helper Methods สำหรับ PIN ==========

  /// บันทึก PIN (Hashed + Salt)
  /// - ไม่เก็บ PIN จริง เก็บเฉพาะ Hash
  /// - ใช้ SHA-256 + Salt
  Future<void> savePin(String pin) async {
    // สร้าง Salt ใหม่ทุกครั้งที่ตั้ง PIN (หรือ reuse ถ้ามีอยู่แล้ว)
    String salt = await readSecure(key: _pinSaltKey) ?? _generateSalt();
    String hashedPin = _hashPin(pin, salt);

    await writeSecure(key: _pinHashKey, value: hashedPin);
    await writeSecure(key: _pinSaltKey, value: salt);
  }

  /// ตรวจสอบ PIN
  /// - Hash PIN ที่กรอกด้วย Salt เดียวกัน
  /// - เทียบกับ Hash ที่เก็บไว้
  Future<bool> verifyPin(String pin) async {
    String? storedHash = await readSecure(key: _pinHashKey);
    String? salt = await readSecure(key: _pinSaltKey);

    if (storedHash == null || salt == null) return false;

    String hashedPin = _hashPin(pin, salt);
    return hashedPin == storedHash;
  }

  /// ตรวจสอบว่ามี PIN หรือยัง
  Future<bool> hasPin() async {
    return await containsKeySecure(_pinHashKey);
  }

  /// ลบ PIN
  Future<void> clearPin() async {
    await deleteSecure(_pinHashKey);
    await deleteSecure(_pinSaltKey);
  }

  // ========== Helper Methods สำหรับ Biometric ==========

  /// บันทึกการเปิดใช้งาน Biometric
  Future<void> setBiometricEnabled(bool enabled) async {
    await writeSecure(
      key: _biometricEnabledKey,
      value: enabled.toString(),
    );
  }

  /// ตรวจสอบว่าเปิดใช้งาน Biometric หรือไม่
  Future<bool> isBiometricEnabled() async {
    final value = await readSecure(
      key: _biometricEnabledKey,
      defaultValue: 'false',
    );
    return value == 'true';
  }

  /// ลบการตั้งค่า Biometric
  Future<void> clearBiometric() async {
    await deleteSecure(_biometricEnabledKey);
  }

  // ========== Private Methods ==========

  /// Hash PIN ด้วย SHA-256 + Salt
  String _hashPin(String pin, String salt) {
    var bytes = utf8.encode(pin + salt);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// สร้าง Salt แบบสุ่ม (32 characters)
  String _generateSalt() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return sha256.convert(utf8.encode(random)).toString().substring(0, 32);
  }

  // ========== Storage Keys ==========

  static const String _pinHashKey = 'app_pin_hash';
  static const String _pinSaltKey = 'app_pin_salt';
  static const String _biometricEnabledKey = 'biometric_enabled';
}
