## 🎯 Popup System with Local Cache

ระบบจัดการ Popup ที่รองรับ:
- ✅ กรอง popup ตามช่วงเวลา (start_date, end_date)
- ✅ กรอง popup ตาม active status
- ✅ กรองตามหน้าที่แสดง (show_on)
- ✅ **Cache local: ไม่แสดง popup ซ้ำในวันเดียวกันเมื่อ user dismiss**
- ✅ รองรับ 3 ภาษา (ไทย, อังกฤษ, จีน)

---

## 📁 ไฟล์ที่เกี่ยวข้อง

### **1. PopupCacheManager**
`lib/core/data/cache/popup_cache_manager.dart`

จัดการ cache ว่า popup ไหนถูก dismiss ไปแล้วในวันนี้

```dart
final cacheManager = PopupCacheManager(AppLocalStorage.instance());

// บันทึกว่า popup ID 1 ถูก dismiss แล้ว
cacheManager.markAsDismissedToday(1);

// ตรวจสอบว่า popup ID 1 ถูก dismiss ไปแล้วหรือยัง
final isDismissed = cacheManager.isDismissedToday(1); // true (ภายในวันเดียวกัน)
```

### **2. HomeRepo with Cache Integration**
`lib/feature/home/repository/home_repo.dart`

```dart
class HomeRepo extends CustomerDataRepo with HomeDataSourceMixin {
  late final PopupCacheManager _popupCache;

  HomeRepo() {
    _popupCache = PopupCacheManager(AppLocalStorage.instance());
  }

  @override
  Future<RepoResult<List<PopupData>>> fetchPopups() async {
    // Auto-filter: active, date range, และไม่ถูก dismiss ในวันนี้
    final activePopups = response.data.where((popup) {
      return popup.isActive &&
          popup.isInDateRange() &&
          !_popupCache.isDismissedToday(popup.id);
    }).toList();
  }

  @override
  void dismissPopupForToday(int popupId) {
    _popupCache.markAsDismissedToday(popupId);
  }
}
```

### **3. PopupDialog Widget**
`lib/core/widgets/popup_dialog.dart`

UI สำหรับแสดง popup พร้อมปุ่ม "ไม่แสดงอีกในวันนี้"

---

## 🚀 การใช้งานใน HomePage

### **ตัวอย่าง: แสดง Popup เมื่อเปิดหน้า Home**

```dart
import 'package:flutter/material.dart';
import 'package:browny_applications_new/core/widgets/popup_dialog.dart';
import 'package:browny_applications_new/feature/home/repository/home_repo.dart';
import 'package:browny_applications_new/core/data/remote/models/response/popup_response.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeRepo _repo = HomeRepo();
  List<PopupData> _homePopups = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAndShowPopups();
  }

  /// 1. Load popups จาก API
  Future<void> _loadAndShowPopups() async {
    setState(() => _isLoading = true);

    try {
      final result = await _repo.fetchPopups();

      if (result.isSuccess) {
        // กรองเฉพาะ popup ที่แสดงในหน้า "home"
        final homePopups = result.data.where((popup) {
          return popup.shouldShowOn('home');
        }).toList();

        setState(() {
          _homePopups = homePopups;
          _isLoading = false;
        });

        // แสดง popup อัตโนมัติ (หลังจาก build เสร็จ)
        if (homePopups.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showPopup(homePopups.first);
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading popups: $e');
    }
  }

  /// 2. แสดง popup dialog
  void _showPopup(PopupData popup) {
    final locale = Localizations.localeOf(context).languageCode;

    PopupDialog.show(
      context: context,
      popup: popup,
      locale: locale,
      repo: _repo,
      onActionPressed: () {
        _handlePopupAction(popup);
      },
      onDismiss: () {
        debugPrint('Popup dismissed');
      },
    );
  }

  /// 3. Handle popup action (เช่น กดปุ่ม CTA)
  void _handlePopupAction(PopupData popup) {
    if (popup.programAction == 'join') {
      // Navigate ไปหน้าที่กำหนด
      if (popup.autoClickTarget == 'washer') {
        Navigator.pushNamed(context, '/washer-program');
      } else if (popup.autoClickTarget == 'bingo') {
        Navigator.pushNamed(context, '/bingo-game');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Home Page'),
                  SizedBox(height: 16),
                  
                  // ปุ่มแสดง popup ใหม่อีกครั้ง (สำหรับ testing)
                  if (_homePopups.isNotEmpty)
                    ElevatedButton(
                      onPressed: () => _showPopup(_homePopups.first),
                      child: Text('แสดง Popup'),
                    ),
                ],
              ),
            ),
    );
  }
}
```

---

## 📋 Popup Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│ 1. User เปิดหน้า Home                                        │
└───────────────┬─────────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. fetchPopups() → API /popups                               │
│    - Filter: active = true                                   │
│    - Filter: อยู่ในช่วงเวลา (start_date - end_date)          │
│    - Filter: ไม่ถูก dismiss ในวันนี้ (check cache)           │
└───────────────┬─────────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. แสดง Popup Dialog                                         │
│    - รูปภาพตามภาษา                                            │
│    - ข้อความ CTA                                             │
│    - ปุ่ม Action                                             │
│    - ปุ่ม "ไม่แสดงอีกในวันนี้"                                │
└───────────────┬─────────────────────────────────────────────┘
                │
         ┌──────┴──────┐
         │             │
         ▼             ▼
