import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';

/// Utility สำหรับ decrypt PIN ที่ได้จาก Laravel backend
///
/// **⚠️ Security Warning:**
/// - ไม่แนะนำให้เก็บ APP_KEY ฝั่ง client
/// - Utility นี้เป็นเพียงตัวอย่างสำหรับ development/testing
/// - สำหรับ production ควรใช้ online verify ผ่าน API แทน
class PinDecryptionUtil {
  PinDecryptionUtil._();

  /// Decrypt Laravel ciphertext เป็น plain PIN
  ///
  /// Parameters:
  /// - ciphertextB64: ค่าจาก field "ciphertext" ของ API
  /// - appKey: APP_KEY จาก server (รูปแบบ 'base64:xxxx')
  ///
  /// Returns: Plain PIN string
  ///
  /// Throws:
  /// - StateError: ถ้า MAC verification failed
  /// - Exception: ถ้า decrypt failed
  ///
  /// Example:
  /// ```dart
  /// final decryptedPin = PinDecryptionUtil.decryptLaravelCiphertext(
  ///   ciphertextB64: response.ciphertext,
  ///   appKey: 'base64:xrjcblphHL0JGPclO/kiBDSXVm0dnw4i+x6FLBV2I/s=',
  /// );
  /// ```
  static String decryptLaravelCiphertext({
    required String ciphertextB64,
    required String appKey,
  }) {
    // 1) เตรียมกุญแจ 32 ไบต์จาก APP_KEY
    final keyB64 = appKey.startsWith('base64:') ? appKey.substring(7) : appKey;
    final key = base64.decode(keyB64); // ต้องได้ length = 32

    if (key.length != 32) {
      throw Exception('Invalid APP_KEY: must be 32 bytes (256 bits)');
    }

    // 2) base64 decode ชั้นนอก -> JSON
    final payloadJson = utf8.decode(base64.decode(ciphertextB64));
    final payload = json.decode(payloadJson) as Map<String, dynamic>;
    final ivB64 = payload['iv'] as String;
    final valueB64 = payload['value'] as String;
    final macHex = payload['mac'] as String;

    // 3) ตรวจ MAC ให้เหมือน Laravel: HMAC-SHA256(ivB64 + valueB64, key)
    final macCalc = Hmac(
      sha256,
      key,
    ).convert(utf8.encode(ivB64 + valueB64)).toString();

    if (macCalc != macHex) {
      throw StateError('MAC verification failed');
    }

    // 4) ถอดรหัส AES-256-CBC + PKCS7 ด้วย key และ iv
    final iv = base64.decode(ivB64);
    final value = base64.decode(valueB64);

    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESEngine()),
    );

    cipher.init(
      false,
      PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
        ParametersWithIV<KeyParameter>(KeyParameter(key), iv),
        null,
      ),
    );

    final plainBytes = cipher.process(value);
    return utf8.decode(plainBytes);
  }

  /// ตรวจสอบว่า ciphertext ที่ได้จาก API สามารถ decrypt ได้หรือไม่
  ///
  /// **Note:** ต้องมี APP_KEY ที่ถูกต้องจาก server
  ///
  /// Returns: true ถ้า decrypt ได้, false ถ้า decrypt ไม่ได้
  static bool canDecrypt({
    required String ciphertextB64,
    required String appKey,
  }) {
    try {
      decryptLaravelCiphertext(
        ciphertextB64: ciphertextB64,
        appKey: appKey,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
