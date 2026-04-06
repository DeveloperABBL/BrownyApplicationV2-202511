# Live Activity — แผนงาน Browny Machine Status

## Overview

แสดงสถานะเครื่องซักอบ (ซัก/อบ) แบบ real-time บน Lock Screen และ Dynamic Island  
ผ่าน [live_activities](https://pub.dev/packages/live_activities) package (ActivityKit iOS 16.1+)

---

## Architecture

```
Flutter App (Dart)                     iOS (Swift)
─────────────────                     ──────────────────────────
LaundryLiveActivityService             BrownyLiveActivity (Widget Extension)
  └─ LiveActivities plugin  ──────►   BrownyMachineActivityAttributes.swift
       (App Group bridge)              BrownyLiveActivityView.swift
                                       BrownyLiveActivityBundle.swift
```

### Data Flow
```
MachineTransactionViewmodel
  │  remainingDurationNotifier
  │  totalDurationInSeconds
  │  machineDetailNotifier
  ▼
LaundryLiveActivityService.startActivity(...)
  │
  ▼  (App Group UserDefaults)
BrownyLiveActivity Widget Extension
  └► Lock Screen / Dynamic Island UI
```

---

## iOS Requirements

| ข้อกำหนด | ค่า |
|---|---|
| iOS Minimum | **16.1** (Live Activities) |
| Xcode | 14.1+ |
| ActivityKit | Built-in (ไม่ต้องติดตั้งเพิ่ม) |
| App Group | `group.com.brownywash.brownyapplications.liveactivity` |
| Widget Extension Bundle ID | `com.brownywash.brownyapplications.BrownyLiveActivity` |

---

## Data Model

### ContentState (Dynamic — อัพเดทได้ระหว่าง Activity ทำงาน)

| Field (snake_case) | Type | Description |
|---|---|---|
| `remaining_seconds` | Int | เวลาเหลือ (วินาที) |
| `total_seconds` | Int | เวลาทั้งหมด (วินาที) |
| `is_completed` | Bool | เสร็จสิ้นแล้วหรือไม่ |
| `machine_number` | String | หมายเลขเครื่อง |
| `service_type` | String | `"wash"` / `"dry"` / `"wash_dry"` |
| `branch_name` | String | ชื่อสาขา |

### ActivityAttributes (Static — กำหนดตอน start ไม่เปลี่ยน)

| Field | Type | Description |
|---|---|---|
| `machine_id` | String | ID ของเครื่อง |

---

## UI Specification

### Lock Screen / Notification Banner

```
┌──────────────────────────────────────────────────┐
│  🫧 Browny Wash          Central World Branch    │
│  เครื่อง #5                                      │
│  ████████████░░░░░░░░░░░░░░░░░  40%             │
│  ⏱ เหลือ: 12:45                                 │
└──────────────────────────────────────────────────┘

[เสร็จสิ้น]
┌──────────────────────────────────────────────────┐
│  ✅ ซักเสร็จแล้ว!          Central World Branch  │
│  เครื่อง #5                                      │
│  ██████████████████████████████  เสร็จสิ้น      │
│  แตะเพื่อให้คะแนนการใช้งาน  ⭐⭐⭐⭐⭐           │
└──────────────────────────────────────────────────┘
```

### Dynamic Island — Compact

```
Leading:  [🫧]  (service icon)
Trailing: [12m] (time remaining)
```

### Dynamic Island — Expanded

```
Leading:  🫧 เครื่อง #5
Trailing: 12:45
Center:   Central World
Bottom:   [Progress Bar]
```

---

## Setup Steps (ทำครั้งเดียว)

### Step 1 — Flutter (Auto)
- [x] เพิ่ม `live_activities` ใน `pubspec.yaml`
- [x] สร้าง `LaundryLiveActivityService` ใน `lib/core/services/live_activity/`
- [x] เพิ่ม `NSSupportsLiveActivities` ใน `ios/Runner/Info.plist`

### Step 2 — Xcode (Manual — ต้องทำใน Xcode)

#### 2.1 เพิ่ม Widget Extension Target
1. เปิด `ios/Runner.xcworkspace` ใน Xcode
2. ไป **File → New → Target**
3. เลือก **Widget Extension**
4. ตั้งชื่อ **`BrownyLiveActivity`**
5. Bundle ID: `com.brownywash.brownyapplications.BrownyLiveActivity`
6. **ยกเลิกเครื่องหมาย** "Include Configuration Intent"
7. ตั้ง Deployment Target เป็น **16.1**
8. เลือก **Swift** language

#### 2.2 เพิ่ม App Group Capability
ต้องทำกับ **ทั้ง 2 Targets** (Runner + BrownyLiveActivity):

1. เลือก Runner target → **Signing & Capabilities**
2. กด **+** → เพิ่ม **App Groups**
3. เพิ่ม group: `group.com.brownywash.brownyapplications.liveactivity`
4. ทำซ้ำกับ **BrownyLiveActivity** target

#### 2.3 แทนที่ไฟล์ใน BrownyLiveActivity Extension
แทนที่ไฟล์ที่ Xcode สร้างให้ด้วยไฟล์ที่เราสร้างใน `ios/BrownyLiveActivity/`:
- `BrownyMachineActivityAttributes.swift`
- `BrownyLiveActivityView.swift`
- `BrownyLiveActivityBundle.swift`

#### 2.4 ตั้งค่า Extension Info.plist
ตรวจสอบว่า `BrownyLiveActivity/Info.plist` มี:
- `NSExtension.NSExtensionPointIdentifier` = `com.apple.widgetkit-extension`

### Step 3 — Apple Developer Portal
1. ไปที่ [Apple Developer Portal](https://developer.apple.com)
2. Identifiers → เพิ่ม App Group: `group.com.brownywash.brownyapplications.liveactivity`
3. เพิ่ม App Group ใน App ID: `com.brownywash.brownyapplications`
4. สร้าง App ID ใหม่: `com.brownywash.brownyapplications.BrownyLiveActivity`
5. Regenerate provisioning profiles

---

## Flutter Integration Points

### เริ่ม Activity (ตอน Machine เริ่มทำงาน)
```dart
// ใน MachineStatusPage หรือ MachineTransactionViewmodel
await LaundryLiveActivityService.instance.startActivity(
  machineId: _viewmodel.machineId,
  machineNumber: machineDetail.machineNumber ?? machineId,
  serviceType: _detectServiceType(machineDetail),
  branchName: machineDetail.storeName ?? '',
  remainingSeconds: remainingDuration.inSeconds,
  totalSeconds: _viewmodel.totalDurationInSeconds.toInt(),
);
```

### อัพเดท Activity (ทุก 15 วินาที หรือตอน status เปลี่ยน)
```dart
// ใน _startStatusTimer หรือ lifecycle ของ MachineStatusPage
await LaundryLiveActivityService.instance.updateActivity(
  remainingSeconds: currentDuration.inSeconds,
  isCompleted: false,
);
```

### จบ Activity (ตอนเสร็จ)
```dart
await LaundryLiveActivityService.instance.endActivity(isCompleted: true);
```

---

## Known Limitations

| ข้อจำกัด | หมายเหตุ |
|---|---|
| iOS 16.1+ เท่านั้น | ต้องเช็ค `areActivitiesEnabled()` ก่อนเสมอ |
| Max 4 Live Activities ต่อ app | iOS กำหนด |
| Live Activity หมดอายุใน 8 ชั่วโมง | ต้อง end ก่อนหมดเวลา |
| ไม่รองรับ Android | Android ใช้ flutter_local_notifications แทน |
| Widget Extension แยก binary | ต้องมีใน App Store submission |
| Background update limit | ใช้ Push-to-update สำหรับ real-time (phase 2) |

---

## Phase 2 — Push-to-Update (แผนในอนาคต)

Live Activity สามารถอัพเดทจาก server ผ่าน APNs ได้โดยไม่ต้องให้ app ตื่น:

1. Flutter ส่ง `activityId` → Backend
2. Backend ส่ง APNs push token ของ Activity
3. Server push update โดยตรง (ไม่ง้อ Flutter app)

ต้องการ:
- `NSSupportsLiveActivitiesFrequentUpdates` = YES (ใน Info.plist)
- APNs server integration
- Push token listener ใน Flutter

---

## File Structure

```
lib/
└── core/
    └── services/
        └── live_activity/
            └── laundry_live_activity_service.dart

ios/
├── Runner/
│   └── Info.plist  ← เพิ่ม NSSupportsLiveActivities
└── BrownyLiveActivity/  ← Widget Extension files
    ├── BrownyMachineActivityAttributes.swift
    ├── BrownyLiveActivityView.swift
    ├── BrownyLiveActivityBundle.swift
    └── Info.plist

docs/
└── LIVE_ACTIVITY_PLAN.md  ← ไฟล์นี้
```
