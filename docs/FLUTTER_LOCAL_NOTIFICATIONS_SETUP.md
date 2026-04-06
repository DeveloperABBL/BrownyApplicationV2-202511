# flutter_local_notifications Setup Checklist

## ✅ Android Setup (ตรวจสอบเรียบร้อยแล้ว)

### 1. Gradle Configuration
- ✅ **compileSdk**: 36 (ต้องการขั้นต่ำ 35)
- ✅ **Desugaring enabled**: เพิ่ม `isCoreLibraryDesugaringEnabled = true`
- ✅ **Desugaring dependency**: เพิ่ม `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`

**Location**: `android/app/build.gradle.kts`

```kotlin
compileOptions {
    isCoreLibraryDesugaringEnabled = true
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

### 2. AndroidManifest.xml Permissions
- ✅ **POST_NOTIFICATIONS**: สำหรับแสดง notifications (Android 13+)
- ✅ **RECEIVE_BOOT_COMPLETED**: สำหรับ reschedule notifications หลัง reboot
- ✅ **VIBRATE**: สำหรับ vibration
- ✅ **WAKE_LOCK**: สำหรับ wake device
- ✅ **SCHEDULE_EXACT_ALARM**: สำหรับ exact timing notifications

**Location**: `android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

### 3. AndroidManifest.xml Receivers
- ✅ **ScheduledNotificationReceiver**: สำหรับ scheduled notifications
- ✅ **ScheduledNotificationBootReceiver**: สำหรับ reschedule หลัง reboot
- ✅ **ActionBroadcastReceiver**: สำหรับ notification actions

**Location**: `android/app/src/main/AndroidManifest.xml` (ใน `<application>` tag)

```xml
<!-- Scheduled notification receivers -->
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>

<!-- Action receiver for notification actions -->
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver" />
```

### 4. Notification Icon
- ✅ Default icon configured: `@mipmap/ic_launcher`
- ⚠️ **แนะนำ**: สร้าง notification icon แยกตาม [Android guidelines](https://developer.android.com/studio/write/image-asset-studio#create-notification)

---

## ✅ iOS Setup (ตรวจสอบเรียบร้อยแล้ว)

### 1. AppDelegate Configuration
- ✅ **UNUserNotificationCenter delegate**: เพิ่ม delegate setup

**Location**: `ios/Runner/AppDelegate.swift`

```swift
override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    // ... existing code ...
    
    // flutter_local_notifications - Set delegate for handling notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}
```

### 2. Info.plist Configuration
- ✅ **UIBackgroundModes**: มี `remote-notification` และ `fetch`

**Location**: `ios/Runner/Info.plist`

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
    <string>fetch</string>
</array>
```

---

## 📋 การใช้งานตาม Documentation

### Initialization
```dart
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);

final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin);

await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
    });
```

### Request Permission (Android 13+)
```dart
// Request notification permission on Android 13+
await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();

// Request exact alarm permission (if needed)
await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.requestExactAlarmsPermission();
```

### Show Notification
```dart
const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
        'browny_channel',
        'Browny Notifications',
        channelDescription: 'Browny app notifications',
        importance: Importance.max,
        priority: Priority.high);

const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

await flutterLocalNotificationsPlugin.show(
    0,
    'Test Notification',
    'This is a test notification',
    notificationDetails);
```

### Schedule Notification
```dart
import 'package:timezone/timezone.dart' as tz;

// Initialize timezone (ใน main.dart)
tz.initializeTimeZones();

// Schedule notification
await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Scheduled Notification',
    'This notification was scheduled',
    tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
    const NotificationDetails(
        android: AndroidNotificationDetails(
            'browny_channel',
            'Browny Notifications',
            channelDescription: 'Browny app notifications')),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
```

---

## ⚠️ สิ่งที่ควรทำเพิ่มเติม (Optional)

### 1. สร้าง Notification Icon แยก (Android)
ตาม [Android guidelines](https://developer.android.com/studio/write/image-asset-studio#create-notification):
1. เปิด Android Studio → Image Asset Studio
2. เลือก "Notification Icons"
3. สร้าง icon ที่เหมาะสม (24x24 dp, white on transparent)
4. ไว้ใน `android/app/src/main/res/drawable/`
5. เปลี่ยน initialization จาก `@mipmap/ic_launcher` เป็น `@drawable/ic_notification`

### 2. Custom Notification Sound (Optional)
1. ใส่ไฟล์เสียงใน `android/app/src/main/res/raw/` และ `ios/Runner/`
2. ตั้งค่าใน notification details:
```dart
const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
        'browny_channel',
        'Browny Notifications',
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        ...);
```

### 3. ProGuard Rules (Release Build)
หาก build release มีปัญหา ให้เพิ่มใน `android/app/proguard-rules.pro`:
```proguard
# Keep resources for flutter_local_notifications
-keep class com.dexterous.** { *; }
```

และตรวจสอบว่า resources ถูก keep ใน `android/app/src/main/res/raw/keep.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources xmlns:tools="http://schemas.android.com/tools"
    tools:keep="@drawable/ic_launcher,@drawable/*,@raw/*,@mipmap/*" />
```

---

## 🧪 Testing Checklist

### Android
- [ ] แสดง notification ปกติได้
- [ ] Schedule notification ทำงานได้ (หลังจาก request exact alarm permission)
- [ ] Notification แสดงหลัง reboot device
- [ ] Tap notification เปิด app ได้
- [ ] Notification actions ทำงานได้ (ถ้ามี)

### iOS
- [ ] Request permission ได้
- [ ] แสดง notification ได้
- [ ] Tap notification เปิด app ได้
- [ ] Scheduled notification ทำงานได้

### การ Debug
1. เช็ค Android logcat: `flutter logs` หรือ Android Studio Logcat
2. เช็ค iOS Console: Xcode → Window → Devices and Simulators → View Device Logs
3. ตรวจสอบ permissions: Settings → Apps → [App Name] → Notifications

---

## 📚 References

- [flutter_local_notifications pub.dev](https://pub.dev/packages/flutter_local_notifications)
- [Android Notification Guidelines](https://developer.android.com/guide/topics/ui/notifiers/notifications)
- [iOS UserNotifications](https://developer.apple.com/documentation/usernotifications)
- [Timezone Package](https://pub.dev/packages/timezone)

---

## ✅ Summary

**การ setup ตรงตาม documentation แล้วทั้งหมด!**

- ✅ Android Gradle configuration (desugaring)
- ✅ Android permissions และ receivers
- ✅ iOS AppDelegate configuration
- ✅ iOS UIBackgroundModes

**พร้อมใช้งาน flutter_local_notifications แล้ว!** 🎉
