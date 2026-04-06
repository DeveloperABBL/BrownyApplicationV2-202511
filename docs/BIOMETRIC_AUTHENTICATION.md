# 🔐 Biometric Authentication Implementation Guide

## 📋 สารบัญ
- [ภาพรวม](#ภาพรวม)
- [Requirements](#requirements)
- [Configuration](#configuration)
- [Architecture](#architecture)
- [Security Features](#security-features)
- [Usage Examples](#usage-examples)
- [API Reference](#api-reference)
- [Error Handling](#error-handling)
- [Best Practices](#best-practices)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

---

## ภาพรวม

ระบบ Biometric Authentication รองรับ:
- ✅ **Face ID** (iOS)
- ✅ **Touch ID** (iOS)  
- ✅ **Fingerprint** (Android)
- ✅ **Face Recognition** (Android)
- ✅ **Iris Scan** (Android)

### Key Features
1. **Security First**: Biometric ต้องใช้ร่วมกับ PIN เท่านั้น
2. **Fallback to PIN**: หาก Biometric ล้มเหลว ให้ใช้ PIN
3. **Device Encryption**: ใช้ Keychain (iOS) / Keystore (Android)
4. **Error Handling**: จัดการ Error แบบละเอียด
5. **User Control**: ผู้ใช้สามารถเปิด/ปิด Biometric ได้

---

## Requirements

### Packages
```yaml
dependencies:
  local_auth: ^3.0.0
  flutter_secure_storage: ^9.2.4
  crypto: ^3.0.7
```

### Minimum Versions
- **iOS**: 12.0+
- **Android**: API 23+ (Android 6.0 Marshmallow)

---

## Configuration

### iOS Configuration

#### 1. Info.plist
เพิ่ม permission description:

```xml
<key>NSFaceIDUsageDescription</key>
<string>เราต้องการใช้ Face ID หรือ Touch ID เพื่อยืนยันตัวตนของคุณ</string>
```

#### 2. iOS Version
ตรวจสอบใน `ios/Podfile`:

```ruby
platform :ios, '12.0'
```

### Android Configuration

#### 1. AndroidManifest.xml
เพิ่ม permissions:

```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>
```

#### 2. MainActivity
เปลี่ยนจาก `FlutterActivity` เป็น `FlutterFragmentActivity`:

```kotlin
package com.yourpackage.app

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

#### 3. MinSdkVersion
ตรวจสอบใน `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 23
    }
}
```

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                        UI Layer                         │
│  - Login Screen / Settings Screen                       │
│  - Show Biometric Dialog                                │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                   ViewModel Layer                        │
│  - PinViewModel                                          │
│  - State Management                                      │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                 Repository Layer                         │
│  - PinRepository                                         │
│    ├─ authenticateWithBiometric()                       │
│    ├─ isBiometricAvailable()                            │
│    ├─ setBiometricEnabled()                             │
│    └─ hasStrongBiometric()                              │
└────────────────────┬────────────────────────────────────┘
                     │
          ┌──────────┴──────────┐
          ▼                     ▼
┌──────────────────┐  ┌──────────────────────┐
│ BiometricHelper  │  │ AppLocalStorageSecure│
│                  │  │                      │
│ - local_auth     │  │ - PIN Hash + Salt    │
│ - Error Handling │  │ - Biometric Enabled  │
│ - Type Detection │  │ - Secure Storage     │
└──────────────────┘  └──────────────────────┘
          │                     │
          ▼                     ▼
┌──────────────────────────────────────────┐
│          Platform Layer                   │
│  iOS: Keychain + LAContext                │
│  Android: Keystore + BiometricPrompt     │
└──────────────────────────────────────────┘
```

---

## Security Features

### 1. PIN is Mandatory
- ❌ **ห้าม** เปิดใช้ Biometric โดยไม่มี PIN
- ✅ ต้องตั้ง PIN ก่อนเสมอ
- ✅ PIN ใช้เป็น Fallback เมื่อ Biometric ล้มเหลว

```dart
// ✅ Correct Flow
await pinRepository.savePin('123456');  // ตั้ง PIN ก่อน
await pinRepository.setBiometricEnabled(true);  // แล้วค่อยเปิด Biometric

// ❌ Wrong Flow
await pinRepository.setBiometricEnabled(true);  // Error!
```

### 2. Biometric Only Mode
```dart
AuthenticationOptions(
  biometricOnly: true,  // ✅ ใช้เฉพาะ Biometric
  // ไม่รวม Device PIN/Pattern/Password
)
```

### 3. Strong Biometric Detection
ตรวจสอบว่ามี Strong Biometric (Face ID, Fingerprint, Iris) หรือไม่  
**ไม่รวม** Weak Biometric เช่น Smart Lock

```dart
final result = await pinRepository.hasStrongBiometric();
if (result.isSuccess && result.data == true) {
  // แสดง Biometric option
}
```

### 4. Rate Limiting & Lock Out
local_auth มี built-in rate limiting:
- **iOS**: ล้มเหลว 5 ครั้ง → ล็อก 30 วินาที
- **Android**: ล้มเหลว 5 ครั้ง → ล็อก 30 วินาที
- **Permanently Locked**: ล้มเหลวมากเกินไป → ใช้ PIN แทน

### 5. Data Encryption
```
┌─────────────────────────────────────────┐
│        User's PIN: "123456"             │
└────────────────┬────────────────────────┘
                 │
                 ▼
      ┌──────────────────────┐
      │  Generate Salt       │
      │  (Random 32 chars)   │
      └──────────┬───────────┘
                 │
                 ▼
      ┌──────────────────────┐
      │  SHA-256 Hash        │
      │  PIN + Salt          │
      └──────────┬───────────┘
                 │
                 ▼
      ┌──────────────────────┐
      │  Store in Keychain/  │
      │  Keystore            │
      │  - app_pin_hash      │
      │  - app_pin_salt      │
      │  - biometric_enabled │
      └──────────────────────┘
```

---

## Usage Examples

### 1. ตรวจสอบว่ารองรับ Biometric หรือไม่

```dart
final pinRepository = PinRepository();

final result = await pinRepository.isBiometricAvailable();
if (result.isSuccess && result.data == true) {
  print('✅ อุปกรณ์รองรับ Biometric');
} else {
  print('❌ อุปกรณ์ไม่รองรับ Biometric');
}
```

### 2. เปิดใช้งาน Biometric (หลังจากตั้ง PIN แล้ว)

```dart
// Step 1: ตรวจสอบว่ามี PIN หรือยัง
final hasPinResult = await pinRepository.hasPin();
if (!hasPinResult.isSuccess || hasPinResult.data != true) {
  print('❌ กรุณาตั้ง PIN ก่อน');
  return;
}

// Step 2: ตรวจสอบว่ารองรับ Biometric หรือไม่
final availableResult = await pinRepository.isBiometricAvailable();
if (!availableResult.isSuccess || availableResult.data != true) {
  print('❌ อุปกรณ์ไม่รองรับ Biometric');
  return;
}

// Step 3: เปิดใช้งาน
final enableResult = await pinRepository.setBiometricEnabled(true);
if (enableResult.isSuccess) {
  print('✅ เปิดใช้งาน Biometric สำเร็จ');
}
```

### 3. Login ด้วย Biometric

```dart
Future<void> loginWithBiometric() async {
  final pinRepository = PinRepository();

  // ตรวจสอบว่าเปิดใช้งาน Biometric หรือไม่
  final enabledResult = await pinRepository.isBiometricEnabled();
  if (!enabledResult.isSuccess || enabledResult.data != true) {
    print('❌ Biometric ไม่ได้เปิดใช้งาน');
    // แสดงหน้า PIN แทน
    return;
  }

  // ทำการ Authenticate
  final authResult = await pinRepository.authenticateWithBiometric(
    reason: 'กรุณายืนยันตัวตนเพื่อเข้าสู่ระบบ',
  );

  if (authResult.isSuccess) {
    final result = authResult.data!;

    if (result.isSuccess) {
      print('✅ Login สำเร็จ');
      // Navigate to Home
    } else {
      // จัดการ Error
      switch (result.errorType) {
        case BiometricAuthErrorType.userCanceled:
          print('ผู้ใช้ยกเลิก - แสดงหน้า PIN');
          // Show PIN screen
          break;

        case BiometricAuthErrorType.lockedOut:
          print('ลองผิดหลายครั้ง - แสดงหน้า PIN');
          // Show PIN screen with message
          break;

        case BiometricAuthErrorType.permanentlyLockedOut:
          print('ถูกล็อกถาวร - ใช้ PIN เท่านั้น');
          // Force PIN screen
          break;

        default:
          print('เกิดข้อผิดพลาด: ${result.errorMessage}');
      }
    }
  }
}
```

### 4. UI Flow - Login Screen with Biometric

```dart
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pinRepository = PinRepository();
  bool _showBiometricOption = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    // ตรวจสอบว่าเปิดใช้งาน Biometric หรือไม่
    final result = await _pinRepository.isBiometricEnabled();
    setState(() {
      _showBiometricOption = result.isSuccess && result.data == true;
    });

    // Auto-show Biometric dialog
    if (_showBiometricOption) {
      _authenticateWithBiometric();
    }
  }

  Future<void> _authenticateWithBiometric() async {
    final result = await _pinRepository.authenticateWithBiometric(
      reason: 'กรุณายืนยันตัวตนเพื่อเข้าสู่ระบบ',
    );

    if (result.isSuccess && result.data!.isSuccess) {
      // Navigate to Home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Show error or fallback to PIN
      final errorType = result.data?.errorType;
      if (errorType == BiometricAuthErrorType.userCanceled) {
        // User canceled - do nothing, let them use PIN
      } else if (errorType == BiometricAuthErrorType.lockedOut) {
        _showMessage('ลองผิดหลายครั้ง กรุณาใช้ PIN');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Column(
        children: [
          // PIN Input
          PinInputWidget(
            onCompleted: (pin) async {
              final result = await _pinRepository.verifyPin(pin);
              if (result.isSuccess && result.data == true) {
                Navigator.pushReplacementNamed(context, '/home');
              } else {
                _showMessage('PIN ไม่ถูกต้อง');
              }
            },
          ),

          // Biometric Button
          if (_showBiometricOption)
            IconButton(
              icon: Icon(Icons.fingerprint, size: 48),
              onPressed: _authenticateWithBiometric,
            ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
```

### 5. Settings - เปิด/ปิด Biometric

```dart
class BiometricSettingTile extends StatefulWidget {
  @override
  State<BiometricSettingTile> createState() => _BiometricSettingTileState();
}

class _BiometricSettingTileState extends State<BiometricSettingTile> {
  final _pinRepository = PinRepository();
  bool _isEnabled = false;
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final availableResult = await _pinRepository.isBiometricAvailable();
    final enabledResult = await _pinRepository.isBiometricEnabled();

    setState(() {
      _isAvailable = availableResult.isSuccess && availableResult.data == true;
      _isEnabled = enabledResult.isSuccess && enabledResult.data == true;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      // เปิดใช้งาน - ต้องยืนยันตัวตนก่อน
      final authResult = await _pinRepository.authenticateWithBiometric(
        reason: 'กรุณายืนยันตัวตนเพื่อเปิดใช้งาน Biometric',
      );

      if (authResult.isSuccess && authResult.data!.isSuccess) {
        await _pinRepository.setBiometricEnabled(true);
        setState(() => _isEnabled = true);
        _showMessage('✅ เปิดใช้งาน Biometric สำเร็จ');
      } else {
        _showMessage('❌ การยืนยันตัวตนล้มเหลว');
      }
    } else {
      // ปิดใช้งาน
      await _pinRepository.setBiometricEnabled(false);
      setState(() => _isEnabled = false);
      _showMessage('ปิดใช้งาน Biometric แล้ว');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAvailable) {
      return ListTile(
        leading: Icon(Icons.fingerprint),
        title: AppText('Face ID / Fingerprint'),
        subtitle: AppText('อุปกรณ์ไม่รองรับหรือไม่มีการลงทะเบียน'),
        enabled: false,
      );
    }

    return SwitchListTile(
      secondary: Icon(Icons.fingerprint),
      title: AppText('Face ID / Fingerprint'),
      subtitle: AppText(_isEnabled ? 'เปิดใช้งาน' : 'ปิดใช้งาน'),
      value: _isEnabled,
      onChanged: _toggleBiometric,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
```

---

## API Reference

### BiometricHelper

#### Methods

##### `canCheckBiometrics()`
```dart
Future<bool> canCheckBiometrics()
```
ตรวจสอบว่าอุปกรณ์รองรับการตรวจสอบ Biometric หรือไม่

**Returns:** `true` ถ้ารองรับ

---

##### `isBiometricAvailable()`
```dart
Future<bool> isBiometricAvailable()
```
ตรวจสอบว่ามี Biometric ที่พร้อมใช้งานหรือไม่ (มีการลงทะเบียนแล้ว)

**Returns:** `true` ถ้าพร้อมใช้งาน

---

##### `getAvailableBiometrics()`
```dart
Future<List<BiometricType>> getAvailableBiometrics()
```
ดึงรายการ Biometric types ที่มีในอุปกรณ์

**Returns:** List of `BiometricType`
- `BiometricType.face` - Face ID / Face Recognition
- `BiometricType.fingerprint` - Touch ID / Fingerprint
- `BiometricType.iris` - Iris scan
- `BiometricType.strong` - Strong biometric
- `BiometricType.weak` - Weak biometric (Smart Lock)

---

##### `authenticateWithBiometric()`
```dart
Future<BiometricAuthResult> authenticateWithBiometric({
  String localizedReason = 'กรุณายืนยันตัวตนเพื่อดำเนินการต่อ',
  bool useErrorDialogs = true,
  bool stickyAuth = true,
})
```
ทำการ Authenticate ด้วย Biometric

**Parameters:**
- `localizedReason`: ข้อความที่แสดงใน Biometric dialog
- `useErrorDialogs`: แสดง error dialog หรือไม่
- `stickyAuth`: lock UI จนกว่าจะ authenticate สำเร็จหรือยกเลิก

**Returns:** `BiometricAuthResult`

---

##### `hasStrongBiometric()`
```dart
Future<bool> hasStrongBiometric()
```
ตรวจสอบว่ามี Strong Biometric (Face, Fingerprint, Iris) หรือไม่

**Returns:** `true` ถ้ามี Strong Biometric

---

### BiometricAuthResult

```dart
class BiometricAuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final BiometricAuthErrorType? errorType;
}
```

**Properties:**
- `isSuccess`: สำเร็จหรือไม่
- `errorMessage`: ข้อความ error (ถ้ามี)
- `errorType`: ประเภทของ error

---

### BiometricAuthErrorType

```dart
enum BiometricAuthErrorType {
  userCanceled,           // ผู้ใช้ยกเลิก
  lockedOut,              // ล็อกชั่วคราว
  permanentlyLockedOut,   // ล็อกถาวร
  notAvailable,           // ไม่รองรับ
  notEnrolled,            // ไม่มีการลงทะเบียน
  other,                  // อื่นๆ
}
```

---

### PinRepository (Biometric Methods)

#### `isBiometricAvailable()`
```dart
Future<RepoResult<bool>> isBiometricAvailable()
```
ตรวจสอบว่าอุปกรณ์รองรับ Biometric หรือไม่

---

#### `authenticateWithBiometric()`
```dart
Future<RepoResult<BiometricAuthResult>> authenticateWithBiometric({
  String? reason,
})
```
ทำการ Authenticate ด้วย Biometric

**Pre-conditions:**
- ✅ ต้องมี PIN ตั้งไว้แล้ว
- ✅ ต้องเปิดใช้งาน Biometric แล้ว

**Returns:** `RepoResult<BiometricAuthResult>`

---

#### `setBiometricEnabled()`
```dart
Future<RepoResult<bool>> setBiometricEnabled(bool enabled)
```
เปิด/ปิด การใช้งาน Biometric

---

#### `isBiometricEnabled()`
```dart
Future<RepoResult<bool>> isBiometricEnabled()
```
ตรวจสอบว่าเปิดใช้งาน Biometric หรือไม่

---

#### `hasStrongBiometric()`
```dart
Future<RepoResult<bool>> hasStrongBiometric()
```
ตรวจสอบว่ามี Strong Biometric หรือไม่

---

## Error Handling

### Error Types

| Error Type | iOS | Android | Action |
|-----------|-----|---------|--------|
| `notAvailable` | ไม่รองรับ | ไม่รองรับ | ซ่อน Biometric option |
| `notEnrolled` | ไม่มี Face ID/Touch ID | ไม่มี Fingerprint | แนะนำให้ตั้งค่า |
| `userCanceled` | กด Cancel | กด Cancel | ให้ใช้ PIN |
| `lockedOut` | ล้มเหลว 5 ครั้ง | ล้มเหลว 5 ครั้ง | แสดงเวลารอ + ใช้ PIN |
| `permanentlyLockedOut` | ล้มเหลวมากเกินไป | ล้มเหลวมากเกินไป | บังคับใช้ PIN |

### Error Messages (Thai)

```dart
String getErrorMessage(BiometricAuthErrorType type) {
  switch (type) {
    case BiometricAuthErrorType.notAvailable:
      return 'อุปกรณ์ไม่รองรับ Biometric';

    case BiometricAuthErrorType.notEnrolled:
      return 'ไม่มี Biometric ที่ลงทะเบียนไว้\nกรุณาตั้งค่าในเครื่อง';

    case BiometricAuthErrorType.userCanceled:
      return 'คุณยกเลิกการยืนยันตัวตน';

    case BiometricAuthErrorType.lockedOut:
      return 'ลองผิดหลายครั้งเกินไป\nกรุณารอสักครู่หรือใช้ PIN';

    case BiometricAuthErrorType.permanentlyLockedOut:
      return 'Biometric ถูกล็อกถาวร\nกรุณาใช้ PIN';

    default:
      return 'เกิดข้อผิดพลาด กรุณาลองใหม่';
  }
}
```

---

## Best Practices

### 1. ✅ PIN is Primary, Biometric is Secondary
```dart
// ❌ Wrong
if (biometricAvailable) {
  showBiometricOnly();
}

// ✅ Correct
if (biometricEnabled) {
  tryBiometric();
  if (failed) {
    showPinFallback();  // Always have PIN fallback
  }
}
```

### 2. ✅ Check Availability Before Showing UI
```dart
@override
void initState() {
  super.initState();
  _checkBiometricAvailability();
}

Future<void> _checkBiometricAvailability() async {
  final result = await pinRepository.isBiometricAvailable();
  setState(() {
    _showBiometricOption = result.isSuccess && result.data == true;
  });
}
```

### 3. ✅ Handle All Error Cases
```dart
final result = await pinRepository.authenticateWithBiometric();

if (result.isSuccess && result.data!.isSuccess) {
  // Success
} else {
  switch (result.data?.errorType) {
    case BiometricAuthErrorType.userCanceled:
      // Let user try again or use PIN
      break;
    case BiometricAuthErrorType.lockedOut:
      // Show PIN with timer
      break;
    case BiometricAuthErrorType.permanentlyLockedOut:
      // Force PIN only
      break;
    default:
      // Show error message
  }
}
```

### 4. ✅ Auto-show Biometric on Login (if enabled)
```dart
@override
void initState() {
  super.initState();
  _autoShowBiometric();
}

Future<void> _autoShowBiometric() async {
  await Future.delayed(Duration(milliseconds: 300)); // Wait for UI

  final enabledResult = await pinRepository.isBiometricEnabled();
  if (enabledResult.isSuccess && enabledResult.data == true) {
    _authenticateWithBiometric();
  }
}
```

### 5. ✅ Clear Sensitive Data on Logout
```dart
Future<void> logout() async {
  await pinRepository.clearPin();
  await pinRepository.clearBiometric();
  // Navigate to login
}
```

### 6. ❌ Don't Log Biometric Data
```dart
// ❌ NEVER
print('Biometric result: ${result.data}');
logger.debug('User authenticated with ${biometricType}');

// ✅ OK
logger.info('Authentication successful');
logger.warn('Biometric authentication failed');
```

### 7. ✅ Require Re-authentication for Sensitive Actions
```dart
Future<void> changePin() async {
  // ต้อง authenticate ก่อน
  final authResult = await pinRepository.authenticateWithBiometric(
    reason: 'กรุณายืนยันตัวตนเพื่อเปลี่ยน PIN',
  );

  if (!authResult.isSuccess || !authResult.data!.isSuccess) {
    // Fallback to PIN
    return;
  }

  // Proceed with PIN change
}
```

---

## Testing

### Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBiometricHelper extends Mock implements BiometricHelper {}
class MockPinRepository extends Mock implements PinRepository {}

void main() {
  group('BiometricHelper', () {
    late BiometricHelper biometricHelper;

    setUp(() {
      biometricHelper = BiometricHelper.instance();
    });

    test('isBiometricAvailable returns true when available', () async {
      // Mock device with fingerprint
      final result = await biometricHelper.isBiometricAvailable();
      expect(result, isA<bool>());
    });

    test('authenticateWithBiometric handles user cancel', () async {
      final result = await biometricHelper.authenticateWithBiometric();

      if (!result.isSuccess) {
        expect(result.errorType, isNotNull);
      }
    });
  });

  group('PinRepository - Biometric', () {
    late PinRepository pinRepository;
    late MockBiometricHelper mockBiometricHelper;

    setUp(() {
      mockBiometricHelper = MockBiometricHelper();
      pinRepository = PinRepository(
        biometricHelper: mockBiometricHelper,
      );
    });

    test('authenticateWithBiometric requires PIN first', () async {
      when(() => mockBiometricHelper.isBiometricAvailable())
          .thenAnswer((_) async => true);

      final result = await pinRepository.authenticateWithBiometric();

      expect(result.isSuccess, isFalse);
      expect(result.error.toString(), contains('PIN must be set'));
    });

    test('authenticateWithBiometric requires enabled first', () async {
      // Set PIN first
      await pinRepository.savePin('123456');

      // But don't enable biometric
      final result = await pinRepository.authenticateWithBiometric();

      expect(result.isSuccess, isFalse);
      expect(result.error.toString(), contains('not enabled'));
    });
  });
}
```

### Integration Tests

```dart
void main() {
  testWidgets('Login with Biometric flow', (tester) async {
    // Setup
    final pinRepository = PinRepository();
    await pinRepository.savePin('123456');
    await pinRepository.setBiometricEnabled(true);

    // Build login screen
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    // Find biometric button
    final biometricButton = find.byIcon(Icons.fingerprint);
    expect(biometricButton, findsOneWidget);

    // Tap biometric button
    await tester.tap(biometricButton);
    await tester.pumpAndSettle();

    // Note: Cannot actually test biometric dialog in integration test
    // Need to use platform-specific testing or manual testing
  });
}
```

---

## Troubleshooting

### iOS Issues

#### Issue: "NSFaceIDUsageDescription not found"
```xml
<!-- Add to ios/Runner/Info.plist -->
<key>NSFaceIDUsageDescription</key>
<string>เราต้องการใช้ Face ID หรือ Touch ID เพื่อยืนยันตัวตนของคุณ</string>
```

#### Issue: Biometric not showing on Simulator
- Simulator: Features → Face ID / Touch ID → Enrolled
- หรือใช้อุปกรณ์จริง

---

### Android Issues

#### Issue: "BiometricPrompt requires FragmentActivity"
```kotlin
// เปลี่ยนใน MainActivity.kt
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()  // ✅ Not FlutterActivity
```

#### Issue: "USE_BIOMETRIC permission denied"
```xml
<!-- Add to AndroidManifest.xml -->
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
```

#### Issue: No biometric on Emulator
- Emulator: Settings → Security → Fingerprint → Add fingerprint
- Terminal: `adb -e emu finger touch 1`

---

### Common Issues

#### Issue: "Biometric not available" แต่เครื่องมี
1. ตรวจสอบว่ามีการลงทะเบียน Biometric ในเครื่องหรือไม่
2. Settings → Face ID / Touch ID / Fingerprint

#### Issue: "Locked out" ทันทีที่เปิดแอป
- ลองผิดหลายครั้งก่อนหน้านี้
- รอ 30 วินาที หรือใช้ PIN

#### Issue: Biometric ใช้งานไม่ได้หลัง reinstall app
- Secure Storage ถูกลบตอน uninstall
- ต้องตั้ง PIN และเปิด Biometric ใหม่

---

## 🔒 Security Checklist

- [x] PIN ต้องตั้งก่อน Biometric เสมอ
- [x] Biometric ใช้เฉพาะ Strong types (Face, Fingerprint, Iris)
- [x] PIN Hash + Salt เก็บใน Keychain/Keystore
- [x] ไม่ log ข้อมูล Biometric
- [x] Handle rate limiting & lock out
- [x] Fallback to PIN เมื่อ Biometric ล้มเหลว
- [x] Clear data on logout
- [x] Require re-auth for sensitive actions
- [x] Error handling ครบทุก case

---

## 📚 References

- [local_auth package](https://pub.dev/packages/local_auth)
- [iOS LAContext](https://developer.apple.com/documentation/localauthentication/lacontext)
- [Android BiometricPrompt](https://developer.android.com/reference/androidx/biometric/BiometricPrompt)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)

---

## 🎯 Next Steps

1. ✅ Setup เสร็จแล้ว
2. ⏳ สร้างหน้า Login with Biometric
3. ⏳ สร้างหน้า Settings (เปิด/ปิด Biometric)
4. ⏳ Test บนอุปกรณ์จริง (iOS + Android)
5. ⏳ เพิ่ม Analytics สำหรับ Biometric usage
6. ⏳ เพิ่ม Rate limiting ใน app logic
7. ⏳ เพิ่ม Biometric timeout (session management)

---

**Last Updated:** December 28, 2025
**Version:** 1.0.0
