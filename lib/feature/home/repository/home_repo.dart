import 'package:browny_applications_new/core/data/remote/models/response/banner_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';
import 'package:browny_applications_new/feature/authentication/repository/customer_data_repo.dart';

mixin HomeDataSourceMixin {
  Future<RepoResult<List<BannerResponse>>> fetchBanner();
}

class HomeRepo extends CustomerDataRepo with HomeDataSourceMixin {
  @override
  Future<RepoResult<List<BannerResponse>>> fetchBanner() async {
    try {
      // fetch data จาก api
      final response = await requireRemote.fetchBanners();

      // ถ้าไม่ใช้ CODE Success จะ return Unknown error
      if (!response.isSuccessful) {
        return RepoResult.error(
          error: Exception('Unknown error.'),
        );
      }

      if (response.data.orEmpty.isEmpty) {
        return RepoResult.empty();
      }

      return RepoResult.dependOn(response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
