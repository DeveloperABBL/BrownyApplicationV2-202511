# 🔒 PIN Security Solutions - แนวทางแก้ไข APP_KEY ให้ secure มากขึ้น

## ⚠️ ปัญหาเดิม: Hardcoded APP_KEY

```dart
// ❌ อันตราย! APP_KEY อยู่ใน source code
static const String _appKey = 'base64:YOUR_LARAVEL_APP_KEY_HERE';
```

**ความเสี่ยง:**
- Attacker decompile app → ได้ APP_KEY
- Commit ลง git → ถูก scan โดย bots
- ไม่สามารถเปลี่ยน key ได้ง่าย

---

## ✅ Level 1: Environment Config (✅ Implemented)

### **Security Level:** ⭐⭐ (พื้นฐาน)

**What we did:**
```dart
// lib/core/env/app_evnironment.dart
abstract class AppEvnironment extends ChangeNotifier {
  /// Laravel APP_KEY สำหรับ decrypt PIN ciphertext
  String get laravelAppKey;
}

// lib/core/env/dev_environment.dart
@override
String get laravelAppKey {
  return const String.fromEnvironment(
    'LARAVEL_APP_KEY',
    defaultValue: 'base64:YOUR_DEV_LARAVEL_APP_KEY_HERE',
  );
}

// lib/feature/authentication/viewmodel/pin_biometric_viewmodel.dart
// ดึง APP_KEY จาก AppEnvironment
final env = context.read<AppEvnironment>();
final appKey = env.laravelAppKey;
```

### **วิธีใช้งาน:**

**Option A: ใช้ --dart-define (แนะนำ)**
```bash
# Build with environment variable
flutter build apk --dart-define=LARAVEL_APP_KEY=base64:xrjcblphHL0JGPclO/kiBDSXVm0dnw4i+x6FLBV2I/s=

# Run with environment variable
flutter run --dart-define=LARAVEL_APP_KEY=base64:xrjcblphHL0JGPclO/kiBDSXVm0dnw4i+x6FLBV2I/s=
```

**Option B: ใช้ flutter_dotenv**
```yaml
# pubspec.yaml
dependencies:
  flutter_dotenv: ^5.1.0

assets:
  - .env
```

```bash
# .env (Don't commit this file!)
LARAVEL_APP_KEY=base64:xrjcblphHL0JGPclO/kiBDSXVm0dnw4i+x6FLBV2I/s=
```

```dart
// main.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

// dev_environment.dart
@override
String get laravelAppKey {
  return dotenv.env['LARAVEL_APP_KEY'] ?? 'default_key';
}
```

### **ข้อดี:**
- ✅ APP_KEY ไม่อยู่ใน source code
- ✅ แต่ละ environment มี key ต่างกัน (dev/staging/prod)
- ✅ ไม่ commit .env file ลง git

### **ข้อเสีย:**
- ⚠️ KEY ยังอยู่ใน compiled app (decompile ได้)
- ⚠️ ต้องระวังเรื่อง .gitignore

---

## ✅ Level 2: Firebase Remote Config

### **Security Level:** ⭐⭐⭐ (ดีขึ้น)

**Concept:** เก็บ APP_KEY บน Firebase Remote Config → fetch runtime

```yaml
# pubspec.yaml
dependencies:
  firebase_remote_config: ^4.3.0
```

```dart
// lib/core/env/dev_environment.dart
class DevEnvironment extends AppEvnironment {
  String? _cachedLaravelAppKey;

  @override
  Future<void> loadEnv() async {
    // ... existing code ...

    // Fetch APP_KEY from Firebase Remote Config
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    
    await remoteConfig.fetchAndActivate();
    _cachedLaravelAppKey = remoteConfig.getString('laravel_app_key');
  }

  @override
  String get laravelAppKey {
    return _cachedLaravelAppKey ?? 'fallback_key';
  }
}
```

### **Firebase Console Setup:**
1. ไปที่ Firebase Console → Remote Config
2. เพิ่ม parameter: `laravel_app_key`
3. Set value: `base64:xrjcblphHL0JGPclO/kiBDSXVm0dnw4i+x6FLBV2I/s=`
4. Publish

