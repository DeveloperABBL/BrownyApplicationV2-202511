import 'package:browny_applications_new/core/data/remote/models/response/banner_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/browny_live_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/home_menu_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';
import 'package:browny_applications_new/feature/authentication/repository/customer_data_repo.dart';

mixin HomeDataSourceMixin on CustomerDataSourceMixin {
  /// ดึงข้อมูล Banner สำหรับแสดงในหน้าหลัก
  Future<RepoResult<BannerResponse>> fetchBanner();

  /// ดึงข้อมูล Home Menu Items (รายการเมนูหน้าหลัก)
  Future<RepoResult<HomeMenuResponse>> fetchHomeMenu();

  /// ดึงข้อมูล Browny Live status และ link
  Future<RepoResult<BrownyLiveResponse>> fetchBrownyLive();
}

class HomeRepo extends CustomerDataRepo with HomeDataSourceMixin {
  @override
  Future<RepoResult<BannerResponse>> fetchBanner() async {
    try {
      // fetch data จาก api
      final response = await requireRemote.fetchBanners();

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
}
