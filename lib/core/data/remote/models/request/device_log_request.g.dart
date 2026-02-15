// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_log_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceLogRequest _$DeviceLogRequestFromJson(Map<String, dynamic> json) =>
    DeviceLogRequest(
      deviceIdentityId: json['device_identity_id'] as String,
      deviceModel: json['device_model'] as String,
      devicePlatform: json['device_platform'] as String,
      transactionToken: json['transaction_token'] as String?,
      notificationToken: json['notification_token'] as String?,
      appVersion: json['app_version'] as String,
      customerId: json['customer_id'] as String?,
    );

Map<String, dynamic> _$DeviceLogRequestToJson(DeviceLogRequest instance) =>
    <String, dynamic>{
      'device_identity_id': instance.deviceIdentityId,
      'device_model': instance.deviceModel,
      'device_platform': instance.devicePlatform,
      'transaction_token': instance.transactionToken,
      'notification_token': instance.notificationToken,
      'app_version': instance.appVersion,
      'customer_id': instance.customerId,
    };
