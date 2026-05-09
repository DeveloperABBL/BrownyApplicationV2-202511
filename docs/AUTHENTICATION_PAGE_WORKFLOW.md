# Authentication Page — Workflow Context

> อ้างอิง: `lib/feature/authentication/`

---

## Overview

`AuthenticationPage` เป็น Single-Page App ภายในตัวเอง ใช้ `PageView` ควบคุมการไหลระหว่าง Process ทั้งหมด แทนที่จะใช้ `go_router` push/pop แต่ละหน้า ผลคือ ViewModel (`AuthenticationViewModel`) มีชีวิตยาวตลอด flow และเก็บ state ข้ามหน้าได้

---

## File Structure

```
feature/authentication/
├── screen/
│   └── authentication_page.dart     # UI ทั้งหมดอยู่ไฟล์เดียว
├── viewmodel/
│   ├── authentication_viewmodel.dart
│   └── pin_biometric_viewmodel.dart
├── repository/
│   ├── customer_data_repo.dart      # CustomerDataSourceMixin + impl
│   └── otp_data_repo.dart           # OTPDataSourceMixin + impl
├── models/
│   └── otp_model.dart
└── error/
    └── authen_exception.dart
```

---

## Widget Hierarchy

```
AuthenticationPage (StatelessWidget)
└── ChangeNotifierProvider<AuthenticationViewModel>
    └── GestureDetector (ปิด keyboard เมื่อกด outside)
        └── _AuthenticationWidget (StatefulWidget)
            └── Scaffold
                └── LayoutBuilder
                    └── Stack
                        ├── [Layer 1] Gradient background (เต็มหน้าจอ)
                        ├── [Layer 2] Logo + White container โค้งมน (ด้านล่าง 70%)
                        ├── [Layer 3] PageView (NeverScrollableScrollPhysics)
                        │   ├── _LoginWidget
                        │   ├── _SignUpWidget
                        │   ├── _OTPWidget → _OTPContent
                        │   ├── _ForgotPasswordWidget
                        │   ├── _ForgotPasswordOTPWidget → _ForgotPasswordOTPContent
                        │   ├── _ResetPasswordWidget
                        │   ├── _ReferralWidget
                        │   ├── _ChangePasswordWidget
                        │   ├── _ChangePasswordOTPWidget
                        │   └── _ChangePasswordNewPasswordWidget
                        └── [Layer 4] Back button (SafeArea, overlay บนสุด)
```

---

## AuthenProcess Enum — Page Order

PageView render ทุก Widget ตาม enum order เสมอ (lazy-built แต่สร้างพร้อมกัน) การเปลี่ยนหน้าทำผ่าน `PageController` ที่ ViewModel ควบคุม

```dart
enum AuthenProcess {
  login,                    // index 0
  signup,                   // index 1
  signupOTP,                // index 2
  forgotPassword,           // index 3
  forgotPasswordOTP,        // index 4
  forgotPasswordNewPassword,// index 5
  changePassword,           // index 6
  changePasswordOTP,        // index 7
  changePasswordNewPassword,// index 8
  referral,                 // index 9
}
```

---

## Flow Diagrams

### 1. Login (Email/Password)

```
[Login page]
    │ กรอก username + password → กด Login
    ▼
  onLogin() ── API fail ──▶ Error dialog
    │
    │ success
    ▼
CreateAppPinPage (process: create)
```

### 2. Social Login (Google / Facebook / Apple / LINE)

```
[Login page]
    │ กด Social icon
    ▼
socialLogin(type) ── fail ──▶ Error dialog
    │ success
    ├── firstLogin = false ──▶ CreateAppPinPage (process: create)
    │
    └── firstLogin = true
            │
            ▼
        isReferralEnabled()   ← GET /referral/status
            │
            ├── enabled = true  ──▶ goToProcess(referral) ──▶ [Referral flow ↓]
            └── enabled = false ──▶ CreateAppPinPage (isFirstSingup: true, process: create)
```

### 3. Signup

