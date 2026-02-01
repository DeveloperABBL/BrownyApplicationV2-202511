import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as handler;

/// Helper class สำหรับจัดการ Permissions ต่างๆ ในแอป
class PermissionHelper {
  // Private constructor เพื่อป้องกันการสร้าง instance
  PermissionHelper._();

  /// ขอ Permission สำหรับการบันทึกรูปภาพลงในอุปกรณ์
  ///
  /// จัดการแบบ platform-specific:
  /// - iOS: ใช้ Permission.photos
  /// - Android 13+ (API 33+): ใช้ Permission.photos
  /// - Android 12 และต่ำกว่า: ใช้ Permission.storage
  ///
  /// Returns [handler.PermissionStatus] สถานะของ permission ที่ขอ
  static Future<handler.PermissionStatus> requestStoragePermission(
    BuildContext context,
  ) async {
    try {
      handler.PermissionStatus status;

      // ตรวจสอบ Platform
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        // iOS: ใช้ photos permission
        status = await handler.Permission.photos.request();
      } else {
        // Android: แยกตาม API level
        // Android 13+ (API 33+) ใช้ photos permission
        if (await handler.Permission.photos.request().isGranted) {
          status = handler.PermissionStatus.granted;
        } else {
          // Android 12 และต่ำกว่า ใช้ storage permission
          status = await handler.Permission.storage.request();
        }
      }

      return status;
    } catch (e) {
      // ถ้าเกิด error ให้ถือว่า permission ถูกปฏิเสธ
      return handler.PermissionStatus.denied;
    }
  }

  /// ตรวจสอบว่า Storage Permission ได้รับอนุญาตแล้วหรือยัง
  ///
  /// Returns [bool] true ถ้าได้รับอนุญาต (granted หรือ limited)
  static Future<bool> hasStoragePermission(BuildContext context) async {
    try {
      handler.PermissionStatus status;

      if (Theme.of(context).platform == TargetPlatform.iOS) {
        status = await handler.Permission.photos.status;
      } else {
        // ลอง photos ก่อน (Android 13+)
        status = await handler.Permission.photos.status;
        if (!status.isGranted) {
          // ถ้าไม่ได้ ลอง storage (Android 12-)
          status = await handler.Permission.storage.status;
        }
      }

      return status.isGranted || status.isLimited;
    } catch (e) {
      return false;
    }
  }

  /// เปิดหน้าการตั้งค่าแอปของระบบ
  ///
  /// ใช้เมื่อ permission ถูก permanently denied
  /// เพื่อให้ผู้ใช้ไปเปิด permission ในการตั้งค่า
  static Future<bool> openAppSettings() async {
    try {
      final canOpened = await handler.openAppSettings();
      return canOpened;
    } catch (e) {
      return false;
    }
  }

  /// ขอ Permission สำหรับกล้อง
  ///
  /// Returns [PermissionStatus] สถานะของ permission ที่ขอ
  static Future<handler.PermissionStatus> requestCameraPermission() async {
    try {
      final granted = await handler.Permission.camera.request();
      return granted;
    } catch (e) {
      return handler.PermissionStatus.denied;
    }
  }

  /// ตรวจสอบว่า Camera Permission ได้รับอนุญาตแล้วหรือยัง
  static Future<bool> hasCameraPermission() async {
    try {
      final status = await handler.Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// ขอ Permission สำหรับไมโครโฟน
  ///
  /// Returns [PermissionStatus] สถานะของ permission ที่ขอ
  static Future<handler.PermissionStatus> requestMicrophonePermission() async {
    try {
      return await handler.Permission.microphone.request();
    } catch (e) {
      return handler.PermissionStatus.denied;
    }
  }

  /// ตรวจสอบว่า Microphone Permission ได้รับอนุญาตแล้วหรือยัง
  static Future<bool> hasMicrophonePermission() async {
    try {
      final status = await handler.Permission.microphone.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// ขอ Permission สำหรับตำแหน่งที่ตั้ง
  ///
  /// Returns [handler.PermissionStatus] สถานะของ permission ที่ขอ
  static Future<handler.PermissionStatus> requestLocationPermission() async {
    try {
      return await handler.Permission.location.request();
    } catch (e) {
      return handler.PermissionStatus.denied;
    }
  }

  /// ตรวจสอบว่า Location Permission ได้รับอนุญาตแล้วหรือยัง
  static Future<bool> hasLocationPermission() async {
    try {
      final status = await handler.Permission.location.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// ขอ Permissions หลายตัวพร้อมกัน
  ///
  /// [permissions] - List ของ Permissions ที่ต้องการขอ
  ///
  /// Returns [Map<Permission, PermissionStatus>] สถานะของแต่ละ permission
  static Future<Map<handler.Permission, handler.PermissionStatus>>
  requestMultiplePermissions(
    List<handler.Permission> permissions,
  ) async {
    try {
      final granted = await permissions.request();
      return granted;
    } catch (e) {
      // ถ้าเกิด error ให้ return map ที่ทุก permission เป็น denied
      return Map.fromEntries(
        permissions.map(
          (permission) => MapEntry(permission, handler.PermissionStatus.denied),
        ),
      );
    }
  }
}
