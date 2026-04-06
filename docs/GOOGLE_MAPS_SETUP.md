# Google Maps Setup Guide

## การตั้งค่า Google Maps API

### 1. สร้าง Google Cloud Project และเปิดใช้งาน Maps SDK

1. ไปที่ [Google Cloud Console](https://console.cloud.google.com/)
2. สร้างโปรเจกต์ใหม่ หรือเลือกโปรเจกต์ที่มีอยู่
3. เปิดใช้งาน APIs ต่อไปนี้:
   - Maps SDK for Android
   - Maps SDK for iOS
   - (Optional) Places API - สำหรับค้นหาสถานที่
   - (Optional) Directions API - สำหรับแสดงเส้นทาง
   - (Optional) Geocoding API - สำหรับแปลง address เป็น coordinates

### 2. สร้าง API Keys

#### สำหรับ Android:
1. ไปที่ Credentials → Create Credentials → API Key
2. จำกัดการใช้งาน:
   - Application restrictions: Android apps
   - เพิ่ม Package name: `th.co.abgroup.browny` (หรือตาม package name ของแอป)
   - เพิ่ม SHA-1 fingerprint จาก keystore
3. API restrictions: เลือกเฉพาะ Maps SDK for Android และ APIs ที่ต้องการใช้

**วิธีหา SHA-1 fingerprint:**
```bash
# Debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release keystore
keytool -list -v -keystore /path/to/your/keystore.jks -alias your-key-alias
```

#### สำหรับ iOS:
1. ไปที่ Credentials → Create Credentials → API Key
2. จำกัดการใช้งาน:
   - Application restrictions: iOS apps
   - เพิ่ม Bundle ID: `th.co.abgroup.browny` (หรือตาม bundle ID ของแอป)
3. API restrictions: เลือกเฉพาะ Maps SDK for iOS และ APIs ที่ต้องการใช้

### 3. เพิ่ม API Keys ในโปรเจกต์

#### Android
แก้ไขไฟล์: `android/app/src/main/AndroidManifest.xml`
```xml
<!-- แทนที่ YOUR_GOOGLE_MAPS_API_KEY_HERE ด้วย API Key จริง -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ANDROID_API_KEY_HERE" />
```

#### iOS
แก้ไขไฟล์: `ios/Runner/AppDelegate.swift`

เพิ่มการ import:
```swift
import GoogleMaps
```

เพิ่มใน `application(_:didFinishLaunchingWithOptions:)`:
```swift
GMSServices.provideAPIKey("YOUR_IOS_API_KEY_HERE")
```

ตัวอย่างเต็ม:
```swift
import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_IOS_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 4. ติดตั้ง Dependencies

```bash
flutter pub get
```

### 5. ตัวอย่างการใช้งาน

```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:browny_applications_new/core/utils/location_helper.dart';
import 'package:browny_applications_new/core/utils/google_maps_helper.dart';

// ในหน้า StatefulWidget
GoogleMapController? _mapController;

@override
Widget build(BuildContext context) {
  return GoogleMap(
    initialCameraPosition: GoogleMapsHelper.createCameraPosition(
      target: GoogleMapsHelper.defaultLocation,
    ),
    onMapCreated: (controller) {
      _mapController = controller;
    },
    myLocationEnabled: true,
    myLocationButtonEnabled: true,
    markers: {
      // เพิ่ม markers ตามต้องการ
    },
  );
}

// ดึงตำแหน่งปัจจุบัน
Future<void> _getCurrentLocation() async {
  try {
    final position = await LocationHelper.getCurrentPosition();
    final latLng = LatLng(position.latitude, position.longitude);
    
    if (_mapController != null) {
      await GoogleMapsHelper.animateCamera(
        _mapController!,
        target: latLng,
      );
    }
  } catch (e) {
    // Handle error
    print('Error getting location: $e');
  }
}
```

### 6. สิทธิ์ที่ต้องการ (Permissions)

ระบบได้เพิ่มสิทธิ์ที่จำเป็นไว้แล้วใน:
- `android/app/src/main/AndroidManifest.xml` - ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION
- `ios/Runner/Info.plist` - NSLocationWhenInUseUsageDescription, NSLocationAlwaysUsageDescription

### 7. Testing

1. ทดสอบบน Android Emulator/Device:
   - ตรวจสอบว่า Google Play Services ติดตั้งและอัพเดทแล้ว
   - ตรวจสอบว่า Location Service เปิดอยู่

2. ทดสอบบน iOS Simulator/Device:
   - ใน Simulator: Features → Location → Custom Location
   - ตรวจสอบว่า Location Service เปิดอยู่

### 8. Troubleshooting

#### Map ไม่แสดง (แสดงเป็นสีเทา)
- ตรวจสอบ API Key ว่าถูกต้อง
- ตรวจสอบว่าเปิดใช้งาน Maps SDK แล้ว
- ตรวจสอบ SHA-1 fingerprint (Android)
- ตรวจสอบ Bundle ID (iOS)

#### Permission denied
- ใช้ `LocationHelper.ensureLocationPermission()` ก่อนใช้งาน
- ตรวจสอบ permission descriptions ใน Info.plist (iOS)

#### Build ไม่ผ่าน
- Run `flutter clean`
- Run `flutter pub get`
- Rebuild โปรเจกต์

### 9. Resources

- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [Geolocator Package](https://pub.dev/packages/geolocator)
- [Google Maps Platform](https://developers.google.com/maps)
- [Map Styling Wizard](https://mapstyle.withgoogle.com/)

### 10. Billing

⚠️ **สำคัญ**: Google Maps Platform ต้องเปิดใช้งาน billing account
- มี Free tier: $200/เดือน
- ตรวจสอบการใช้งานที่ [Console](https://console.cloud.google.com/)
- ตั้งค่า budget alerts เพื่อป้องกันค่าใช้จ่ายเกิน
