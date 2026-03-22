import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/json_converters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'festive_history_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class FestiveHistoryResponse {
  FestiveHistoryResponse({
    this.status,
    this.data,
  });

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'data')
  final List<FestiveHistoryData>? data;

  factory FestiveHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$FestiveHistoryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FestiveHistoryResponseToJson(this);
}

@JsonSerializable()
class FestiveHistoryData {
  FestiveHistoryData({
    this.id,
    this.festiveCode,
    this.eventId,
    this.title,
    this.type,
    this.reward,
    this.createdAt,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'festive_code')
  final String? festiveCode;

  @JsonKey(name: 'event_id')
  final int? eventId;

  @JsonKey(name: 'title')
  final ContentLocalizeData? title;

  /// ประเภทผลลัพธ์: "won", "lose", "limit_reached", "scanned_today"
  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'reward', fromJson: _rewardFromJson, toJson: _rewardToJson)
  final FestiveHistoryReward? reward;

  @DateTimeConverter()
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  static FestiveHistoryReward? _rewardFromJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      return FestiveHistoryReward.fromJson(value);
    }
    return null;
  }

  static dynamic _rewardToJson(FestiveHistoryReward? reward) =>
      reward?.toJson() ?? [];

  /// ดึง title ตาม locale
  String getTitleDisplay(String locale) => title?.getByLocaleCode(locale) ?? '';

  String getCreateAtDisplay(String locale) {
    String prefix = '';
    if (locale == 'th') {
      prefix = 'วันที่ ';
    }
    return createdAt?.formatDateLocale(
          locale,
          pattern: '${prefix}dd MMM yyyy',
        ) ??
        '-';
  }

  /// ได้รับรางวัล
  bool get isWon => type == 'won';

  factory FestiveHistoryData.fromJson(Map<String, dynamic> json) =>
      _$FestiveHistoryDataFromJson(json);
  Map<String, dynamic> toJson() => _$FestiveHistoryDataToJson(this);
}

@JsonSerializable()
class FestiveHistoryReward {
  FestiveHistoryReward({
    this.id,
    this.name,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  factory FestiveHistoryReward.fromJson(Map<String, dynamic> json) =>
      _$FestiveHistoryRewardFromJson(json);
  Map<String, dynamic> toJson() => _$FestiveHistoryRewardToJson(this);
}
