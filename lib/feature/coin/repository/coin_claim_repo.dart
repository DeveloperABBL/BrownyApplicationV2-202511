import 'package:browny_applications_new/core/data/remote/models/response/coin_claim_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coin_claimed_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';
import 'package:browny_applications_new/feature/authentication/repository/customer_data_repo.dart';

mixin CoinDataSourceMixin on CustomerDataSourceMixin {
  Future<RepoResult<CoinClaimedResponse>> coinClaiming(String id);

  Future<RepoResult<CoinClaimResponse>> fetchCoinClaimData(String id);
}

class CoinClaimRepo extends CustomerDataRepo with CoinDataSourceMixin {
  @override
  Future<RepoResult<CoinClaimedResponse>> coinClaiming(String id) async {
    try {
      final response = await requireRemote.coinClaiming({
        "customer_id": id,
      });

      if (!response.isSuccessful || response.data.resStatus != true) {
        return RepoResult.error(
          error: Exception(response.response.statusMessage),
        );
      }

      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(
        error: e,
      );
    }
  }

  @override
  Future<RepoResult<CoinClaimResponse>> fetchCoinClaimData(String id) async {
    try {
      final response = await requireRemote.getCoinClaimData(id);
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }

      return RepoResult.dependOn(response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
