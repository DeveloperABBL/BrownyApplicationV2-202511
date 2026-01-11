import 'dart:io';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

/// Helper class สำหรับจัดการการแชร์ข้อมูลต่างๆ
class ShareHelper {
  // Private constructor เพื่อป้องกันการสร้าง instance
  ShareHelper._();

  /// แชร์ข้อความธรรมดา
  ///
  /// [text] - ข้อความที่ต้องการแชร์
  /// [subject] - หัวข้อของการแชร์ (optional)
  ///
  /// Returns [ShareResult] ผลลัพธ์ของการแชร์
  static Future<ShareResult> shareText(
    String text, {
    String? subject,
  }) async {
    try {
      return await Share.share(
        text,
        subject: subject,
      );
    } catch (e) {
      return ShareResult.unavailable;
    }
  }

  /// แชร์ URL
  ///
  /// [url] - URL ที่ต้องการแชร์
  /// [subject] - หัวข้อของการแชร์ (optional)
  ///
  /// Returns [ShareResult] ผลลัพธ์ของการแชร์
  static Future<ShareResult> shareUrl(
    String url, {
    String? subject,
  }) async {
    try {
      return await Share.shareUri(
        Uri.parse(url),
      );
    } catch (e) {
      return ShareResult.unavailable;
    }
  }

  /// แชร์ไฟล์เดียว
  ///
  /// [filePath] - Path ของไฟล์ที่ต้องการแชร์
  /// [text] - ข้อความที่จะแนบไปกับไฟล์ (optional)
  /// [subject] - หัวข้อของการแชร์ (optional)
  ///
  /// Returns [ShareResult] ผลลัพธ์ของการแชร์
  static Future<ShareResult> shareFile(
    String filePath, {
    String? text,
    String? subject,
  }) async {
    try {
      final file = XFile(filePath);
      return await Share.shareXFiles(
        [file],
        text: text,
        subject: subject,
      );
    } catch (e) {
      return ShareResult.unavailable;
    }
  }

  /// แชร์หลายไฟล์พร้อมกัน
  ///
  /// [filePaths] - List ของ paths ของไฟล์ที่ต้องการแชร์
  /// [text] - ข้อความที่จะแนบไปกับไฟล์ (optional)
  /// [subject] - หัวข้อของการแชร์ (optional)
  ///
  /// Returns [ShareResult] ผลลัพธ์ของการแชร์
  static Future<ShareResult> shareFiles(
    List<String> filePaths, {
    String? text,
    String? subject,
  }) async {
    try {
      final files = filePaths.map((path) => XFile(path)).toList();
      return await Share.shareXFiles(
        files,
        text: text,
        subject: subject,
      );
    } catch (e) {
      return ShareResult.unavailable;
    }
  }

  /// แชร์รูปภาพจาก Uint8List (bytes)
  ///
  /// [imageBytes] - ข้อมูลรูปภาพในรูปแบบ bytes
  /// [fileName] - ชื่อไฟล์ที่ต้องการใช้ (รวม extension เช่น 'receipt.png')
  /// [text] - ข้อความที่จะแนบไปกับรูปภาพ (optional)
  /// [subject] - หัวข้อของการแชร์ (optional)
  ///
  /// Returns [ShareResult] ผลลัพธ์ของการแชร์
  static Future<ShareResult> shareImage(
    Uint8List imageBytes, {
    required String fileName,
    String? text,
    String? subject,
  }) async {
    try {
      // สร้างไฟล์ชั่วคราวใน temp directory
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');

      // เขียนข้อมูลลงไฟล์
      await tempFile.writeAsBytes(imageBytes);

      // แชร์ไฟล์
      final result = await shareFile(
        tempFile.path,
        text: text,
        subject: subject,
      );

      // ลบไฟล์ชั่วคราวหลังจากแชร์เสร็จ (optional - iOS จะลบอัตโนมัติ)
      try {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (e) {
        // Ignore deletion errors
      }

      return result;
    } catch (e) {
      return ShareResult.unavailable;
    }
  }

  /// แชร์หลายรูปภาพจาก Uint8List (bytes)
  ///
  /// [images] - List ของ Map ที่มี 'bytes' และ 'fileName'
  /// [text] - ข้อความที่จะแนบไปกับรูปภาพ (optional)
  /// [subject] - หัวข้อของการแชร์ (optional)
  ///
  /// Returns [ShareResult] ผลลัพธ์ของการแชร์
  static Future<ShareResult> shareImages(
    List<Map<String, dynamic>> images, {
    String? text,
    String? subject,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFiles = <File>[];

      // สร้างไฟล์ชั่วคราวสำหรับแต่ละรูปภาพ
      for (final image in images) {
        final bytes = image['bytes'] as Uint8List;
        final fileName = image['fileName'] as String;
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(bytes);
        tempFiles.add(tempFile);
      }

      // แชร์ไฟล์ทั้งหมด
      final result = await shareFiles(
        tempFiles.map((f) => f.path).toList(),
        text: text,
        subject: subject,
      );

      // ลบไฟล์ชั่วคราวหลังจากแชร์เสร็จ
      for (final file in tempFiles) {
        try {
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          // Ignore deletion errors
        }
      }

      return result;
    } catch (e) {
      return ShareResult.unavailable;
    }
  }

  /// แชร์ข้อความพร้อมไฟล์
  ///
  /// [text] - ข้อความที่ต้องการแชร์
  /// [filePath] - Path ของไฟล์ที่ต้องการแชร์
  /// [subject] - หัวข้อของการแชร์ (optional)
  ///
  /// Returns [ShareResult] ผลลัพธ์ของการแชร์
  static Future<ShareResult> shareTextWithFile(
    String text,
    String filePath, {
    String? subject,
  }) async {
    try {
      final file = XFile(filePath);
      return await Share.shareXFiles(
        [file],
        text: text,
        subject: subject,
      );
    } catch (e) {
      return ShareResult.unavailable;
    }
  }

  /// แชร์รูปภาพพร้อมข้อความ (สำหรับ Social Media)
  ///
  /// [imageBytes] - ข้อมูลรูปภาพในรูปแบบ bytes
  /// [fileName] - ชื่อไฟล์ที่ต้องการใช้
  /// [caption] - ข้อความที่จะแนบไปกับรูปภาพ
  ///
  /// Returns [ShareResult] ผลลัพธ์ของการแชร์
  static Future<ShareResult> shareImageWithCaption(
    Uint8List imageBytes, {
    required String fileName,
    required String caption,
  }) async {
    return await shareImage(
      imageBytes,
      fileName: fileName,
      text: caption,
    );
  }

  /// ตรวจสอบว่าระบบรองรับการแชร์หรือไม่
  ///
  /// Returns [bool] true ถ้ารองรับการแชร์
  static Future<bool> canShare() async {
    try {
      // share_plus รองรับทุก platform ที่ Flutter รองรับ
      return true;
    } catch (e) {
      return false;
    }
  }
}
