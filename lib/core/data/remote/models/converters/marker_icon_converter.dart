import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:browny_applications_new/core/core_index.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// DONG 2026-01-28
///
/// Converter สำหรับ download marker icon จาก URL และแปลงเป็น BitmapDescriptor
class MarkerIconConverter {
  /// Dio instance เฉพาะกิจสำหรับ download รูปภาพ
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  /// Download marker icon จาก URL และแปลงเป็น BitmapDescriptor
  ///
  /// [url] - URL ของรูปภาพ marker
  /// [width] - ความกว้างที่ต้องการ resize (default: 100)
  Future<BitmapDescriptor> getMarkerIconFromUrl(
    String url, {
    int width = 100,
  }) async {
    try {
      // ใช้ Dio download รูปภาพเป็น bytes
      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes, // สำคัญ: ขอเป็น Bytes ไม่ใช่ JSON
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        // แปลง List<int> เป็น Uint8List
        final Uint8List imageData = Uint8List.fromList(response.data!);

        // Decode ครั้งแรกเพื่อหา aspect ratio ของภาพต้นฉบับ
        final ui.Codec codecForSize = await ui.instantiateImageCodec(imageData);
        final ui.FrameInfo frameInfoForSize = await codecForSize.getNextFrame();
        final originalWidth = frameInfoForSize.image.width;
        final originalHeight = frameInfoForSize.image.height;

        // คำนวณ targetHeight ให้สัดส่วนกับ targetWidth
        final aspectRatio = originalHeight / originalWidth;
        final targetHeight = (width * aspectRatio).round();

        // Decode ครั้งสองพร้อม resize ตาม aspect ratio
        final ui.Codec codec = await ui.instantiateImageCodec(
          imageData,
          targetWidth: width,
          targetHeight:
              targetHeight, // กำหนด height ให้สัดส่วนเพื่อไม่ให้ภาพบิดเบี้ยว
        );
        final ui.FrameInfo frameInfo = await codec.getNextFrame();
        final ByteData? byteData = await frameInfo.image.toByteData(
          format: ui.ImageByteFormat.png,
        );

        final Uint8List resizedBytes = byteData!.buffer.asUint8List();

        return BitmapDescriptor.bytes(resizedBytes);
      } else {
        return BitmapDescriptor.defaultMarker;
      }
    } catch (e) {
      // DioError จะถูก catch ที่นี่
      debugPrint("Dio Error loading marker: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }

  /// Download marker icons ทั้ง active และ inactive พร้อมกัน
  ///
  /// Returns: Map with 'active' and 'inactive' keys
  Future<Map<String, BitmapDescriptor>> getMarkerIcons({
    required String activeUrl,
    required String inactiveUrl,
    int width = 100,
  }) async {
    try {
      // Download ทั้งสองรูปพร้อมกัน
      final results = await Future.wait([
        getMarkerIconFromUrl(activeUrl, width: width),
        getMarkerIconFromUrl(inactiveUrl, width: width),
      ]);

      return {
        'active': results[0],
        'inactive': results[1],
      };
    } catch (e) {
      debugPrint("Error loading marker icons: $e");
      return {
        'active': BitmapDescriptor.defaultMarker,
        'inactive': BitmapDescriptor.defaultMarker,
      };
    }
  }

  /// Dispose Dio instance
  void dispose() {
    _dio.close();
  }
}
