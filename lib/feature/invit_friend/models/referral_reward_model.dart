import 'package:browny_applications_new/core/data/remote/models/response/referral_reward_response.dart';

class ReferralRewardModel extends ReferralRewardResponse {
  factory ReferralRewardModel.fromResponse(
    ReferralRewardResponse response,
    String locale,
  ) {
    final refRData = List.generate(
      (response.totalStep ?? 0),
      (index) => ReferralRewardData(
        active: response.nowStep! > 0 && response.nowStep! >= index,
        isReward: response.rewards!.where((e) => e.step! == index).isNotEmpty,
      ),
    );

    return ReferralRewardModel(
      locale: locale,
      rewardDisplay:
          response.rewards
              ?.map((item) => RewardModel.fromRewardItem(item, locale))
              .toList() ??
          [],
      referralRewardData: refRData,
      terms: response.terms,
      totalStep: response.totalStep,
      rewards: response.rewards,
      nowStep: response.nowStep,
    );
  }

  final String locale;
  final List<ReferralRewardData> referralRewardData;
  final List<RewardModel> rewardDisplay;

  ReferralRewardModel({
    required this.locale,
    required this.rewardDisplay,
    required this.referralRewardData,
    super.terms,
    super.totalStep,
    super.rewards,
    super.nowStep,
  });

  String get termsDisplay => super.terms?.getByLocaleCode(locale) ?? '';
  int get nowStepDisplay => super.nowStep ?? -1;
}

class ReferralRewardData {
  final bool active;
  final bool isReward;

  ReferralRewardData({
    required this.active,
    required this.isReward,
  });
}

class RewardModel extends RewardItem {
  final String local;

  RewardModel({
    required this.local,
    super.step,
    super.icon,
    super.type,
    super.name,
    super.description,
    super.image,
    super.expire,
  });

  factory RewardModel.fromRewardItem(RewardItem item, String locale) {
    return RewardModel(
      local: locale,
      type: item.type,
      name: item.name,
      description: item.description,
      image: item.image,
      expire: item.expire,
    );
  }

  String get typeDisplay => super.type?.getByLocaleCode(local) ?? '';
  String get nameDisplay => super.name?.getByLocaleCode(local) ?? '';
  String get descriptionDisplay =>
      super.description?.getByLocaleCode(local) ?? '';
  String get imageDisplay => super.image?.getByLocaleCode(local) ?? '';
  String get expireDisplay => super.expire?.getByLocaleCode(local) ?? '';
}
