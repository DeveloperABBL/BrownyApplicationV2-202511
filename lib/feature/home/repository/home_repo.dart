import 'package:browny_applications_new/core/data/cache/app_local_storage.dart';
import 'package:browny_applications_new/core/data/cache/popup_cache_manager.dart';
import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/data/remote/models/request/banner_collect_request.dart';
import 'package:browny_applications_new/core/data/remote/models/response/banner_collect_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/banner_highlight_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/banner_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/browny_live_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/customer_notification_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/home_menu_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/popup_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/working_machine_data.dart';
import 'package:browny_applications_new/core/data/remote/models/response/working_machines_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';
import 'package:browny_applications_new/feature/authentication/repository/customer_data_repo.dart';
import 'package:flutter/foundation.dart';

mixin HomeDataSourceMixin on CustomerDataSourceMixin {
  /// ดึงข้อมูล Banner สำหรับแสดงในหน้าหลัก
  ///
  /// Parameters:
  /// - customerId: UUID ของลูกค้า (nullable)
  Future<RepoResult<BannerResponse>> fetchBanner({String? customerId});

  /// ดึงข้อมูล Banner Highlight สำหรับแสดงในหน้าหลัก
  ///
  /// Parameters:
  /// - customerId: UUID ของลูกค้า (nullable)
  Future<RepoResult<BannerHighlightResponse>> fetchBannerHighlight({
    String? customerId,
  });

  /// ดึงข้อมูล Home Menu Items (รายการเมนูหน้าหลัก)
  Future<RepoResult<HomeMenuResponse>> fetchHomeMenu();

  /// ดึงข้อมูล Browny Live status และ link
  Future<RepoResult<BrownyLiveResponse>> fetchBrownyLive();

  /// ดึงข้อมูล Popups สำทรับแสดง campaign/promotion
  ///
  /// จะกรองเฉพาะ popup ที่:
  /// - active = true
  /// - อยู่ในช่วงเวลาที่กำหนด
  /// - ไม่ถูก dismiss ไปแล้วในวันนี้
  Future<RepoResult<List<PopupData>>> fetchPopups({String? showOn});

  /// DONG 2026-02-17
  ///
  /// ดึงข้อมูลว่า Popup inivit Friend วันนี้แสดงไปแล้วหรือยัง
  Future<RepoResult<bool>> fetchPopupInvitFriend();

  /// DONG 2026-02-28
  ///
  /// API fetch รายการเครื่องที่กำลังทำงาน
  ///
  /// Parameters:
  /// - customerId: UUID ของลูกค้า
  /// - notificationToken: FCM token สำหรับ push notification
  ///
  /// Returns:
  /// - WorkingMachinesResponse with count และ list ของเครื่องที่กำลังทำงาน
  Future<RepoResult<WorkingMachinesResponse>> fetchWorkingMachines({
    String? customerId,
    String? notificationToken,
  });

  /// DONG 2026-02-28
  ///
  /// API fetch รายการ notifications ของลูกค้า
  ///
  /// Parameters:
  /// - uuid: UUID ของลูกค้า
  ///
  /// Returns:
  /// - CustomerNotificationResponse with list ของ notifications
  Future<RepoResult<CustomerNotificationResponse>> fetchCustomerNotifications(
    String uuid,
  );

  /// บันทึกว่า popup นี้ถูก dismiss สำหรับวันนี้
  void dismissPopupForToday(int popupId);

  /// บันทึกว่า popup list นี้ถูก dismiss สำหรับวันนี้
  void dismissPopupsForToday(List<PopupData> popups);

  /// บันทึกว่า popup InvitFriend นี้ถูก dismiss สำหรับวันนี้
  void dismissInvitFriendForToday();

  /// DONG 2026-03-08
  ///
  /// API Collect Banner (เก็บคูปองจาก Banner)
  ///
  /// Parameters:
  /// - bannerId: ID ของ Banner
  /// - customerId: UUID ของลูกค้า
  ///
  /// Returns:
  /// - BannerCollectResponse with status และ message
  Future<RepoResult<BannerCollectResponse>> collectBanner({
    required int bannerId,
    required String customerId,
  });
}

class HomeRepo extends CustomerDataRepo with HomeDataSourceMixin {
  // Popup cache manager
  late final PopupCacheManager _popupCache;

  HomeRepo() {
    _popupCache = PopupCacheManager(AppLocalStorage.instance());
  }

