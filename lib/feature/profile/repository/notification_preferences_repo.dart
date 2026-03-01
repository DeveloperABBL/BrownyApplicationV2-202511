import 'package:browny_applications_new/core/data/remote/models/request/update_notification_preferences_request.dart';
import 'package:browny_applications_new/core/data/remote/models/response/notification_preferences_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/update_notification_preferences_response.dart';
import 'package:browny_applications_new/core/data/repo/app_repository.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';

mixin NotificationPreferencesDataSourceMixin {
  /// API fetch ข้อมูลการตั้งค่าการแจ้งเตือน
  Future<RepoResult<NotificationPreferencesResponse>>
  fetchNotificationPreferences(String uuid);

  /// API อัพเดทการตั้งค่าการแจ้งเตือน
  Future<RepoResult<UpdateNotificationPreferencesResponse>>
  updateNotificationPreferences(
    String uuid,
    UpdateNotificationPreferencesRequest request,
  );
}

class NotificationPreferencesRepo extends AppRepository
    with NotificationPreferencesDataSourceMixin {
  @override
  Future<RepoResult<NotificationPreferencesResponse>>
  fetchNotificationPreferences(String uuid) async {
    try {
      final response = await requireRemote.fetchNotificationPreferences(uuid);
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<UpdateNotificationPreferencesResponse>>
  updateNotificationPreferences(
    String uuid,
    UpdateNotificationPreferencesRequest request,
  ) async {
    try {
      final response = await requireRemote.updateNotificationPreferences(
        uuid,
        request,
      );
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
