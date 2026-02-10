import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/utils/json_converters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'customer_notification_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable(explicitToJson: true)
class CustomerNotificationResponse {
  @JsonKey(name: 'data')
  final List<CustomerNotificationItem>? data;

  CustomerNotificationResponse({this.data});

  factory CustomerNotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$CustomerNotificationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerNotificationResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CustomerNotificationItem {
  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'title')
  final ContentLocalizeData? title;

  @JsonKey(name: 'message')
  final ContentLocalizeData? message;

  @JsonKey(name: 'icon')
  final String? icon;

  @JsonKey(name: 'created_at')
  @DateTimeConverter()
  final DateTime? createdAt;

  CustomerNotificationItem({
    this.type,
    this.title,
    this.message,
    this.icon,
    this.createdAt,
  });

  factory CustomerNotificationItem.fromJson(Map<String, dynamic> json) =>
      _$CustomerNotificationItemFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerNotificationItemToJson(this);
}
