// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'festive_history_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FestiveHistoryResponse _$FestiveHistoryResponseFromJson(
  Map<String, dynamic> json,
) => FestiveHistoryResponse(
  status: json['status'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => FestiveHistoryData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FestiveHistoryResponseToJson(
  FestiveHistoryResponse instance,
) => <String, dynamic>{'status': instance.status, 'data': instance.data};

FestiveHistoryData _$FestiveHistoryDataFromJson(Map<String, dynamic> json) =>
    FestiveHistoryData(
      id: (json['id'] as num?)?.toInt(),
      festiveCode: json['festive_code'] as String?,
      eventId: (json['event_id'] as num?)?.toInt(),
      title: json['title'] == null
          ? null
          : ContentLocalizeData.fromJson(json['title'] as Map<String, dynamic>),
      type: json['type'] as String?,
      reward: FestiveHistoryData._rewardFromJson(json['reward']),
      createdAt: const DateTimeConverter().fromJson(
        json['created_at'] as String?,
      ),
    );

Map<String, dynamic> _$FestiveHistoryDataToJson(FestiveHistoryData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'festive_code': instance.festiveCode,
      'event_id': instance.eventId,
      'title': instance.title,
      'type': instance.type,
      'reward': FestiveHistoryData._rewardToJson(instance.reward),
      'created_at': const DateTimeConverter().toJson(instance.createdAt),
    };

FestiveHistoryReward _$FestiveHistoryRewardFromJson(
  Map<String, dynamic> json,
) => FestiveHistoryReward(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
);

Map<String, dynamic> _$FestiveHistoryRewardToJson(
  FestiveHistoryReward instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};
