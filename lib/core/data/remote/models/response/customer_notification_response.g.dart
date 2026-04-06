// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_notification_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerNotificationResponse _$CustomerNotificationResponseFromJson(
  Map<String, dynamic> json,
) => CustomerNotificationResponse(
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => CustomerNotificationItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CustomerNotificationResponseToJson(
  CustomerNotificationResponse instance,
) => <String, dynamic>{'data': instance.data?.map((e) => e.toJson()).toList()};

CustomerNotificationItem _$CustomerNotificationItemFromJson(
  Map<String, dynamic> json,
) => CustomerNotificationItem(
  type: json['type'] as String?,
  title: json['title'] == null
      ? null
      : ContentLocalizeData.fromJson(json['title'] as Map<String, dynamic>),
  message: json['message'] == null
      ? null
      : ContentLocalizeData.fromJson(json['message'] as Map<String, dynamic>),
  icon: json['icon'] as String?,
  createdAt: const DateTimeConverter().fromJson(json['created_at'] as String?),
);

Map<String, dynamic> _$CustomerNotificationItemToJson(
  CustomerNotificationItem instance,
) => <String, dynamic>{
  'type': instance.type,
  'title': instance.title?.toJson(),
  'message': instance.message?.toJson(),
  'icon': instance.icon,
  'created_at': const DateTimeConverter().toJson(instance.createdAt),
};
