import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Helper class สำหรับจัดการ Firebase Crashlytics
///
/// ใช้สำหรับ record exceptions และ crashes ภายใน app
///
/// Example:
/// ```dart
/// // Initialize ใน main.dart
/// await CrashlyticsHelper.initialize();
///
/// // Record exception
/// try {
///   // some code
/// } catch (e, stackTrace) {
///   await CrashlyticsHelper.recordError(e, stackTrace, reason: 'Payment failed');
/// }
///
/// // Log custom message
/// CrashlyticsHelper.log('User navigated to checkout');
///
/// // Set user identifier
/// await CrashlyticsHelper.setUserIdentifier('user123');
/// ```
class CrashlyticsHelper {
  static FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;
  static bool _initialized = false;

  /// Initialize Firebase Crashlytics
  ///
  /// ควรเรียกใน main() หลัง Firebase.initializeApp()
  ///
  /// [enableInDebugMode] - เปิดใช้ crashlytics ใน debug mode หรือไม่ (default: false)
  static Future<void> initialize({
    bool enableInDebugMode = false,
  }) async {
    if (_initialized) {
      debugPrint('⚠️ CrashlyticsHelper already initialized');
      return;
    }

    try {
      // ปิด crashlytics ใน debug mode ถ้าไม่ต้องการ
      if (kDebugMode && !enableInDebugMode) {
        await _crashlytics.setCrashlyticsCollectionEnabled(false);
        debugPrint('🔧 Crashlytics disabled in debug mode');
        _initialized = true;
        return;
      }

      // เปิดใช้งาน crashlytics
      await _crashlytics.setCrashlyticsCollectionEnabled(true);

      // Setup Flutter error handler
      FlutterError.onError = (FlutterErrorDetails details) {
        // ถ้าเป็น debug mode ให้แสดง error ตามปกติ
        if (kDebugMode) {
          FlutterError.presentError(details);
        }

        // Record to Crashlytics
        _crashlytics.recordFlutterFatalError(details);
      };

      // Setup platform dispatcher error handler (async errors)
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics.recordError(error, stack, fatal: true);
        return true;
      };

      _initialized = true;
      debugPrint('✅ Crashlytics initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to initialize Crashlytics: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// ==================== Error Recording ====================

  /// Record exception ไปยัง Crashlytics
  ///
  /// [exception] - Exception object
  /// [stackTrace] - Stack trace จาก catch block
  /// [reason] - เหตุผลหรือบริบทของ error (optional)
  /// [fatal] - เป็น fatal error หรือไม่ (default: false)
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? customKeys,
  }) async {
    try {
      // เพิ่ม custom keys ถ้ามี
      if (customKeys != null) {
        for (final entry in customKeys.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value);
        }
      }

      await _crashlytics.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );

      debugPrint('📝 Error recorded to Crashlytics: $exception');
    } catch (e) {
      debugPrint('❌ Failed to record error: $e');
    }
  }

  /// Record Flutter error details
  ///
  /// ใช้สำหรับ record FlutterErrorDetails โดยตรง
  static Future<void> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  }) async {
    try {
      if (fatal) {
        await _crashlytics.recordFlutterFatalError(details);
      } else {
        await _crashlytics.recordFlutterError(details);
      }

      debugPrint('📝 Flutter error recorded to Crashlytics');
    } catch (e) {
      debugPrint('❌ Failed to record Flutter error: $e');
    }
  }

  /// ==================== Logging ====================

  /// Log custom message
  ///
  /// ใช้สำหรับ track user actions หรือ app flow
  /// Logs จะถูกแนบกับ crash reports
  ///
  /// Example:
  /// ```dart
  /// CrashlyticsHelper.log('User clicked checkout button');
  /// CrashlyticsHelper.log('API call: POST /orders');
  /// ```
  static void log(String message) {
    _crashlytics.log(message);
  }

  /// ==================== User Information ====================

  /// ตั้งค่า user identifier
  ///
  /// ใช้สำหรับระบุ user ที่เกิด crash
  ///
  /// Example:
  /// ```dart
  /// await CrashlyticsHelper.setUserIdentifier('user_12345');
  /// ```
  static Future<void> setUserIdentifier(String identifier) async {
    try {
      await _crashlytics.setUserIdentifier(identifier);
      debugPrint('👤 User identifier set: $identifier');
    } catch (e) {
      debugPrint('❌ Failed to set user identifier: $e');
    }
  }

  /// ล้าง user identifier (ใช้เมื่อ user logout)
  static Future<void> clearUserIdentifier() async {
    try {
      await _crashlytics.setUserIdentifier('');
      debugPrint('👤 User identifier cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear user identifier: $e');
    }
  }

  /// ==================== Custom Keys ====================

  /// ตั้งค่า custom key-value
  ///
  /// ใช้สำหรับเพิ่มข้อมูลเพิ่มเติมใน crash reports
  ///
  /// Example:
  /// ```dart
  /// await CrashlyticsHelper.setCustomKey('payment_method', 'credit_card');
  /// await CrashlyticsHelper.setCustomKey('order_total', 1500.0);
  /// ```
  static Future<void> setCustomKey(String key, dynamic value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
      debugPrint('🔑 Custom key set: $key = $value');
    } catch (e) {
      debugPrint('❌ Failed to set custom key: $e');
    }
  }

  /// ตั้งค่า custom keys หลายค่าพร้อมกัน
  ///
  /// Example:
  /// ```dart
  /// await CrashlyticsHelper.setCustomKeys({
  ///   'screen': 'checkout',
  ///   'payment_method': 'credit_card',
  ///   'item_count': 3,
  /// });
  /// ```
  static Future<void> setCustomKeys(Map<String, dynamic> keys) async {
    try {
      for (final entry in keys.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value);
      }
      debugPrint('🔑 ${keys.length} custom keys set');
    } catch (e) {
      debugPrint('❌ Failed to set custom keys: $e');
    }
  }

  /// ==================== Testing ====================

  /// Force crash สำหรับ testing (ใช้ใน debug mode เท่านั้น!)
  ///
  /// ⚠️ **WARNING**: จะทำให้ app crash จริงๆ!
  static void forceCrash() {
    if (kDebugMode) {
      _crashlytics.crash();
    } else {
      debugPrint('⚠️ Force crash is only available in debug mode');
    }
  }

  /// ส่ง test exception
  ///
  /// ใช้สำหรับทดสอบว่า Crashlytics ทำงานถูกต้อง
  static Future<void> sendTestException() async {
    if (kDebugMode) {
      await recordError(
        Exception('This is a test exception from Crashlytics'),
        StackTrace.current,
        reason: 'Testing Crashlytics integration',
        fatal: false,
      );
    } else {
      debugPrint('⚠️ Test exception is only available in debug mode');
    }
  }

  /// ==================== Utility ====================

  /// ตรวจสอบว่า Crashlytics เปิดใช้งานหรือไม่
  static Future<bool> isEnabled() async {
    try {
      return _crashlytics.isCrashlyticsCollectionEnabled;
    } catch (e) {
      return false;
    }
  }

  /// Check if initialized
  static bool get isInitialized => _initialized;
}
