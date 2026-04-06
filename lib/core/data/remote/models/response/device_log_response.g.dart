// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_log_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceLogResponse _$DeviceLogResponseFromJson(Map<String, dynamic> json) =>
    DeviceLogResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] == null
          ? null
          : DeviceLogData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DeviceLogResponseToJson(DeviceLogResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

DeviceLogData _$DeviceLogDataFromJson(Map<String, dynamic> json) =>
    DeviceLogData(
      id: json['id'] as String,
      deviceModel: json['device_model'] as String,
      devicePlatform: json['device_platform'] as String,
      deviceIdentityId: json['device_identity_id'] as String,
      transactionToken: json['transaction_token'] as String?,
      notificationToken: json['notification_token'] as String?,
      appVersion: json['app_version'] as String,
      customerId: json['customer_id'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$DeviceLogDataToJson(DeviceLogData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'device_model': instance.deviceModel,
      'device_platform': instance.devicePlatform,
      'device_identity_id': instance.deviceIdentityId,
      'transaction_token': instance.transactionToken,
      'notification_token': instance.notificationToken,
      'app_version': instance.appVersion,
      'customer_id': instance.customerId,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
