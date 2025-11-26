# CHANGELOG
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