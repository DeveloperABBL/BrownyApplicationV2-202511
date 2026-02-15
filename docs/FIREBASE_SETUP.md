# Firebase Crashlytics & Cloud Messaging Setup

## 📦 Dependencies เพิ่มเติม

```yaml
firebase_crashlytics: ^5.0.7
firebase_messaging: ^16.1.1
flutter_local_notifications: ^17.2.4
```

## 🚀 การใช้งาน

### 1. Firebase Crashlytics

**Initialize ใน main.dart:**
```dart
await CrashlyticsHelper.initialize(
  enableInDebugMode: false, // เปิดเป็น true เพื่อ test ใน debug mode
);
```

**Record exception:**
```dart
try {
  // your code
} catch (e, stackTrace) {
  await CrashlyticsHelper.recordError(
    e, 
    stackTrace,
    reason: 'Payment failed',
    customKeys: {
      'user_id': '12345',
      'order_id': 'ORD-001',
    },
  );
}
```

**Log custom messages:**
```dart
CrashlyticsHelper.log('User navigated to checkout');
CrashlyticsHelper.log('API call: POST /orders');
```

**Set user identifier:**
```dart
// เมื่อ user login
await CrashlyticsHelper.setUserIdentifier('user_12345');

// เมื่อ user logout
await CrashlyticsHelper.clearUserIdentifier();
```

**Custom keys สำหรับ crash context:**
```dart
await CrashlyticsHelper.setCustomKey('payment_method', 'credit_card');
await CrashlyticsHelper.setCustomKey('order_total', 1500.0);

// หรือตั้งหลายค่าพร้อมกัน
await CrashlyticsHelper.setCustomKeys({
  'screen': 'checkout',
  'payment_method': 'credit_card',
  'item_count': 3,
});
```

**Testing:**
```dart
// ส่ง test exception
await CrashlyticsHelper.sendTestException();

// Force crash (debug mode only)
CrashlyticsHelper.forceCrash(); // ⚠️ จะทำให้ app crash จริงๆ!
```

---

### 2. Firebase Cloud Messaging (Push Notifications)

**Initialize ใน main.dart:**
```dart
await NotificationHelper.initialize();

// Setup notification tap handler
NotificationHelper.onNotificationTap((message) {
  debugPrint('User tapped notification with data: ${message.data}');
  
  // Handle navigation
  final screen = message.data['screen'];
  final id = message.data['id'];
  
  if (screen == 'order_detail') {
    context.pushNamed('order_detail', pathParameters: {'id': id});
  }
});
```

**Get FCM Token:**
```dart
final token = await NotificationHelper.getToken();
// ส่ง token ไปยัง backend
await yourApi.updateFcmToken(token);
```

**Subscribe to topics:**
```dart
// Subscribe
await NotificationHelper.subscribeToTopic('promotions');
await NotificationHelper.subscribeToTopic('news');

// Unsubscribe
await NotificationHelper.unsubscribeFromTopic('promotions');
```

**Delete token (เมื่อ user logout):**
```dart
await NotificationHelper.deleteToken();
```

**Test notification:**
```dart
await NotificationHelper.showTestNotification(
  title: 'Test Notification',
  body: 'This is a test notification',
  data: {'screen': 'home'},
);
```

---

## 📱 Platform Configuration

### Android

**AndroidManifest.xml** (✅ Already configured):
- ✅ POST_NOTIFICATIONS permission
- ✅ RECEIVE_BOOT_COMPLETED permission
- ✅ VIBRATE and WAKE_LOCK permissions
- ✅ SCHEDULE_EXACT_ALARM permission (for scheduled notifications)
- ✅ Firebase Messaging service
- ✅ Default notification channel
- ✅ Default notification icon & color
- ✅ Scheduled notification receivers (flutter_local_notifications)
- ✅ Action broadcast receiver (flutter_local_notifications)

**Gradle Configuration** (✅ Already configured):
- ✅ Desugaring enabled for scheduled notifications
- ✅ compileSdk 36+

**Firebase Console:**
1. ไปที่ Project Settings → Cloud Messaging
2. ใน "Cloud Messaging API" tab, enable Cloud Messaging API
3. Download `google-services.json` และใส่ใน `android/app/`

