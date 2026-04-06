import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Helper class สำหรับจัดการ Device Identifiers
///
/// ใช้กลยุทธ์ผสมผสานระหว่าง:
/// - Platform identifiers (IDFV/ANDROID_ID)
/// - Custom UUID ที่เก็บใน secure storage
/// - Firebase Installation ID (optional)
class DeviceIdentifierHelper {
  static const _storage = FlutterSecureStorage();
  static const _customIdKey = 'custom_device_uuid';
  static const _uuid = Uuid();

  /// ดึง Device Identifier ที่ปลอดภัยและ persistent ที่สุด
  ///
  /// กลยุทธ์:
  /// 1. ลองใช้ Custom UUID ที่เคยสร้างไว้ (ใน Keychain/KeyStore)
  /// 2. ถ้าไม่มี ให้สร้างใหม่และบันทึก
  /// 3. Fallback ไปใช้ platform identifier
  ///
  /// Returns: Device identifier ที่ไม่ซ้ำและ persistent
  static Future<String> getDeviceIdentifier() async {
    try {
      // 1. ลองอ่าน custom UUID จาก secure storage
      String? customId = await _storage.read(key: _customIdKey);

      if (customId == null || customId.isEmpty) {
        // 2. ถ้าไม่มี ให้สร้าง UUID ใหม่
        customId = _uuid.v4();

        // 3. บันทึกลง secure storage (Keychain/KeyStore)
        await _storage.write(key: _customIdKey, value: customId);
      }

      return customId;
    } catch (e) {
      // Fallback: ใช้ platform identifier
      return await _getPlatformIdentifier();
    }
  }

  /// ดึง Platform-specific identifier (IDFV/ANDROID_ID)
  ///
  /// ⚠️ **ข้อจำกัด**:
  /// - iOS: เปลี่ยนเมื่อลบ apps ทั้งหมดของ vendor
  /// - Android: เปลี่ยนเมื่อ factory reset
  static Future<String> _getPlatformIdentifier() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? _uuid.v4();
    } else {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    }
  }

  /// ดึงข้อมูล Device Model
  static Future<String> getDeviceModel() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      // "iPhone14,3" -> "iPhone 13 Pro"
      return _iosModelName(iosInfo.utsname.machine);
    } else {
      final androidInfo = await deviceInfo.androidInfo;
      // "samsung SM-G991B" -> "Samsung Galaxy S21"
      return '${androidInfo.manufacturer} ${androidInfo.model}'
          .replaceAll('_', ' ')
          .trim();
    }
  }

  /// แปลง iOS machine identifier เป็นชื่อรุ่นที่อ่านง่าย
  static String _iosModelName(String identifier) {
    // Map ของ iOS machine identifiers
    const modelMap = {
      'iPhone14,2': 'iPhone 13 Pro',
      'iPhone14,3': 'iPhone 13 Pro Max',
      'iPhone14,4': 'iPhone 13 mini',
      'iPhone14,5': 'iPhone 13',
      'iPhone15,2': 'iPhone 14 Pro',
      'iPhone15,3': 'iPhone 14 Pro Max',
      'iPhone15,4': 'iPhone 14',
      'iPhone15,5': 'iPhone 14 Plus',
      'iPhone16,1': 'iPhone 15 Pro',
      'iPhone16,2': 'iPhone 15 Pro Max',
      'iPhone16,3': 'iPhone 15',
      'iPhone16,4': 'iPhone 15 Plus',
      // iPad
      'iPad13,1': 'iPad Pro 12.9" (5th gen)',
      'iPad13,2': 'iPad Pro 12.9" (5th gen)',
      'iPad14,1': 'iPad mini (6th gen)',
      'iPad14,2': 'iPad mini (6th gen)',
      // เพิ่มได้ตามต้องการ...
    };

    return modelMap[identifier] ?? identifier;
  }

  /// ดึง Platform name ("IOS" หรือ "ANDROID")
  static String getDevicePlatform() {
    return Platform.isIOS ? 'IOS' : 'ANDROID';
  }

  /// ลบ Custom UUID (ใช้เมื่อ user logout หรือ reset app)
  ///
  /// ⚠️ **คำเตือน**: หลังจากลบแล้ว device จะถูกมองว่าเป็นเครื่องใหม่
  static Future<void> resetDeviceIdentifier() async {
    try {
      await _storage.delete(key: _customIdKey);
    } catch (e) {
      // Ignore errors
    }
  }

  /// ดึง Device Info แบบครบชุด (สำหรับส่ง API)
  static Future<Map<String, String>> getDeviceInfo() async {
    return {
      'device_identity_id': await getDeviceIdentifier(),
      'device_model': await getDeviceModel(),
      'device_platform': getDevicePlatform(),
    };
  }
}
