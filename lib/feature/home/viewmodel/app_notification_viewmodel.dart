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
    super.dispose();
  }

  // ========== ValueNotifier ==========
  /// Notifier สำหรับเก็บ notifications ของลูกค้า
  final ValueNotifier<UiResult<CustomerNotificationResponse>>
  _customerNotificationsNotifier = ValueNotifier(UiResult.loading());

  ValueListenable<UiResult<CustomerNotificationResponse>>
  get customerNotificationsNotifier => _customerNotificationsNotifier;

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