### iOS

**Info.plist** (✅ Already configured):
- ✅ UIBackgroundModes: remote-notification, fetch

**Xcode Configuration:**
1. เปิด `ios/Runner.xcworkspace` ใน Xcode
2. เลือก Runner → Signing & Capabilities
3. เพิ่ม **Push Notifications** capability
4. เพิ่ม **Background Modes** capability และเลือก:
   - ✅ Remote notifications
   - ✅ Background fetch

**Firebase Console:**
1. ไปที่ Project Settings → Cloud Messaging
2. ใส่ APNs Authentication Key หรือ APNs Certificate
3. Download `GoogleService-Info.plist` และใส่ใน `ios/Runner/`

**Upload APNs Key:**
```bash
# ไปที่ https://developer.apple.com/account/resources/authkeys/list
# สร้าง key ใหม่ด้วย "Apple Push Notifications service (APNs)"
# Download .p8 file และนำไป upload ใน Firebase Console
```

---

## 🧪 Testing

### Test Crashlytics

**ส่ง test crash:**
```dart
// Debug mode
await CrashlyticsHelper.sendTestException();

// ดูผลลัพธ์ใน Firebase Console → Crashlytics
// อาจใช้เวลา 5-10 นาทีในการแสดงผล
```

**Force crash (debug mode):**
```dart
CrashlyticsHelper.forceCrash(); // App จะ crash ทันที!
```

### Test Push Notifications

**1. ผ่าน Firebase Console:**
```
Firebase Console → Cloud Messaging → Send test message
- เอา FCM token จาก NotificationHelper.getToken()
- ใส่ token และส่ง test notification
```

**2. ผ่าน curl:**
```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "FCM_TOKEN_HERE",
    "notification": {
      "title": "Test Notification",
      "body": "This is a test message"
    },
    "data": {
      "screen": "home",
      "id": "123"
    }
  }'
```

**3. ผ่าน code:**
```dart
await NotificationHelper.showTestNotification(
  title: 'Test',
  body: 'Testing local notification',
);
```

---

## 📝 Payload Structure

**Recommended notification payload:**
```json
{
  "notification": {
    "title": "New Order",
    "body": "You have a new order #12345"
  },
  "data": {
    "screen": "order_detail",
    "id": "12345",
    "type": "order",
    "action": "open"
  },
  "android": {
    "priority": "high",
    "notification": {
      "channel_id": "browny_channel",
      "sound": "default",
      "color": "#FF6B35"
    }
  },
  "apns": {
    "payload": {
      "aps": {
        "sound": "default",
        "badge": 1
      }
    }
  }
}
```

---

## 🔧 Troubleshooting

### Crashlytics ไม่แสดงข้อมูล
1. รอ 5-10 นาที หลังส่ง crash ครั้งแรก
2. ตรวจสอบว่า `google-services.json` และ `GoogleService-Info.plist` ถูกต้อง
3. Build app ใน release mode: `flutter build apk --release`
4. ตรวจสอบ Firebase Console → Crashlytics → Enable Crashlytics

### Notifications ไม่ขึ้น
1. ตรวจสอบ permissions:
   ```dart
   final hasPermission = await NotificationHelper.hasPermission();
   ```
2. ตรวจสอบ FCM token:
   ```dart
   final token = await NotificationHelper.getToken();
   print('Token: $token');
   ```
3. Android: ตรวจสอบว่ามี `google-services.json` ใน `android/app/`
4. iOS: ตรวจสอบว่าเพิ่ม Push Notifications capability แล้ว
5. iOS: ตรวจสอบว่า upload APNs key ใน Firebase Console แล้ว

### Background notifications ไม่ทำงาน (iOS)
1. เช็คว่าเปิด Background Modes → Remote notifications ใน Xcode
2. เช็ค `content-available: 1` ใน payload
3. Test บน physical device (simulator อาจมีปัญหา)

---

## 📚 Additional Resources

- [Firebase Crashlytics Documentation](https://firebase.google.com/docs/crashlytics)
- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [Testing FCM](https://firebase.google.com/docs/cloud-messaging/flutter/first-message)