### **ข้อดี:**
- ✅ KEY ไม่อยู่ใน app binary
- ✅ เปลี่ยน KEY ได้ทันทีโดยไม่ต้อง release app ใหม่
- ✅ A/B testing ได้ (key rotation)

### **ข้อเสีย:**
- ⚠️ ต้องมี internet ครั้งแรก
- ⚠️ Man-in-the-middle attack ได้ถ้าไม่ใช้ SSL pinning
- ⚠️ KEY ยังถูก cache ใน memory (dump memory ได้)

---

## ✅ Level 3: Native Keychain/Keystore

### **Security Level:** ⭐⭐⭐⭐ (ดี)

**Concept:** เก็บ APP_KEY ใน iOS Keychain / Android Keystore

```yaml
# pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.0.0  # Already have this!
```

```dart
// lib/core/env/dev_environment.dart
class DevEnvironment extends AppEvnironment {
  final _secureStorage = FlutterSecureStorage();
  String? _cachedLaravelAppKey;

  @override
  Future<void> loadEnv() async {
    // ... existing code ...

    // Try to read from secure storage
    _cachedLaravelAppKey = await _secureStorage.read(
      key: 'laravel_app_key',
    );

    // If not exists, fetch from server and save
    if (_cachedLaravelAppKey == null) {
      _cachedLaravelAppKey = await _fetchAppKeyFromServer();
      
      if (_cachedLaravelAppKey != null) {
        await _secureStorage.write(
          key: 'laravel_app_key',
          value: _cachedLaravelAppKey,
        );
      }
    }
  }

  Future<String?> _fetchAppKeyFromServer() async {
    try {
      // Call API to get APP_KEY (requires authentication)
      // final response = await AppClient.instance().getAppKey();
      // return response.data.appKey;
      return null; // TODO: Implement
    } catch (e) {
      return null;
    }
  }

  @override
  String get laravelAppKey {
    return _cachedLaravelAppKey ?? 'fallback_key';
  }
}
```

### **ข้อดี:**
- ✅ KEY เก็บใน hardware-backed storage (Secure Enclave/TEE)
- ✅ ปลอดภัยมากจาก root/jailbreak
- ✅ Key rotation ทำได้ง่าย

### **ข้อเสีย:**
- ⚠️ ต้องมี API สำหรับ fetch APP_KEY
- ⚠️ ยังต้องมี fallback key

---

## ⭐ Level 4: Backend Proxy (Most Secure - แนะนำที่สุด!)

### **Security Level:** ⭐⭐⭐⭐⭐ (ปลอดภัยที่สุด)

**Concept:** ไม่เก็บ APP_KEY ฝั่ง client เลย → ให้ backend decrypt แทน

### **Architecture:**

```
[Mobile App] → [Backend Proxy] → [Laravel API]
     ↓                ↓                ↓
  No KEY      Has APP_KEY      Return PIN
```

### **Implementation:**

**1. เพิ่ม API บน Backend Proxy:**

```php
// routes/api.php
Route::post('/proxy/decrypt-pin', [ProxyController::class, 'decryptPin'])
    ->middleware('auth:sanctum');
```

```php
// app/Http/Controllers/ProxyController.php
class ProxyController extends Controller
{
    public function decryptPin(Request $request)
    {
        $request->validate([
            'ciphertext' => 'required|string',
        ]);

        try {
            // Decrypt ฝั่ง backend ที่มี APP_KEY
            $encrypter = new Encrypter(
                base64_decode(substr(config('app.key'), 7)),
                'AES-256-CBC'
            );
            
            $decrypted = $encrypter->decrypt($request->ciphertext);
            
            return response()->json([
                'success' => true,
                'pin' => $decrypted,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Decryption failed',
            ], 400);
        }
    }
}
```

**2. เพิ่ม API Client ฝั่ง Mobile:**

```dart
// lib/core/data/remote/app_client.dart
@POST('/proxy/decrypt-pin')
Future<HttpResponse<DecryptPinResponse>> decryptPin(
  @Body() DecryptPinRequest request,
);
```

