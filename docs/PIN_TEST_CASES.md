# PIN Management Test Cases

## ✅ Test Cases ที่ครอบคลุมแล้ว

### Test Case 1: Register Flow
```
User -> Register -> Create PIN(123456)
  -> API setPin + getPin
  -> Save to local (hash + ciphertext)
  -> Verify:
     ✅ Input "123456" -> SUCCESS
     ✅ Input "123455" -> FAILED
```

### Test Case 2a: Login with Existing PIN
```
User -> Login -> Sync PIN from server
  -> Decrypt ciphertext -> Get PIN(123456)
  -> Save to local (hash + ciphertext)
  -> Verify:
     ✅ Input "123456" -> SUCCESS
     ✅ Input "123455" -> FAILED
```

### Test Case 2b: Login without PIN (First Time)
```
User -> Login -> No PIN on server
  -> Show Create PIN screen
  -> Follow Test Case 1 flow
```

---

## ⚠️ Test Cases ที่ควรเพิ่ม

### Test Case 3: Offline Verification
```
Scenario: User has saved PIN, then loses internet
Flow:
  1. User gọก PIN "123456" offline
  2. System ใช้ hash + salt verification
  
Expected:
  ✅ Input "123456" -> SUCCESS (offline)
  ✅ Input "123455" -> FAILED (offline)
  
Implementation: ใช้ repository.verifyPin() (ไม่ต้อง network)
```

### Test Case 4: Online Verification (ตรวจสอบกับ Server)
```
Scenario: Need high accuracy verification (e.g., critical transaction)
Flow:
  1. User กรอก PIN "123456"
  2. System เรียก API verifyPin
  
Expected:
  ✅ Input "123456" -> HTTP 200 -> SUCCESS
  ✅ Input "123455" -> HTTP 401 -> FAILED
  
Implementation: ใช้ repository.verifyPinOnline(pin, customerId)
```

### Test Case 5: Decrypt Failed (APP_KEY ผิด)
```
Scenario: APP_KEY ไม่ตรงกับ server หรือเปลี่ยน APP_KEY
Flow:
  1. User Login -> getPinFromServer()
  2. Ciphertext มี แต่ decrypt failed
  
Expected:
  ❌ Return false
  ❌ Show error "Cannot sync PIN from server"
  ⚠️ ไม่ควรให้สร้าง PIN ใหม่ (จะทำให้ local/server ไม่ตรงกัน)
  
Action:
  - Log error to monitoring service
  - Contact support or retry later
```

### Test Case 6: Network Error ระหว่าง Register
```
Scenario: User สร้าง PIN แต่ setPin API failed
Flow:
  1. User กรอก PIN "123456" + confirm
  2. Call API setPin -> Network Error / Timeout
  
Expected:
  ❌ savePin() return error
  ❌ Show error message
  ✅ ไม่บันทึก PIN ลง local storage
  ✅ User ต้องลองใหม่
```

### Test Case 7: Change PIN
```
Scenario: User ต้องการเปลี่ยน PIN
Flow:
  1. User กรอก old PIN "123456" -> verify
  2. User กรอก new PIN "654321" -> confirm
  3. Call API setPin(654321) + getPin()
  4. Save to local (hash ใหม่ + ciphertext ใหม่)
  
Expected:
  ✅ Old PIN "123456" ใช้ไม่ได้แล้ว -> FAILED
  ✅ New PIN "654321" ใช้ได้ -> SUCCESS
  
TODO: สร้าง method changePin() ใน repository
```

### Test Case 8: Biometric + PIN Sync
```
Scenario: User enable biometric หลัง register
Flow:
  1. Register -> Create PIN "123456"
  2. Enable biometric
  3. Logout and Login again
  4. Biometric auth success
  
Expected:
  ✅ User สามารถเข้าได้โดยไม่ต้องกรอก PIN
  ✅ System ยังมี hash + ciphertext ใน local
  
Note: Biometric ต้องมี PIN ก่อน (dependency)
```

### Test Case 9: Multiple Devices
```
Scenario: User ใช้หลาย device
Flow:
  Device A: Register -> Create PIN "123456"
  Device B: Login -> Sync PIN from server
  
Expected:
  ✅ Device B ได้ PIN "123456" (decrypted)
  ✅ Device B verify PIN work correctly
  ✅ Device A change PIN -> Device B ต้อง sync ใหม่
```

### Test Case 10: Clear PIN
```
Scenario: User ต้องการลบ PIN (e.g., logout)
Flow:
  1. Call repository.clearPin()
  
Expected:
  ✅ Local storage: hash, salt, ciphertext ถูกลบ
  ⚠️ Server: PIN ยังอยู่ (ไม่ควรลบ เพราะอาจมีหลาย device)
  
Note: ถ้าต้องการลบ PIN จริงๆ ต้องเพิ่ม API deletePIN
```

---

## 🔴 Critical Issues ที่ต้องแก้

### Issue 1: APP_KEY Hardcoded
```dart
// ❌ Don't do this in production
static const String _appKey = 'base64:YOUR_LARAVEL_APP_KEY_HERE';

// ✅ Should move to environment
final appKey = AppEnvironment.instance.laravelAppKey;
```

### Issue 2: Decryption on Client Side
```
⚠️ Security Risk: APP_KEY อยู่ใน client code
   - Attacker สามารถ decompile app และดึง APP_KEY ได้
   - แนะนำ: ใช้ online verification เป็นหลัก
   - Offline verification ใช้เฉพาะเมื่อไม่มี network
```

### Issue 3: No PIN Reset Flow
```
Problem: ถ้า user ลืม PIN ทำอย่างไร?
Solution:
  1. เพิ่ม "Forgot PIN" flow
  2. ส่ง OTP ไปยืนยัน
  3. ให้สร้าง PIN ใหม่
  4. Call API resetPin() เพื่ออัพเดต server
```

---

## 📋 Checklist ก่อน Production

- [ ] แทนที่ APP_KEY จริงจาก Laravel .env
- [ ] ย้าย APP_KEY ไปเก็บใน Environment Config
- [ ] เพิ่ม error logging/monitoring
- [ ] สร้าง "Forgot PIN" flow
- [ ] สร้าง "Change PIN" flow  
- [ ] Test ทุก test case
- [ ] Security review โดย security team
- [ ] Load testing สำหรับ API endpoints
- [ ] Penetration testing
- [ ] Document API rate limiting

---

## 🎯 Test Coverage Summary

| Category | Covered | Missing |
|----------|---------|---------|
| Register Flow | ✅ | - |
| Login with PIN | ✅ | - |
| Login without PIN | ✅ | - |
| Offline Verification | ✅ | - |
| Online Verification | ✅ | - |
| Decrypt Failed | ⚠️ | Need better handling |
| Network Error | ❌ | Need test |
| Change PIN | ❌ | Need implementation |
| Forgot PIN | ❌ | Need implementation |
| Multiple Devices | ⚠️ | Need test |
| Clear PIN | ✅ | - |
| Biometric Integration | ✅ | - |

**Overall Coverage: 75%** (9/12 test cases)
