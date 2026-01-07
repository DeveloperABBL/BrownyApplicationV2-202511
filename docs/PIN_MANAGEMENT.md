# PIN Management System

## Overview
ระบบจัดการ PIN สำหรับความปลอดภัยของแอปพลิเคชัน ใช้ `flutter_secure_storage` เก็บ PIN แบบ Hashed + Salt

## Architecture

```
├── lib/core/data/cache/
│   ├── app_local_storage.dart          # Hive storage (settings, preferences)
│   └── app_local_storage_secure.dart   # Secure storage (PIN, sensitive data)
│
├── lib/core/data/repo/
│   └── app_repository.dart              # Base repository (access both storage)
│
├── lib/feature/authentication/
│   ├── repository/
│   │   └── pin_repository.dart          # PIN business logic
│   ├── viewmodel/
│   │   └── pin_viewmodel.dart           # State management
│   └── screen/
│       └── create_app_pin_page.dart     # UI for creating PIN
```

## Security Features

### 1. PIN Hashing (SHA-256 + Salt)
```dart
// ไม่เก็บ PIN จริง เก็บเฉพาะ Hash
String pin = "123456";
String salt = _generateSalt(); // Random 32 chars
String hashedPin = _hashPin(pin, salt); // SHA-256(pin + salt)

// บันทึกใน Secure Storage
await secureStorage.write(key: 'app_pin_hash', value: hashedPin);
await secureStorage.write(key: 'app_pin_salt', value: salt);
```

### 2. Secure Storage (Keychain/Keystore)
- **iOS**: ใช้ Keychain (Hardware-backed encryption)
- **Android**: ใช้ Keystore (EncryptedSharedPreferences)

### 3. Validation
```dart
Future<bool> verifyPin(String pin) async {
  String? storedHash = await readSecure(key: 'app_pin_hash');
  String? salt = await readSecure(key: 'app_pin_salt');
  
  String hashedPin = _hashPin(pin, salt);
  return hashedPin == storedHash; // เทียบ Hash
}
```

## Usage

### 1. Setup Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.2.4
  crypto: ^3.0.7
  provider: ^6.1.2
```

### 2. Create PIN

```dart
import 'package:provider/provider.dart';
import 'package:browny_applications_new/feature/authentication/repository/pin_repository.dart';
import 'package:browny_applications_new/feature/authentication/viewmodel/pin_viewmodel.dart';
import 'package:browny_applications_new/feature/authentication/screen/create_app_pin_page.dart';

// Navigate to Create PIN Page
context.pushNamed(CreateAppPinPage.pageName);

// หรือใช้ Provider แบบ manual
ChangeNotifierProvider(
  create: (_) => PinViewModel(repository: PinRepository()),
  child: CreateAppPinPage(),
);
```

### 3. Verify PIN

```dart
// ใน ViewModel
final viewModel = context.read<PinViewModel>();
bool isValid = await viewModel.verifyPin('123456');

if (isValid) {
  // PIN ถูกต้อง → ให้เข้าแอปได้
  print('PIN correct!');
} else {
  // PIN ไม่ถูกต้อง → แสดง error
  print('Invalid PIN');
}
```

### 4. Check if PIN exists

```dart
final viewModel = context.read<PinViewModel>();
bool hasPin = await viewModel.hasPin();

if (hasPin) {
  // มี PIN แล้ว → ให้กรอก PIN
  Navigator.pushNamed(context, '/verify_pin');
} else {
  // ยังไม่มี PIN → ให้สร้าง PIN
  Navigator.pushNamed(context, '/create_pin');
}
```

### 5. Clear PIN (Logout)

```dart
final repository = PinRepository();
await repository.clearPin();
```

## Repository API

### PinRepository Methods

```dart
class PinRepository extends AppRepository with PinDataSourceMixin {
  // บันทึก PIN (Hash + Salt)
  Future<RepoResult<bool>> savePin(String pin);
  
  // ตรวจสอบ PIN
  Future<RepoResult<bool>> verifyPin(String pin);
  
  // ตรวจสอบว่ามี PIN หรือยัง
  Future<RepoResult<bool>> hasPin();
  
  // ลบ PIN
  Future<RepoResult<bool>> clearPin();
  
  // เปิดใช้งาน Biometric (สำหรับอนาคต)
  Future<RepoResult<bool>> setBiometricEnabled(bool enabled);
  Future<RepoResult<bool>> isBiometricEnabled();
  Future<RepoResult<bool>> clearBiometric();
}
```

## ViewModel API

### PinViewModel State

```dart
class PinViewModel extends ChangeNotifier {
  // State
  String pin;              // PIN ขั้นตอนที่ 1
  String confirmPin;       // PIN ขั้นตอนที่ 2 (ยืนยัน)
  int step;                // ขั้นตอน (1 หรือ 2)
  bool isLoading;          // กำลังบันทึก
  String? errorMessage;    // ข้อผิดพลาด
  
