// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_notification_preferences_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateNotificationPreferencesRequest
_$UpdateNotificationPreferencesRequestFromJson(Map<String, dynamic> json) =>
    UpdateNotificationPreferencesRequest(
      notifyMachineDone: json['notify_machine_done'] as bool,
      notifyNews: json['notify_news'] as bool,
      notifyPromotion: json['notify_promotion'] as bool,
    );

Map<String, dynamic> _$UpdateNotificationPreferencesRequestToJson(
  UpdateNotificationPreferencesRequest instance,
) => <String, dynamic>{
  'notify_machine_done': instance.notifyMachineDone,
  'notify_news': instance.notifyNews,
  'notify_promotion': instance.notifyPromotion,
};
