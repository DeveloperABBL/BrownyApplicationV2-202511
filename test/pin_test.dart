import 'dart:convert';
import 'package:crypto/crypto.dart';
// import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';

void main() {
  // 1. ข้อมูลที่ได้จาก API
  final apiResponse = {
    "success": true,
    "ciphertext":
        "eyJpdiI6IkEzMTlyL2JFOU80bmFLdHFBS1hXZkE9PSIsInZhbHVlIjoiUmF0NGdSYXVYOXZBeGU4bVpIYVZUQT09IiwibWFjIjoiZjhhYmQ5NjJjNjc3MTZmMmY0MzYwZjIwNmFmMTBlNGE3NzliNmExYzJlYjMyNWU5ZTk4YjUxNzBjOWU1NjMwNyIsInRhZyI6IiJ9",
    "cipher": "AES-256-CBC",
  };

  test('Pin Decode', () async {
    // 2. *** สำคัญมาก ***: ต้องเอา Key มาจาก Server (ปกติคือ APP_KEY ใน .env)
    // หาก Key ใน Server ขึ้นต้นด้วย base64: ต้อง decode ก่อน
    // ตัวอย่างนี้สมมติว่าเป็น Key ขนาด 32 bytes (256 bit)
    // คุณต้องเปลี่ยนค่านี้ให้ตรงกับ Server!
    const String serverKey =
        "base64:xrjcblphHL0JGPclO/kiBDSXVm0dnw4i+x6FLBV2I/s=";

    try {
      final decryptedText = decryptLaravelCiphertext(
        ciphertextB64: apiResponse['ciphertext'] as String,
        appKey: serverKey,
      );

      print('Decrypted PIN: $decryptedText'); // ควรจะเป็น 111111
    } catch (e) {
      print('Error: $e');
      print('สาเหตุที่เป็นไปได้: Key ไม่ถูกต้อง หรือ Format ของ Key ผิด');
    }
  });
}

String decryptLaravelCiphertext({
  required String ciphertextB64, // ค่าจาก field "ciphertext" ของ API
  required String appKey, // รูปแบบ 'base64:xxxx'
}) {
  // 1) เตรียมกุญแจ 32 ไบต์จาก APP_KEY
  final keyB64 = appKey.startsWith('base64:') ? appKey.substring(7) : appKey;
  final key = base64.decode(keyB64); // ต้องได้ length = 32

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

  // 4) ถอดรหัส AES-256-CBC + PKCS7 ด้วย key และ iv (อันนี้ค่อย base64.decode)
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

// String decryptLaravelPayload({
//   required String payload,
//   required String keyString,
// }) {
//   try {
//     // 1. Decode Base64 ก้อนใหญ่ก่อน เพื่อให้ได้ JSON ภายใน
//     // Payload จริงๆ คือ JSON string ที่ถูก Base64 encode ไว้
//     final String jsonStr = utf8.decode(base64Decode(payload));
//     final Map<String, dynamic> payloadMap = jsonDecode(jsonStr);

//     // 2. ดึงค่า iv และ value (encrypted data)
//     final String ivBase64 = payloadMap['iv'];
//     final String valueBase64 = payloadMap['value'];

//     // 3. เตรียม Key และ IV
//     // ถ้า Key เป็น Base64 ให้ใช้ encrypt.Key.fromBase64(keyString)
//     // ถ้า Key เป็น Plain text ให้ใช้ encrypt.Key.utf8(keyString)
//     // โดยปกติ Laravel key มักจะเป็น base64 encoded มาแล้ว

//     // ** ตรวจสอบว่า Key ของคุณเป็นแบบไหน **
//     // ถ้า key ขึ้นต้นด้วย "base64:..." ให้ตัดคำว่า base64: ออกแล้วใช้ fromBase64
//     final key = encrypt.Key.fromBase64(keyString);
//     // หรือถ้าเป็น text ธรรมดาใช้: final key = encrypt.Key.utf8(keyString);

//     final iv = encrypt.IV.fromBase64(ivBase64);

//     // 4. ตั้งค่า Encrypter เป็น AES โหมด CBC (ตามที่ JSON ระบุ)
//     final encrypter = encrypt.Encrypter(
//       encrypt.AES(key, mode: encrypt.AESMode.cbc),
//     );

//     // 5. ทำการ Decrypt
//     final decrypted = encrypter.decrypt64(valueBase64, iv: iv);

//     // 6. Laravel บางครั้งจะ serialize ข้อมูล (เช่น s:6:"111111";)
//     // แต่ถ้าเป็นการ encrypt string ธรรมดา จะได้ค่าออกมาเลย
//     return decrypted;
//   } catch (e) {
//     throw Exception('Decryption failed: $e');
//   }
// }
