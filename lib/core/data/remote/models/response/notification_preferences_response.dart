import 'package:json_annotation/json_annotation.dart';

part 'notification_preferences_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class NotificationPreferencesResponse {
  @JsonKey(name: 'success')
  final bool? success;

  @JsonKey(name: 'data')
  final NotificationPreferencesData? data;

  NotificationPreferencesResponse({
    this.success,
    this.data,
  });

  factory NotificationPreferencesResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$NotificationPreferencesResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$NotificationPreferencesResponseToJson(this);
}

@JsonSerializable()
class NotificationPreferencesData {
  @JsonKey(name: 'notify_general')
  final int? notifyGeneral;

  @JsonKey(name: 'notify_promotion')
  final int? notifyPromotion;

  @JsonKey(name: 'notify_news')
  final int? notifyNews;

  @JsonKey(name: 'notify_machine_done')
  final int? notifyMachineDone;

  NotificationPreferencesData({
    this.notifyGeneral,
    this.notifyPromotion,
    this.notifyNews,
    this.notifyMachineDone,
  });

  factory NotificationPreferencesData.fromJson(
    Map<String, dynamic> json,
  ) => _$NotificationPreferencesDataFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPreferencesDataToJson(this);
}
