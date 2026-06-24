import 'package:browny_applications_new/core/data/remote/models/response/customer_notification_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/feature/home/viewmodel/home_page_viewmodel.dart';
import 'package:flutter/foundation.dart';

class AppNotificationViewmodel extends HomePageViewmodel {
  AppNotificationViewmodel({
    required super.context,
    required super.repo,
    required super.brownyShopRepo,
  });

  // ========== Dispose ==========
  @override
  void dispose() {
    _customerNotificationsNotifier.dispose();
    _notificationFilterNotifier.dispose();
    super.dispose();
  }

  // ========== ValueNotifier ==========
  /// Notifier สำหรับเก็บ notifications ของลูกค้า
  final ValueNotifier<UiResult<CustomerNotificationResponse>>
  _customerNotificationsNotifier = ValueNotifier(UiResult.loading());

  ValueListenable<UiResult<CustomerNotificationResponse>>
  get customerNotificationsNotifier => _customerNotificationsNotifier;

  // ========== Filter ==========
  /// ประเภทการแจ้งเตือนกลุ่ม "ซัก-อบ" (toggle index 1)
  /// อื่นๆ ที่ไม่อยู่ในชุดนี้ = กลุ่ม "การสั่งซื้อ" (toggle index 2 เช่น Browny Shop)
  static const Set<String> serviceNotificationTypes = {
    'payment',
    'top_up',
    'soon_finish',
    'machine_finish',
  };

  /// ตัวกรองประเภทการแจ้งเตือน
  /// 0 = ทั้งหมด, 1 = ซัก-อบ (ตาม [serviceNotificationTypes]), 2 = อื่นๆ
  final ValueNotifier<int> _notificationFilterNotifier = ValueNotifier(0);
  ValueListenable<int> get notificationFilterNotifier =>
      _notificationFilterNotifier;

  void setNotificationFilter(int value) {
    _notificationFilterNotifier.value = value;
  }

  /// กรองรายการ notifications ตาม [filter] ที่เลือกบน toggle
  List<CustomerNotificationItem> filterNotifications(
    List<CustomerNotificationItem> all,
    int filter,
  ) {
    switch (filter) {
      // ซัก-อบ — เฉพาะประเภทใน serviceNotificationTypes
      case 1:
        return all
            .where((e) => serviceNotificationTypes.contains(e.type))
            .toList();
      // การสั่งซื้อ — ประเภทอื่นๆ ที่ไม่ใช่ ซัก-อบ
      case 2:
        return all
            .where((e) => !serviceNotificationTypes.contains(e.type))
            .toList();
      // ทั้งหมด
      default:
        return all;
    }
  }

  // ========== Logic ==========
  /// DONG 2026-02-28
  ///
  /// API fetch รายการ notifications ของลูกค้า
  @override
  Future<void> fetchCustomerNotifications() async {
    // 1. Set loading state
    _customerNotificationsNotifier.value = UiResult.loading();

    String customerId = currentCustomerProvider.current.id.orEmpty;
    if (customerId.isEmpty) {
      _customerNotificationsNotifier.value = UiResult.empty();
      return;
    }

    // 2. Call repository
    final result = await homeRepo.fetchCustomerNotifications(customerId);

    // 3. Handle error
    if (result.hasError) {
      _customerNotificationsNotifier.value = UiResult.error(
        error: result.error,
      );
      return;
    }

    // 4. Handle empty
    if (result.isEmpty) {
      _customerNotificationsNotifier.value = UiResult.empty();
      return;
    }

    // 5. Handle success
    _customerNotificationsNotifier.value = UiResult.success(data: result.data);
  }
}