```dart
// lib/core/data/remote/models/request/decrypt_pin_request.dart
@JsonSerializable()
class DecryptPinRequest {
  final String ciphertext;

  DecryptPinRequest({required this.ciphertext});
  
  factory DecryptPinRequest.fromJson(Map<String, dynamic> json) =>
      _$DecryptPinRequestFromJson(json);
  Map<String, dynamic> toJson() => _$DecryptPinRequestToJson(this);
}
```

```dart
// lib/core/data/remote/models/response/decrypt_pin_response.dart
@JsonSerializable()
class DecryptPinResponse {
  final bool success;
  final String? pin;
  final String? error;

  DecryptPinResponse({
    required this.success,
    this.pin,
    this.error,
  });
  
  factory DecryptPinResponse.fromJson(Map<String, dynamic> json) =>
      _$DecryptPinResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DecryptPinResponseToJson(this);
}
```

**3. ปรับ Repository:**

```dart
// lib/feature/authentication/repository/pin_biometric_repository.dart
@override
Future<RepoResult<Map<String, String?>>> getPinFromServer({
  required String customerId,
}) async {
  try {
    // 1. เรียก API getPin
    final response = await requireRemote.getPin(customerId);
    
    if (!response.isSuccessful) {
      return RepoResult.error(
        error: Exception('Failed to get PIN from server'),
      );
    }

    final ciphertext = response.data.ciphertext;

    // 2. เรียก Backend Proxy เพื่อ decrypt
    final decryptRequest = DecryptPinRequest(ciphertext: ciphertext!);
    final decryptResponse = await requireRemote.decryptPin(decryptRequest);

    if (!decryptResponse.isSuccessful || decryptResponse.data.pin == null) {
      return RepoResult.error(
        error: Exception('Failed to decrypt PIN'),
      );
    }

    // 3. Return PIN ที่ decrypt แล้ว + ciphertext
    return RepoResult.success(
      data: {
        'pin': decryptResponse.data.pin,
        'ciphertext': ciphertext,
        'cipher': response.data.cipher,
      },
    );
  } catch (e) {
    return RepoResult.error(error: Exception(e.toString()));
  }
}
```

**4. ปรับ ViewModel:**

```dart
// lib/feature/authentication/viewmodel/pin_biometric_viewmodel.dart
Future<bool> getPinFromServer() async {
  try {
    // ... existing code ...

    // 1. ดึง PIN จาก server (ตอนนี้ backend จะ decrypt ให้แล้ว)
    final result = await _repository.getPinFromServer(customerId: customerId);

    if (!result.isSuccess) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final decryptedPin = result.data['pin'];  // มี PIN จริงแล้ว ไม่ต้อง decrypt
    final ciphertext = result.data['ciphertext'];
    final cipher = result.data['cipher'];

    // 2. ถ้าไม่มี PIN แสดงว่าไม่มี PIN
    if (decryptedPin == null || decryptedPin.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // 3. บันทึก PIN จริงลง secure storage
    await _repository.requireSecureStorage.savePin(
      decryptedPin,
      ciphertext: ciphertext,
      cipherMethod: cipher,
    );

    _isLoading = false;
    notifyListeners();
    return true;
  } catch (e) {
    // ... error handling ...
  }
}
```

### **ข้อดี:**
- ✅✅ ไม่มี APP_KEY ฝั่ง client เลย
- ✅✅ Attacker decompile app ได้แค่ API endpoint
- ✅✅ Key rotation ง่าย (เปลี่ยนฝั่ง backend)
- ✅✅ Centralized security control
- ✅✅ สามารถ log/monitor decrypt requests ได้

### **ข้อเสีย:**
- ⚠️ ต้องมี internet เสมอ (แต่ getPinFromServer ก็ต้อง network อยู่แล้ว)
- ⚠️ เพิ่ม load บน backend
- ⚠️ Latency เพิ่มขึ้นเล็กน้อย (1 extra API call)

---

## ✅ Level 5: Hardware Security Module (HSM)

### **Security Level:** ⭐⭐⭐⭐⭐⭐ (Enterprise Grade)

