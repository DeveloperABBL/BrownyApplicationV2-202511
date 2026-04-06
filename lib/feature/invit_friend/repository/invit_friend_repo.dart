import 'package:browny_applications_new/core/data/remote/models/response/referral_reward_response.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';
import 'package:browny_applications_new/feature/authentication/repository/customer_data_repo.dart';

mixin InvitFriendDataSourceMixin on CustomerDataSourceMixin {
  Future<RepoResult<ReferralRewardResponse>> fetchReferralReward(String? uuid);
}

class InvitFriendRepo extends CustomerDataRepo with InvitFriendDataSourceMixin {
  @override
  Future<RepoResult<ReferralRewardResponse>> fetchReferralReward(
    String? uuid,
  ) async {
    try {
      final response = await requireRemote.fetchReferralReward(
        {'customer_id': uuid},
      );
      return RepoResult.dependOn(response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
