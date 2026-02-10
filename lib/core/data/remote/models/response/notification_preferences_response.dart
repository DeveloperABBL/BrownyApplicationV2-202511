import 'package:json_annotation/json_annotation.dart';

part 'notification_preferences_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class NotificationPreferencesResponse {
  @JsonKey(name: 'notify_machine_done')
  final int? notifyMachineDone;

  @JsonKey(name: 'notify_news')
  final int? notifyNews;

  @JsonKey(name: 'notify_promotion')
  final int? notifyPromotion;

  NotificationPreferencesResponse({
    this.notifyMachineDone,
    this.notifyNews,
    this.notifyPromotion,
  });

  factory NotificationPreferencesResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$NotificationPreferencesResponseFromJson(json);
  Map<String, dynamic> toJson() =>
      _$NotificationPreferencesResponseToJson(this);
}
