// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationPreferencesResponse _$NotificationPreferencesResponseFromJson(
  Map<String, dynamic> json,
) => NotificationPreferencesResponse(
  notifyMachineDone: (json['notify_machine_done'] as num?)?.toInt(),
  notifyNews: (json['notify_news'] as num?)?.toInt(),
  notifyPromotion: (json['notify_promotion'] as num?)?.toInt(),
);

Map<String, dynamic> _$NotificationPreferencesResponseToJson(
  NotificationPreferencesResponse instance,
) => <String, dynamic>{
  'notify_machine_done': instance.notifyMachineDone,
  'notify_news': instance.notifyNews,
  'notify_promotion': instance.notifyPromotion,
};
