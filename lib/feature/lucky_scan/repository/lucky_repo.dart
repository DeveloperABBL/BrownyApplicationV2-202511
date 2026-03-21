import 'package:browny_applications_new/core/data/remote/models/response/festive_index_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/lucky_draw_response.dart';
import 'package:browny_applications_new/core/data/repo/app_repository.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';

mixin LuckyDataSourceMixin {
  /// API fetch รายการ Festive Event (Lucky Scan campaigns)
  Future<RepoResult<FestiveIndexResponse>> fetchFestiveIndex();

  /// API สแกน QR Lucky Draw
  Future<RepoResult<LuckyDrawResponse>> postLuckyDraw({
    required String customerId,
    required String qrCode,
  });
}

class LuckyRepo extends AppRepository with LuckyDataSourceMixin {
  @override
  Future<RepoResult<FestiveIndexResponse>> fetchFestiveIndex() async {
    try {
      final response = await requireRemote.fetchFestiveIndex();
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<LuckyDrawResponse>> postLuckyDraw({
    required String customerId,
    required String qrCode,
  }) async {
    try {
      final response = await requireRemote.postLuckyDraw({
        'customer_id': customerId,
        'qr_code': qrCode,
      });
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
