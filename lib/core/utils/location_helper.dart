import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Helper class สำหรับจัดการตำแหน่งที่ตั้ง (Location) และ Google Maps
class LocationHelper {
  // Private constructor เพื่อป้องกันการสร้าง instance
  LocationHelper._();

  /// ตรวจสอบว่า Location Service เปิดอยู่หรือไม่
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// ตรวจสอบสถานะ Location Permission
  static Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// ขอ Location Permission
  ///
  /// Returns [LocationPermission] สถานะของ permission หลังจากขอ
  static Future<LocationPermission> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// ตรวจสอบและขอ Permission พร้อมเปิด Location Service (ถ้าจำเป็น)
  ///
  /// Returns [bool] true ถ้าสามารถใช้งาน Location ได้
  static Future<bool> ensureLocationPermission() async {
    // ตรวจสอบว่า Location Service เปิดอยู่หรือไม่
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location service ปิดอยู่ - แจ้งให้ผู้ใช้เปิด
      return false;
    }

    // ตรวจสอบและขอ permission
    LocationPermission permission = await requestLocationPermission();

    // ถ้า permission ถูก denied forever
    if (permission == LocationPermission.deniedForever) {
      // ต้องให้ผู้ใช้ไปเปิดใน Settings
      return false;
    }

    // ถ้าได้รับอนุญาต
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return true;
    }

    return false;
  }

  /// ดึงตำแหน่งปัจจุบันของผู้ใช้
  ///
  /// [desiredAccuracy] - ความแม่นยำที่ต้องการ (default: LocationAccuracy.high)
  ///
  /// Returns [Position] ตำแหน่งปัจจุบัน หรือ throw Exception ถ้าไม่สามารถดึงได้
  static Future<Position> getCurrentPosition({
    LatLng? currentPosition,
    LocationAccuracy desiredAccuracy = LocationAccuracy.best,
  }) async {
    // ตรวจสอบ permission ก่อน
    if (currentPosition == null) {
      bool hasPermission = await ensureLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission not granted');
      }
    }

    // ดึงตำแหน่งปัจจุบัน
    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: desiredAccuracy,
        distanceFilter: 10, // อัพเดทเมื่อเคลื่อนที่ 10 เมตร
      ),
    );
  }

  /// คำนวณระยะทางระหว่าง 2 จุด (เป็นเมตร)
  ///
  /// [startLatitude] - latitude จุดเริ่มต้น
  /// [startLongitude] - longitude จุดเริ่มต้น
  /// [endLatitude] - latitude จุดปลายทาง
  /// [endLongitude] - longitude จุดปลายทาง
  ///
  /// Returns [double] ระยะทางเป็นเมตร
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// เปิดแอปการตั้งค่า Location
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Stream สำหรับติดตามตำแหน่งแบบ real-time
  ///
  /// [desiredAccuracy] - ความแม่นยำที่ต้องการ
  /// [distanceFilter] - ระยะทางขั้นต่ำ (เมตร) ที่จะ trigger update (default: 10)
  ///
  /// Returns [Stream<Position>] stream ของตำแหน่งที่อัพเดท
  static Stream<Position> getPositionStream({
    LocationAccuracy desiredAccuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: desiredAccuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// แปลงระยะทางจากเมตรเป็นกิโลเมตร
  static double metersToKilometers(double meters) {
    return meters / 1000;
  }

  /// จัดรูปแบบระยะทาง (แสดงเป็น km หรือ m ตามความเหมาะสม)
  ///
  /// Returns [String] ระยะทางในรูปแบบที่อ่านง่าย เช่น "1.5 km" หรือ "500 m"
  static String formatDistance(double meters) {
    if (meters >= 1000) {
      double km = metersToKilometers(meters);
      return '${km.toStringAsFixed(1)} km';
    } else {
      return '${meters.toStringAsFixed(0)} m';
    }
  }
}
