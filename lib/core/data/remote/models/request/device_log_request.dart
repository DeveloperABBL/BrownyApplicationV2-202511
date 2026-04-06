import 'package:json_annotation/json_annotation.dart';

part 'device_log_request.g.dart';

/// Request model สำหรับบันทึกข้อมูลอุปกรณ์เข้า backend
@JsonSerializable()
class DeviceLogRequest {
  /// Device unique identifier (IDFA for iOS, Advertising ID for Android)
  @JsonKey(name: 'device_identity_id')
  final String deviceIdentityId;

  /// รุ่นของอุปกรณ์ (เช่น "iPhone 14 Pro", "Samsung Galaxy S23")
  @JsonKey(name: 'device_model')
  final String deviceModel;

  /// Platform ของอุปกรณ์ ("IOS" หรือ "ANDROID")
  @JsonKey(name: 'device_platform')
  final String devicePlatform;

  /// Transaction token สำหรับ Apple/Google Payment
  @JsonKey(name: 'transaction_token')
  final String? transactionToken;

  /// FCM/APNs notification token
  @JsonKey(name: 'notification_token')
  final String? notificationToken;

  /// เวอร์ชันของแอป (เช่น "3.0.0")
  @JsonKey(name: 'app_version')
  final String appVersion;

  /// UUID ของ customer (nullable สำหรับผู้ใช้ที่ยังไม่ได้ login)
  @JsonKey(name: 'customer_id')
  final String? customerId;

  DeviceLogRequest({
    required this.deviceIdentityId,
    required this.deviceModel,
    required this.devicePlatform,
    this.transactionToken,
    this.notificationToken,
    required this.appVersion,
    this.customerId,
  });

  factory DeviceLogRequest.fromJson(Map<String, dynamic> json) =>
      _$DeviceLogRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceLogRequestToJson(this);
}
