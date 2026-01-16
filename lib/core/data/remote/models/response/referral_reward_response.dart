import 'package:json_annotation/json_annotation.dart';
import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/introductions_response.dart';

part 'referral_reward_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// dart run build_runner watch (auto gen)
// **************************************************************************

@JsonSerializable(explicitToJson: true)
class ReferralRewardResponse extends BaseModelResponse {
  ReferralRewardResponse({
    this.terms,
    this.totalStep,
    this.rewards,
    this.nowStep,
    super.success,
    super.errorType,
    super.message,
  });

  @JsonKey(name: 'terms')
  final ContentLocalizeData? terms;

  @JsonKey(name: 'total_step')
  final int? totalStep;

  @JsonKey(name: 'rewards')
  final List<RewardItem>? rewards;

  @JsonKey(name: 'now_step')
  final int? nowStep;

  factory ReferralRewardResponse.fromJson(Map<String, dynamic> json) =>
      _$ReferralRewardResponseFromJson(json);
  Map<String, dynamic> toJson() =>
      baseToJson(_$ReferralRewardResponseToJson(this));
}

@JsonSerializable(explicitToJson: true)
class RewardItem {
  RewardItem({
    this.step,
    this.icon,
    this.type,
    this.name,
    this.description,
    this.image,
    this.expire,
  });

  @JsonKey(name: 'step')
  final int? step;

  @JsonKey(name: 'icon')
  final String? icon;

  @JsonKey(name: 'type')
  final ContentLocalizeData? type;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  @JsonKey(name: 'description')
  final ContentLocalizeData? description;

  @JsonKey(name: 'image')
  final ContentLocalizeData? image;

  @JsonKey(name: 'expire')
  final ContentLocalizeData? expire;

  factory RewardItem.fromJson(Map<String, dynamic> json) =>
      _$RewardItemFromJson(json);
  Map<String, dynamic> toJson() => _$RewardItemToJson(this);
}
