import 'package:browny_applications_new/core/data/repo/app_repository.dart';
import 'package:browny_applications_new/core/data/remote/models/response/contact_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';

mixin ContactDataSourceMixin {
  /// API fetch ข้อมูล Contact (social media links)
  Future<RepoResult<ContactResponse>> fetchContact();
}

class ContactRepo extends AppRepository with ContactDataSourceMixin {
  @override
  Future<RepoResult<ContactResponse>> fetchContact() async {
    try {
      final response = await requireRemote.fetchContact();
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
