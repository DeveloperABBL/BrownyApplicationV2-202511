// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_notification_preferences_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateNotificationPreferencesResponse
_$UpdateNotificationPreferencesResponseFromJson(Map<String, dynamic> json) =>
    UpdateNotificationPreferencesResponse(
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : UpdateNotificationPreferencesData.fromJson(
              json['data'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$UpdateNotificationPreferencesResponseToJson(
  UpdateNotificationPreferencesResponse instance,
) => <String, dynamic>{'message': instance.message, 'data': instance.data};

UpdateNotificationPreferencesData _$UpdateNotificationPreferencesDataFromJson(
  Map<String, dynamic> json,
) => UpdateNotificationPreferencesData(
  notifyMachineDone: json['notify_machine_done'] as bool?,
  notifyNews: json['notify_news'] as bool?,
  notifyPromotion: json['notify_promotion'] as bool?,
);

Map<String, dynamic> _$UpdateNotificationPreferencesDataToJson(
  UpdateNotificationPreferencesData instance,
) => <String, dynamic>{
  'notify_machine_done': instance.notifyMachineDone,
  'notify_news': instance.notifyNews,
  'notify_promotion': instance.notifyPromotion,
};