  // Methods
  void addDigit(String digit);    // เพิ่มตัวเลข
  void removeDigit();             // ลบตัวเลข
  void reset();                   // Reset state
  Future<bool> verifyPin(String pin);
  Future<bool> hasPin();
}
```

## UI Flow

### Create PIN Flow

```
Step 1: สร้างรหัส PIN 6 หลัก
  ↓ (กรอกครบ 6 หลัก)
Step 2: ยืนยันรหัส PIN
  ↓ (PIN ตรงกัน)
Save to Secure Storage (Hashed + Salt)
  ↓
Success Dialog
  ↓
กลับไปหน้าก่อน
```

### Error Handling

```dart
// PIN ไม่ตรงกัน
if (pin != confirmPin) {
  errorMessage = 'PIN ไม่ตรงกัน กรุณาลองใหม่';
  step = 1;  // กลับไปขั้นตอนที่ 1
}

// PIN format ไม่ถูกต้อง (ต้องเป็นตัวเลข 6 หลัก)
if (!_isValidPin(pin)) {
  return RepoResult.error(
    error: Exception('PIN must be 6 digits'),
  );
}
```

## Best Practices

### 1. Never Log PIN
```dart
// ❌ ห้าม
print('User PIN: $pin');
debugPrint('PIN: $pin');

// ✅ ใช้
print('PIN length: ${pin.length}');
print('PIN created successfully');
```

### 2. Clear PIN on Logout
```dart
Future<void> logout() async {
  final pinRepo = PinRepository();
  await pinRepo.clearPin();
  await pinRepo.clearBiometric();
  
  // Clear other user data...
}
```

### 3. Rate Limiting (TODO)
```dart
// จำกัดจำนวนครั้งที่พยายาม
int failedAttempts = 0;
const maxAttempts = 5;

Future<bool> verifyPin(String pin) async {
  bool isValid = await repository.verifyPin(pin);
  
  if (!isValid) {
    failedAttempts++;
    if (failedAttempts >= maxAttempts) {
      // Lock app for 5 minutes
      await lockApp(Duration(minutes: 5));
    }
  } else {
    failedAttempts = 0;
  }
  
  return isValid;
}
```

### 4. Biometric Integration (Future)
```dart
// ใช้ local_auth package
import 'package:local_auth/local_auth.dart';

Future<bool> authenticateWithBiometric() async {
  final auth = LocalAuthentication();
  
  bool canCheckBiometrics = await auth.canCheckBiometrics;
  if (!canCheckBiometrics) return false;
  
  bool authenticated = await auth.authenticate(
    localizedReason: 'ยืนยันตัวตนเพื่อเข้าแอป',
    options: AuthenticationOptions(
      biometricOnly: true,
    ),
  );
  
  return authenticated;
}
```

## Storage Keys

```dart
// AppLocalStorageSecure keys
static const String _pinHashKey = 'app_pin_hash';
static const String _pinSaltKey = 'app_pin_salt';
static const String _biometricEnabledKey = 'biometric_enabled';
```

## Testing

```dart
void main() {
  group('PinRepository Tests', () {
    late PinRepository repository;
    
    setUp(() {
      repository = PinRepository();
    });
    
    test('Save and verify PIN', () async {
      // Save PIN
      final saveResult = await repository.savePin('123456');
      expect(saveResult.isSuccess, true);
      
      // Verify correct PIN
      final verifyResult = await repository.verifyPin('123456');
      expect(verifyResult.data, true);
      
      // Verify incorrect PIN
      final wrongResult = await repository.verifyPin('000000');
      expect(wrongResult.data, false);
    });
    
    test('Has PIN check', () async {
      // Before saving
      final beforeResult = await repository.hasPin();
      expect(beforeResult.data, false);
      
      // After saving
      await repository.savePin('123456');
      final afterResult = await repository.hasPin();
      expect(afterResult.data, true);
    });
    
    test('Clear PIN', () async {
      await repository.savePin('123456');
      await repository.clearPin();
      
      final hasPinResult = await repository.hasPin();
      expect(hasPinResult.data, false);
    });
  });
}
```

## Troubleshooting

### Issue: "Duplicate GlobalKey detected"
❌ ห้ามใช้ GlobalKey ใน PageView
✅ ใช้ State management (Provider) แทน

### Issue: "PIN not saving"
ตรวจสอบ:
1. ติดตั้ง flutter_secure_storage แล้วหรือยัง
2. iOS: ตั้งค่า Keychain Sharing ใน Xcode
3. Android: minSdkVersion >= 18

### Issue: "Can't access Secure Storage"
```dart
// Debug mode
try {
  await secureStorage.savePin('123456');
} catch (e) {
  print('Error: $e');
  // Check permissions, Keychain settings
}
```

## Future Enhancements

- [ ] Biometric authentication (Face ID, Touch ID)
- [ ] PIN timeout (ให้กรอกใหม่หลังแอปปิด X นาที)
- [ ] Rate limiting (Lock app หลังพยายาม N ครั้ง)
- [ ] PIN strength indicator
- [ ] PIN recovery via email/SMS
- [ ] Multiple PIN profiles (User PIN, Admin PIN)