```
[SignUp page]
    │ กรอก username + password + checkbox → กด สมัครสมาชิก
    ▼
onSummitForm() [signup]
    │ checkUsernameExists ── ซ้ำ ──▶ Error dialog
    │ success
    ▼
[SignupOTP page]   ← startOtpTimer() เรียก POST /otp ทันที
    │ กรอก OTP 4 หลัก → auto-submit เมื่อครบ
    ▼
verifyOTP(pin)  ── invalid ──▶ error state ใน Pinput
    │ valid
    ▼
onSummitForm() [signupOTP]  ← POST /customer/register
    │ สำเร็จ → fetchProfile
    ▼
isReferralEnabled()   ← GET /referral/status
    │
    ├── enabled = true  ──▶ goToProcess(referral) ──▶ [Referral flow ↓]
    └── enabled = false ──▶ CreateAppPinPage (isFirstSingup: true, process: create)
```

### 4. Forgot Password

```
[ForgotPassword page]
    │ กรอก email/phone → กด ถัดไป
    ▼
onSummitForm() [forgotPassword]
    │ checkUsernameExists ── ไม่พบ ──▶ Error
    │ success
    ▼
[ForgotPasswordOTP page]   ← startOtpTimer()
    │ กรอก OTP
    ▼
verifyOTP(pin) ── invalid ──▶ error state
    │ valid → auto submit
    ▼
[ResetPassword page]
    │ กรอก password ใหม่ + confirm
    ▼
onSummitForm() [forgotPasswordNewPassword]  ← PATCH /customer/password
    │ success
    ▼
Dialog "เปลี่ยนรหัสผ่านสำเร็จ" → goToProcess(login, animate: false)
```

### 5. Change Password (เข้าจากหน้า Profile)

```
AuthenticationPage.goToPage(process: changePassword)
    │
[ChangePassword page]
    │ กรอก username ปัจจุบัน (ต้องตรงกับ profile.phone หรือ .email)
    ▼
onSummitForm() [changePassword]  ← local validate เท่านั้น
    │ match
    ▼
[ChangePasswordOTP page]   ← startOtpTimer()
    │ กรอก OTP
    ▼
verifyOTP(pin)
    │ valid
    ▼
[ChangePasswordNewPassword page]
    │ กรอก old password + new password
    ▼
onSummitForm() [changePasswordNewPassword]  ← POST /customer/change-password
    │ success
    ▼
Dialog → context.pop() ออกจาก AuthenticationPage
```

### 6. Referral

```
[Referral page]  ← เข้ามาจาก signup หรือ social firstLogin
    │ กรอกเบอร์มือถือเพื่อน → กด ยืนยัน
    ▼
onSummitForm() [referral]
    │ validate ไม่ใช่เบอร์ตัวเอง
    │ POST /referrals
    ├── success ──▶ Dialog "บันทึกชวนเพื่อนเรียบร้อย"
    │               └──▶ CreateAppPinPage (isFirstSingup: true)
    └── error ──▶ error message inline (ไม่เป็น dialog)

    [ปุ่ม Skip]
    └──▶ CreateAppPinPage (isFirstSingup: true, process: create)
```

---

## Widget Base Class Pattern

`_SignUpWidget` เป็น base class ที่ Widget หน้าอื่นๆ extend และ override เฉพาะส่วนที่ต่างกัน:

```
_SignUpWidget (base)
├── _LoginWidget               (override: title, description, submit, forgot, social separator, no checkbox)
├── _OTPContent                (layout แยกออกมา, ไม่ใช้ buildContent() ของ base)
│   └── _ForgotPasswordOTPContent (override: _summitOtp → ไป forgotPasswordNewPassword)
├── _ForgotPasswordWidget      (override: title, description, form fields, submit, no social)
├── _ResetPasswordWidget       (override: form fields, submit, no social)
├── _ReferralWidget            (override: ทุก method เกือบหมด, form = phone only)
├── _ChangePasswordWidget      (override: title, form fields อาจแตกต่าง)
├── _ChangePasswordOTPWidget   (StatefulWidget แยก, ใช้ _OTPContent)
└── _ChangePasswordNewPasswordWidget
```

Methods ที่ override ได้ใน base class:

| Method | หน้าที่ |
|--------|---------|
| `contentTitle()` | หัวเรื่อง |
| `contentDescription()` | คำอธิบาย |
| `listOfFormAuth()` | list ของ field ในฟอร์ม |
| `textFormFieldEmailOrPhone()` | field username |
| `textFormFieldPasswordWithObscure()` | field password |
| `contentCheckboxTermOfPolicy()` | checkbox T&C |
| `contentButtonSummit()` | ปุ่ม submit หลัก |
| `contentButtonForgotPassword()` | ปุ่มลืมรหัส / Skip |
| `contentSocialLoginSeparator()` | เส้นคั่น |
| `contentSocialLogin()` | ปุ่ม Social Login |
| `contentSignUpCheering()` | "ยังไม่มีบัญชี? สมัครเลย" |
| `getFormKey()` | GlobalKey สำหรับ Form |
| `getValidatorEmailOrPhone()` | validator username |
| `getValidatorPassword()` | validator password |