┌─────────────────┐ ┌─────────────────────────────────────────┐
│ User กดปุ่ม CTA  │ │ User กด "ไม่แสดงอีกในวันนี้"             │
└────────┬────────┘ └──────────┬──────────────────────────────┘
         │                     │
         ▼                     ▼
┌─────────────────┐ ┌─────────────────────────────────────────┐
│ Handle Action   │ │ dismissPopupForToday(popup.id)          │
│ (Navigate)      │ │ → บันทึก cache: popup_dismissed_1 = "2026-02-12" │
└─────────────────┘ └─────────────────────────────────────────┘
                                │
                                ▼
                ┌─────────────────────────────────────────────┐
                │ ครั้งถ้ดไปในวันนี้                            │
                │ fetchPopups() จะไม่ return popup นี้          │
                └─────────────────────────────────────────────┘
```

---

## 🎨 PopupDialog Features

### **1. รองรับ 3 ภาษา**
```dart
// Locale จาก context
final locale = Localizations.localeOf(context).languageCode;
// 'th' → แสดงข้อความและรูปภาษาไทย
// 'en' → แสดงข้อความและรูปภาษาอังกฤษ
// 'zh' → แสดงข้อความและรูปภาษาจีน
```

### **2. ปุ่ม "ไม่แสดงอีกในวันนี้"**
```dart
TextButton(
  onPressed: () {
    // บันทึกว่าไม่ต้องการแสดงในวันนี้อีก
    repo.dismissPopupForToday(popup.id);
    Navigator.of(context).pop();
  },
  child: Text(_getDontShowTodayText(locale)),
)
```

**ผลลัพธ์:**
- บันทึก `popup_dismissed_1 = "2026-02-12"` ลง Hive
- ครั้งถัดไปในวันนี้ `fetchPopups()` จะไม่ return popup ID 1
- **พอถึงวันใหม่ (2026-02-13)** popup ID 1 จะกลับมาแสดงได้ปกติ

---

## 🧪 Testing Scenarios

### **Scenario 1: แสดง popup ครั้งแรกของวัน**
```dart
// เช้าวันที่ 12 Feb 2026, 08:00
await _repo.fetchPopups();
// → Return [Popup#1] ✅

_showPopup(popup1);
// User กด "ไม่แสดงอีกในวันนี้"
_repo.dismissPopupForToday(1);
```

### **Scenario 2: เปิดหน้า Home อีกครั้งในวันเดียวกัน**
```dart
// ช่วงบ่ายวันที่ 12 Feb 2026, 14:00
await _repo.fetchPopups();
// → Return [] (empty) ❌ เพราะ Popup#1 ถูก dismiss แล้ว
```

### **Scenario 3: เปิดหน้า Home ในวันถัดไป**
```dart
// เช้าวันที่ 13 Feb 2026, 08:00
await _repo.fetchPopups();
// → Return [Popup#1] ✅ (cache หมดอายุแล้ว)
```

### **Scenario 4: Multiple Popups**
```dart
// มี 3 popups ที่ควรแสดงในหน้า home
await _repo.fetchPopups();
// → Return [Popup#1, Popup#2, Popup#3]

// แสดง Popup#1 (user กด dismiss)
_repo.dismissPopupForToday(1);

// แสดง Popup#2 (user กดปุ่ม CTA)
// → ไม่ dismiss, popup#2 จะยังแสดงได้ในวันนี้

// เปิดหน้า Home อีกครั้ง
await _repo.fetchPopups();
// → Return [Popup#2, Popup#3] (ไม่มี Popup#1)
```

---

## 🔧 Advanced Usage

### **1. แสดงหลาย popups ตามลำดับ**
```dart
Future<void> _showPopupsSequentially() async {
  for (final popup in _homePopups) {
    await PopupDialog.show(
      context: context,
      popup: popup,
      locale: locale,
      repo: _repo,
    );
    
    // หน่วงเวลาก่อนแสดง popup ถัดไป
    await Future.delayed(Duration(milliseconds: 500));
  }
}
```

### **2. Log ว่า popup ไหนถูกแสดง**
```dart
void _showPopup(PopupData popup) {
  // Log analytics
  analytics.logEvent(
    name: 'popup_shown',
    parameters: {
      'popup_id': popup.id,
      'popup_name': popup.name,
      'page': 'home',
    },
  );
  
  PopupDialog.show(...);
}
```

### **3. Custom popup ตามเงื่อนไข**
```dart
// แสดงเฉพาะ popup ที่มี specific tag
final filteredPopups = _homePopups.where((popup) {
  return popup.programAction == 'join' && 
         popup.autoClickTarget == 'washer';
}).toList();
```

---

## 📊 Cache Storage Structure

**Hive Box: `browny_preferences`**

```
Key: "popup_dismissed_1"
Value: "2026-02-12"

Key: "popup_dismissed_2"  
Value: "2026-02-12"

Key: "popup_dismissed_3"
Value: "2026-02-11" (หมดอายุแล้ว)
```

**Cache จะถูกเขียนทับอัตโนมัติเมื่อวันใหม่มาถึง**

---

## ✅ Checklist

- [x] สร้าง PopupCacheManager
- [x] Integrate กับ HomeRepo
- [x] สร้าง PopupDialog widget
- [x] ตัวอย่างการใช้งานใน HomePage
- [x] รองรับ 3 ภาษา (th, en, zh)
- [x] Auto-filter popup ที่ถูก dismiss
- [x] Cache หมดอายุอัตโนมัติเมื่อถึงวันใหม่

**พร้อมใช้งานแล้วครับ! 🎉**
