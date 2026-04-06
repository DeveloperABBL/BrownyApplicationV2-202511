// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_reward_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferralRewardResponse _$ReferralRewardResponseFromJson(
  Map<String, dynamic> json,
) => ReferralRewardResponse(
  terms: json['terms'] == null
      ? null
      : ContentLocalizeData.fromJson(json['terms'] as Map<String, dynamic>),
  totalStep: (json['total_step'] as num?)?.toInt(),
  rewards: (json['rewards'] as List<dynamic>?)
      ?.map((e) => RewardItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  nowStep: (json['now_step'] as num?)?.toInt(),
  success: json['success'] as bool?,
  errorType: json['error_type'] as String?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$ReferralRewardResponseToJson(
  ReferralRewardResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'terms': instance.terms,
  'total_step': instance.totalStep,
  'rewards': instance.rewards,
  'now_step': instance.nowStep,
};

RewardItem _$RewardItemFromJson(Map<String, dynamic> json) => RewardItem(
  step: (json['step'] as num?)?.toInt(),
  icon: json['icon'] as String?,
  type: json['type'] == null
      ? null
      : ContentLocalizeData.fromJson(json['type'] as Map<String, dynamic>),
  name: json['name'] == null
      ? null
      : ContentLocalizeData.fromJson(json['name'] as Map<String, dynamic>),
  description: json['description'] == null
      ? null
      : ContentLocalizeData.fromJson(
          json['description'] as Map<String, dynamic>,
        ),
  image: json['image'] == null
      ? null
      : ContentLocalizeData.fromJson(json['image'] as Map<String, dynamic>),
  expire: json['expire'] == null
      ? null
      : ContentLocalizeData.fromJson(json['expire'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RewardItemToJson(RewardItem instance) =>
    <String, dynamic>{
      'step': instance.step,
      'icon': instance.icon,
      'type': instance.type?.toJson(),
      'name': instance.name?.toJson(),
      'description': instance.description?.toJson(),
      'image': instance.image?.toJson(),
      'expire': instance.expire?.toJson(),
    };
