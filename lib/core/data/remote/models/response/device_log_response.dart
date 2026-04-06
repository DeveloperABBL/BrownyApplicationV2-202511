import 'package:json_annotation/json_annotation.dart';

part 'device_log_response.g.dart';

/// Response model สำหรับ API บันทึกข้อมูลอุปกรณ์
@JsonSerializable()
class DeviceLogResponse {
  /// สถานะความสำเร็จของการบันทึก
  @JsonKey(name: 'success')
  final bool success;

  /// ข้อความตอบกลับ
  @JsonKey(name: 'message')
  final String message;

  /// ข้อมูลอุปกรณ์ที่บันทึกแล้ว
  @JsonKey(name: 'data')
  final DeviceLogData? data;

  DeviceLogResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DeviceLogResponse.fromJson(Map<String, dynamic> json) =>
      _$DeviceLogResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceLogResponseToJson(this);
}

/// ข้อมูลอุปกรณ์ที่ถูกบันทึกใน backend
@JsonSerializable()
class DeviceLogData {
  /// ID ของข้อมูลอุปกรณ์ใน database
  @JsonKey(name: 'id')
  final String id;

  /// รุ่นของอุปกรณ์
  @JsonKey(name: 'device_model')
  final String deviceModel;

  /// Platform ของอุปกรณ์
  @JsonKey(name: 'device_platform')
  final String devicePlatform;

  /// Device unique identifier
  @JsonKey(name: 'device_identity_id')
  final String deviceIdentityId;

  /// Transaction token
  @JsonKey(name: 'transaction_token')
  final String? transactionToken;

  /// Notification token
  @JsonKey(name: 'notification_token')
  final String? notificationToken;

  /// App version
  @JsonKey(name: 'app_version')
  final String appVersion;

  /// Customer UUID
  @JsonKey(name: 'customer_id')
  final String? customerId;

  /// วันที่สร้างข้อมูล
  @JsonKey(name: 'created_at')
  final String createdAt;

  /// วันที่แก้ไขข้อมูลล่าสุด
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  DeviceLogData({
    required this.id,
    required this.deviceModel,
    required this.devicePlatform,
    required this.deviceIdentityId,
    this.transactionToken,
    this.notificationToken,
    required this.appVersion,
    this.customerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeviceLogData.fromJson(Map<String, dynamic> json) =>
      _$DeviceLogDataFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceLogDataToJson(this);
}
