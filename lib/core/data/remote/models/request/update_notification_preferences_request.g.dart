// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_notification_preferences_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateNotificationPreferencesRequest
_$UpdateNotificationPreferencesRequestFromJson(Map<String, dynamic> json) =>
    UpdateNotificationPreferencesRequest(
      notifyGeneral: json['notify_general'] as bool,
      notifyNews: json['notify_news'] as bool,
      notifyPromotion: json['notify_promotion'] as bool,
      notifyMachineDone: json['notify_machine_done'] as bool,
    );

Map<String, dynamic> _$UpdateNotificationPreferencesRequestToJson(
  UpdateNotificationPreferencesRequest instance,
) => <String, dynamic>{
  'notify_general': instance.notifyGeneral,
  'notify_news': instance.notifyNews,
  'notify_promotion': instance.notifyPromotion,
  'notify_machine_done': instance.notifyMachineDone,
};
