import 'package:json_annotation/json_annotation.dart';

part 'update_notification_preferences_request.g.dart';

/// Request model สำหรับอัพเดทการตั้งค่าการแจ้งเตือน
@JsonSerializable()
class UpdateNotificationPreferencesRequest {
  @JsonKey(name: 'notify_machine_done')
  final bool notifyMachineDone;

  @JsonKey(name: 'notify_news')
  final bool notifyNews;

  @JsonKey(name: 'notify_promotion')
  final bool notifyPromotion;

  UpdateNotificationPreferencesRequest({
    required this.notifyMachineDone,
    required this.notifyNews,
    required this.notifyPromotion,
  });

  factory UpdateNotificationPreferencesRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$UpdateNotificationPreferencesRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$UpdateNotificationPreferencesRequestToJson(this);
}
