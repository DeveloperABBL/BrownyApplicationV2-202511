import 'package:json_annotation/json_annotation.dart';

part 'update_notification_preferences_response.g.dart';

/// Response model สำหรับอัพเดทการตั้งค่าการแจ้งเตือน
@JsonSerializable()
class UpdateNotificationPreferencesResponse {
  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'data')
  final NotificationPreferencesData? data;

  UpdateNotificationPreferencesResponse({
    this.message,
    this.data,
  });

  factory UpdateNotificationPreferencesResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$UpdateNotificationPreferencesResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$UpdateNotificationPreferencesResponseToJson(this);
}

@JsonSerializable()
class NotificationPreferencesData {
  @JsonKey(name: 'notify_machine_done')
  final bool? notifyMachineDone;

  @JsonKey(name: 'notify_news')
  final bool? notifyNews;

  @JsonKey(name: 'notify_promotion')
  final bool? notifyPromotion;

  NotificationPreferencesData({
    this.notifyMachineDone,
    this.notifyNews,
    this.notifyPromotion,
  });

  factory NotificationPreferencesData.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesDataFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPreferencesDataToJson(this);
}