  @override
  Future<RepoResult<BannerResponse>> fetchBanner({String? customerId}) async {
    try {
      // fetch data จาก api
      final response = await requireRemote.fetchBanners(customerId);

      // ถ้าไม่ใช้ CODE Success จะ return Unknown error
      if (!response.isSuccessful) {
        return RepoResult.error(
          error: Exception('Unknown error.'),
        );
      }

      if (response.data == null) {
        return RepoResult.empty();
      }

      return RepoResult.dependOn(response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<BannerHighlightResponse>> fetchBannerHighlight({
    String? customerId,
  }) async {
    try {
      // fetch data จาก api
      final response = await requireRemote.fetchBannersHighlight(customerId);

      // ถ้าไม่ใช้ CODE Success จะ return Unknown error
      if (!response.isSuccessful) {
        return RepoResult.error(
          error: Exception('Unknown error.'),
        );
      }

      if (response.data == null) {
        return RepoResult.empty();
      }

      return RepoResult.dependOn(response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<HomeMenuResponse>> fetchHomeMenu() async {
    try {
      final response = await requireRemote.fetchHomeMenu();

      if (!response.isSuccessful) {
        return RepoResult.error(
          error: Exception('Unknown error.'),
        );
      }

      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<BrownyLiveResponse>> fetchBrownyLive() async {
    try {
      final response = await requireRemote.fetchBrownyLive();

      if (!response.isSuccessful) {
        return RepoResult.error(
          error: Exception('Unknown error.'),
        );
      }

      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<List<PopupData>>> fetchPopups({String? showOn}) async {
    try {
      final response = await requireRemote.fetchPopups();

      if (!response.isSuccessful) {
        return RepoResult.error(
          error: Exception('Unknown error.'),
        );
      }

      // กรองเฉพาะ popup ที่:
      // 1. active = true
      // 2. อยู่ในช่วงเวลาที่กำหนด
      // 3. ไม่ถูก dismiss ไปแล้วในวันนี้
      final activePopups = response.data.where((popup) {
        // ต้อง active
        return popup.isActive &&
            // อยู่ใน period
            popup.isInDateRange() &&
            // เป็น id ที่ยังไม่ถูก user ปิดไม่ให้แสดงอีกในวัน
            !_popupCache.isDismissedToday(popup.id) &&
            // ถ้า pass ShowOn เข้ามา จะต้องเอาที่ตรงกันเท่านั้น
            (showOn == null ? true : popup.shouldShowOn(showOn));
      }).toList();

      if (activePopups.isEmpty) {
        return RepoResult.empty();
      }

      return RepoResult.success(data: activePopups);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<bool>> fetchPopupInvitFriend() async {
    return RepoResult.success(data: !_popupCache.isInvitFriendDismissedToday());
  }

  @override
  void dismissPopupForToday(int popupId) {
    _popupCache.markPopupAsDismissedToday(popupId);
  }

  @override
  void dismissPopupsForToday(List<PopupData> popups) {
    _popupCache.markAsDismissedToday(popups);
  }

  @override
  void dismissInvitFriendForToday() {
    _popupCache.markInvitFriendAsDismissedToday();
  }

  @override
  Future<RepoResult<WorkingMachinesResponse>> fetchWorkingMachines({
    String? customerId,
    String? notificationToken,
  }) async {
    try {
      if (kDebugMode) {
        return RepoResult.success(
          data: WorkingMachinesResponse(
            count: 2,
            data: [
              WorkingMachineData(
                id: 13,
                machineImage:
                    'https://dev.abgroup.co.th/storage/galleries/s3nbAR7QLSPpZ9aSTWSyGV9nXQZy6JhsPgVvaJKL.png',
                finishDatatime: '16:30',
                remainingTime: '00:08:00',
                name: ContentLocalizeData(
                  th: "เครื่องซัก 1 / Test",
                  en: "Washer 1 / Test",
                  zh: "洗衣机 1 / Test",
                ),
              ),
              WorkingMachineData(
                id: 14,
                machineImage:
                    'https://dev.abgroup.co.th/storage/galleries/s3nbAR7QLSPpZ9aSTWSyGV9nXQZy6JhsPgVvaJKL.png',
                finishDatatime: '23:06',
                remainingTime: '00:00:00',
                name: ContentLocalizeData(
                  th: "เครื่องซัก 2 / Test",
                  en: "Washer 2 / Test",
                  zh: "洗衣机 2 / Test",
                ),
              ),
            ],
          ),
        );
      }

      final response = await requireRemote.fetchWorkingMachines(
        customerId: customerId,
        notificationToken: notificationToken,
      );

      if (!response.isSuccessful) {
        return RepoResult.error(
          error: Exception('Unknown error.'),
        );
      }

      return RepoResult.success(
        data: WorkingMachinesResponse(
          count: response.data.orEmpty.length,
          data: response.data,
        ),
      );
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<CustomerNotificationResponse>> fetchCustomerNotifications(
    String uuid,
  ) async {
    try {
      final response = await requireRemote.fetchCustomerNotifications(uuid);

      if (!response.isSuccessful) {
        return RepoResult.error(
          error: Exception('Unknown error.'),
        );
      }

      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<BannerCollectResponse>> collectBanner({
    required int bannerId,
    required String customerId,
  }) async {
    try {
      final response = await requireRemote.collectBanner(
        bannerId,
        BannerCollectRequest(customerId: customerId),
      );

      if (!response.isSuccessful) {
        return RepoResult.error(
          error: Exception('Unknown error.'),
        );
      }

      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
