# CHANGELOG
---
### DONG 2026-01-12
* build 3.0.0(21) เป็นตัว update progress ล่าสุด ซึ่งยังไม่ครบใน phase1
  * ที่เล่นได้แล้วจะมี
    - login
    - Register
    - ตั้ง Pin, Biometric
    - ตั้งค่า Profile
    - เติมเงิน
    - Scan QRCode (Scan ติดแล้วแต่ยังไม่มี Process อะไรต่อ)
    - History(เป็น Mockup Data รอ API)

---
### DONG 2026-01-11
- เพิ่มหน้า Wallet
 - Process การ topup, QRCode Display, Slip (Mockup Data)
- เก็บรายละเอียดหน้า ProfilePage
- Process การสมัครสมาชิก
 - หน้าเก็บรายละเอียดหน้า Pin input

---
### DONG 2025-12-02
- Process การสมัครสมาชิก
  - หน้า Pin input (ยังไม่เสร็จ)
  - ปรับ Logic รองรับการสมัครสมาชิกและส่งค่าไปหน้า Pin input (ยังไม่เรียบร้อย)
  - เพิ่ม Wording en, th, zh สำหรับ Process การสมัครสมาชิก
- เพิ่มหน้า ProfilePage (ยังไม่เสร็จ)

---
### DONG 2025-11-26
- เพิ่ม Logic การ Login ด้วย User ที่มีอยู่ในระบบแล้ว
  - fetch data จาก API เพิ่มแสดงยอดเงินคงเหลือ, คอยน์ ในหน้า home
  - login และ caching ข้อมูล User ที่ login ได้สำเร็จ
  - handle การ Login ด้วย case error ต่างๆ ที่อาจเกิดขึ้น
- เพิ่ม Logic การดึงข้อมูล customer ที่เคย Login เอาไว้แล้วมาใช้งานต่อ

---
### DONG 2025-11-19
- ขึ้นหน้า HomePage
  - ส่วนการแสดง TP Wallet, Coin, การ Login
- Authen process
  - login ```(on develop)```
  - sign up ```(draft)```
  - forgot password ```(draft)```

---
### DONG 2025-11-11
- วางโครงสร้าง Project
  - **ลบ platform ที่ไม่รองรับ windows, linux**
- เพิ่ม BottomNavigation Design Browny
- เพิ่มหน้า OnBoardingPage
- ขึ้นหน้า HomePage (ยังไม่เสร็จ)