---

## ViewModel Key Methods

```dart
// Navigation
goToProcess(AuthenProcess, {bool animate})  // เปลี่ยนหน้า + cleanup state
goBack()                                    // smart back (บางหน้า override destination)
goNext()                                    // ไปหน้าถัดไปใน enum order

// Form submission (switch ตาม currentProcess)
Future<UiResult<void>> onSummitForm()

// Auth actions
Future<UiResult<LoginCustomerData>> onLogin()
Future<UiResult<LoginCustomerData>> socialLogin(SocialLoginType)
Future<UiResult<bool>> verifyOTP(String otp)

// Referral gate (DONG 2026-05-09)
Future<bool> isReferralEnabled()   // GET /referral/status, fallback = true

// OTP
Future<void> startOtpTimer()       // request OTP + countdown 60s
Future<void> resendOtp()

// Profile
Future<UiResult<ContactResponse>> fetchTermsLink()
```

---

## Referral Gate Logic (เพิ่ม 2026-05-09)

`isReferralEnabled()` ถูกเรียกก่อน navigate ไป `AuthenProcess.referral` เสมอ ใน 2 จุด:

1. **Signup OTP verified** (`_OTPContent._summitOtp`)
2. **Social login firstLogin=true** (`_SignUpWidget._socialLogin`)

Fallback policy: ถ้า API error → ถือว่า `enabled = true` (แสดง referral ตามปกติ) เพื่อไม่ให้ User พลาด feature

---

## Entry Points

```dart
// push หน้านี้จากที่อื่น
AuthenticationPage.goToPage(context, process: AuthenProcess.login)
AuthenticationPage.goToPage(context, process: AuthenProcess.changePassword)

// Guest user พยายาม changePassword/forgotPassword → redirect login อัตโนมัติ
```

---

## OTP Timer Behavior

- เริ่ม countdown 60 วินาที ทันทีที่เข้าหน้า OTP (`addPostFrameCallback`)
- ระหว่าง countdown: แสดง "ขอรหัสใหม่ใน X วินาที"
- หมดเวลา: แสดงปุ่ม "ขอรหัสใหม่"
- กด "ขอรหัสใหม่": `_otpRequestResend = true` → `startOtpTimer()` เรียก API ใหม่ + reset countdown
- DebugMode: ไม่เรียก API จริง แสดง SnackBar "OTP Requested" แทน

---

## Validation System

### SignUp Required Conditions
```dart
enum SignUpRequiredConditions {
  valideEmalOrPhone,     // username field valid
  passwordHasLowercase,  // มีตัวอักษร lowercase
  passwordHasDigit,      // มีตัวเลข
  acceptTermOfPolicy,    // ติ๊ก checkbox
}
```
ปุ่ม Submit เปิดเมื่อ `_validations.isEmpty` (ลบ condition ออกเมื่อ validate ผ่าน)

### Reset Password Conditions
```dart
enum ResetPasswordConditions {
  samePassword,   // password == confirmPassword
  atleastLength,  // ยาว >= 8 ตัว
}
```
แสดงเป็น checklist UI ใน `_ResetPasswordWidget`

---

## Gotchas

- **GlobalKey ซ้ำ**: PageView render ทุก Widget พร้อมกัน ใช้ GlobalKey ต่างกันต่อหน้า (`formKeyLogin`, `formKeySignup`, `formKeyReferral`, `formKeyForgetPasswordUsername`, `formKeyForgetPasswordReset`)
- **OTP Widget แยก State**: `_OTPWidget` เป็น StatefulWidget ห่อ `_OTPContent` เพื่อป้องกัน rebuild จาก keyboard ทำให้ call API OTP ซ้ำ
- **`goToProcess(referral)`**: clear usernameController — ดังนั้น `isReferralEnabled()` ต้องถูกเรียกก่อน `goToProcess(referral)` เสมอ (phone หายหลัง clear)
- **Social Login iOS Facebook**: มี fallback path ดึง token โดยตรงจาก `FacebookAuth.accessToken` เพราะ Firebase มีปัญหากับ iOS