**Concept:** เก็บ APP_KEY ใน HSM (AWS CloudHSM, Google Cloud HSM)

**สำหรับ enterprise ที่ต้องการ compliance:**
- PCI-DSS Level 1
- HIPAA
- SOC 2 Type II

**Implementation:** ซับซ้อนและมีค่าใช้จ่ายสูง - ไม่แนะนำสำหรับ app ทั่วไป

---

## 📊 เปรียบเทียบแนวทาง

| Level | Security | Complexity | Cost | แนะนำสำหรับ |
|-------|----------|------------|------|-------------|
| 1. Environment Config | ⭐⭐ | ต่ำ | ฟรี | Development/Testing |
| 2. Remote Config | ⭐⭐⭐ | กลาง | ต่ำ | Small-Medium Apps |
| 3. Native Keychain | ⭐⭐⭐⭐ | กลาง | ต่ำ | Medium Apps |
| 4. Backend Proxy | ⭐⭐⭐⭐⭐ | กลาง | กลาง | **Production (แนะนำ!)** |
| 5. HSM | ⭐⭐⭐⭐⭐⭐ | สูง | สูงมาก | Enterprise/Banking |

---

## 🎯 คำแนะนำ

### สำหรับ Development: Level 1 ✅
- ใช้ `--dart-define` หรือ `flutter_dotenv`
- เซ็ตอัพง่าย test ง่าย

### สำหรับ Production: Level 4 ⭐ (แนะนำ!)
- **Backend Proxy Approach**
- ปลอดภัยที่สุด คุ้มค่าที่สุด
- ไม่มี APP_KEY ฝั่ง client เลย

### Hybrid Approach (ทางเลือก):
```
1. ใช้ Backend Proxy เป็นหลัก (Level 4)
2. มี Native Keychain เป็น fallback (Level 3)
3. มี Remote Config สำหรับ config อื่นๆ (Level 2)
```

---

## ✅ TODO Checklist

- [x] **Level 1: Environment Config** (✅ Implemented)
  - [x] เพิ่ม `laravelAppKey` ใน AppEvnironment
  - [x] แก้ไข PinBiometricViewModel ให้ใช้จาก Environment
  - [ ] ตั้งค่า `--dart-define` ใน CI/CD
  - [ ] เพิ่ม `.env` ใน `.gitignore`

- [ ] **Level 4: Backend Proxy** (🎯 แนะนำต่อไป)
  - [ ] สร้าง API `/proxy/decrypt-pin` บน backend
  - [ ] สร้าง DecryptPinRequest/Response models
  - [ ] แก้ไข Repository ให้เรียก decrypt API
  - [ ] ลบ PinDecryptionUtil ออก (ไม่ต้องใช้แล้ว)
  - [ ] Test flow ทั้งหมด

---

## 🔐 Best Practices

1. **Never commit secrets to git**
   ```bash
   # .gitignore
   .env
   *.env
   **/google-services.json
   **/GoogleService-Info.plist
   ```

2. **Use different keys per environment**
   ```
   DEV:     base64:dev_key_xyz...
   STAGING: base64:staging_key_abc...
   PROD:    base64:prod_key_123...
   ```

3. **Rotate keys regularly**
   - Every 90 days
   - After security incident
   - When team member leaves

4. **Monitor decrypt failures**
   ```dart
   // Log to analytics
   Analytics.logError('PIN_DECRYPT_FAILED', {
     'customer_id': customerId,
     'error': e.toString(),
     'timestamp': DateTime.now().toIso8601String(),
   });
   ```

5. **Have a key rotation plan**
   - Old keys ต้อง work ได้อีก 30 days
   - Gradual migration to new key
   - Notify users if needed

---

## 📚 References

- [Flutter Environment Variables](https://docs.flutter.dev/deployment/flavors)
- [Firebase Remote Config](https://firebase.google.com/docs/remote-config)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)

---

## 🆘 Need Help?

ถ้ามีคำถามหรือต้องการคำแนะนำเพิ่มเติม:
1. Check docs/PIN_TEST_CASES.md
2. Review existing implementation
3. Contact security team
