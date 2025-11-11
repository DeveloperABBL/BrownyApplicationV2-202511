import 'package:browny_applications_new/core/data/remote/models/response/introductions_response.dart';
import 'package:browny_applications_new/core/data/repo/app_repository.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';

/// domain DataSourece ของ Onboarding
mixin OnboardDataSource {
  /// DONG 2025-11-09
  ///
  /// สำหรับ fetch introduction onboarding
  Future<List<IntroductionsResponse>?> fetchIntroductions();
}

/// Implementations
class OnboardRepo extends AppRepository with OnboardDataSource {
  @override
  Future<List<IntroductionsResponse>?> fetchIntroductions() async {
    try {
      final response = await requireRemote.introductions();
      if (response.isSuccessful && response.data?.isNotEmpty == true) {
        return response.data;
      }
      return List.empty();
    } on Exception catch (e) {
      return throw e;
    }
  }
}
