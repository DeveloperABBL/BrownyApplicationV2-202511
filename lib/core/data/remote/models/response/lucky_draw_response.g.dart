// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lucky_draw_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LuckyDrawResponse _$LuckyDrawResponseFromJson(Map<String, dynamic> json) =>
    LuckyDrawResponse(
      type: json['type'] as String?,
      status: json['status'] as String?,
      step: json['step'] as String?,
      reward: LuckyDrawResponse._rewardFromJson(json['reward']),
      translations: (json['translations'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          LuckyDrawTranslationData.fromJson(e as Map<String, dynamic>),
        ),
      ),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$LuckyDrawResponseToJson(LuckyDrawResponse instance) =>
    <String, dynamic>{
      'type': instance.type,
      'status': instance.status,
      'step': instance.step,
      'reward': LuckyDrawResponse._rewardToJson(instance.reward),
      'translations': instance.translations,
      'message': instance.message,
    };

LuckyDrawReward _$LuckyDrawRewardFromJson(Map<String, dynamic> json) =>
    LuckyDrawReward(
      id: (json['id'] as num?)?.toInt(),
      type: json['type'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$LuckyDrawRewardToJson(LuckyDrawReward instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'name': instance.name,
    };

LuckyDrawTranslationData _$LuckyDrawTranslationDataFromJson(
  Map<String, dynamic> json,
) => LuckyDrawTranslationData(
  banner: json['banner'] as String?,
  title: json['title'] as String?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$LuckyDrawTranslationDataToJson(
  LuckyDrawTranslationData instance,
) => <String, dynamic>{
  'banner': instance.banner,
  'title': instance.title,
  'message': instance.message,
};
