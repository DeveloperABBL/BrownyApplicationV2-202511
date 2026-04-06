// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationPreferencesResponse _$NotificationPreferencesResponseFromJson(
  Map<String, dynamic> json,
) => NotificationPreferencesResponse(
  success: json['success'] as bool?,
  data: json['data'] == null
      ? null
      : NotificationPreferencesData.fromJson(
          json['data'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$NotificationPreferencesResponseToJson(
  NotificationPreferencesResponse instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

NotificationPreferencesData _$NotificationPreferencesDataFromJson(
  Map<String, dynamic> json,
) => NotificationPreferencesData(
  notifyGeneral: (json['notify_general'] as num?)?.toInt(),
  notifyPromotion: (json['notify_promotion'] as num?)?.toInt(),
  notifyNews: (json['notify_news'] as num?)?.toInt(),
  notifyMachineDone: (json['notify_machine_done'] as num?)?.toInt(),
);

Map<String, dynamic> _$NotificationPreferencesDataToJson(
  NotificationPreferencesData instance,
) => <String, dynamic>{
  'notify_general': instance.notifyGeneral,
  'notify_promotion': instance.notifyPromotion,
  'notify_news': instance.notifyNews,
  'notify_machine_done': instance.notifyMachineDone,
};
