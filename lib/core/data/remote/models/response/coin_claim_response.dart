import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';

part 'coin_claim_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// dart run build_runner watch (auto gen)
// **************************************************************************

@JsonSerializable(explicitToJson: true)
class CoinClaimResponse extends BaseModelResponse {
  CoinClaimResponse({
    this.data,
    super.success,
    super.errorType,
    super.message,
  });

  @JsonKey(name: 'data')
  final CoinClaimData? data;

  factory CoinClaimResponse.fromJson(Map<String, dynamic> json) =>
      _$CoinClaimResponseFromJson(json);
  Map<String, dynamic> toJson() => baseToJson(_$CoinClaimResponseToJson(this));
}

@JsonSerializable(explicitToJson: true)
class CoinClaimData {
  CoinClaimData({
    this.customerId,
    this.streakDay,
    this.lastClaimedDate,
    this.claimableToday,
    this.nextDay,
    this.targetDay,
    this.todayAmount,
    this.maxDay,
    this.streaks,
    this.banners,
    this.todayHighlight,
    this.todayCalendarDate,
    this.defaultDailyCoin,
    this.popupImages,
    this.popupDetails,
    this.coinSettings,
  });

  @JsonKey(name: 'customer_id')
  final String? customerId;

  @JsonKey(name: 'streak_day')
  final int? streakDay;

  @JsonKey(name: 'last_claimed_date')
  final String? lastClaimedDate;

  @JsonKey(name: 'claimable_today')
  final bool? claimableToday;

  @JsonKey(name: 'next_day')
  final int? nextDay;

  @JsonKey(name: 'target_day')
  final int? targetDay;

  @JsonKey(name: 'today_amount')
  final double? todayAmount;

  @JsonKey(name: 'max_day')
  final int? maxDay;

  @JsonKey(name: 'streaks')
  final List<StreakItem>? streaks;

  @JsonKey(name: 'banners')
  final ContentLocalizeData? banners;

  @JsonKey(name: 'today_highlight')
  final bool? todayHighlight;

  @JsonKey(name: 'today_calendar_date')
  final String? todayCalendarDate;

  @JsonKey(name: 'default_daily_coin')
  final double? defaultDailyCoin;

  @JsonKey(name: 'popup_images')
  final ContentLocalizeData? popupImages;

  @JsonKey(name: 'popup_details')
  final ContentLocalizeData? popupDetails;

  @JsonKey(name: 'coin_settings')
  final CoinSettings? coinSettings;

  factory CoinClaimData.fromJson(Map<String, dynamic> json) =>
      _$CoinClaimDataFromJson(json);
  Map<String, dynamic> toJson() => _$CoinClaimDataToJson(this);
}

@JsonSerializable()
class StreakItem {
  StreakItem({
    this.day,
    this.calendarDate,
    this.amount,
    this.highlight,
    this.isCustom,
    this.claimedAt,
  });

  @JsonKey(name: 'day', fromJson: _dayFromJson)
  final String? day;

  @JsonKey(name: 'calendar_date')
  final String? calendarDate;

  @JsonKey(name: 'amount')
  final double? amount;

  @JsonKey(name: 'highlight')
  final bool? highlight;

  @JsonKey(name: 'is_custom')
  final bool? isCustom;

  @JsonKey(name: 'claimed_at')
  final String? claimedAt;

  static String? _dayFromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is num) return value.toInt().toString();
    return value.toString();
  }

  factory StreakItem.fromJson(Map<String, dynamic> json) =>
      _$StreakItemFromJson(json);
  Map<String, dynamic> toJson() => _$StreakItemToJson(this);
}

@JsonSerializable()
class CoinSettings {
  CoinSettings({
    this.enableLoginFirst,
    this.loginFirstCoin,
    this.enableTopup,
    this.topupCoin,
    this.topupCoinMin,
    this.enableWashDry,
    this.washDryCoin,
    this.washDryCoinMin,
    this.defaultDailyCoin,
  });

  @JsonKey(name: 'enable_login_first')
  final bool? enableLoginFirst;

  @JsonKey(name: 'login_first_coin')
  final double? loginFirstCoin;

  @JsonKey(name: 'enable_topup')
  final bool? enableTopup;

  @JsonKey(name: 'topup_coin')
  final double? topupCoin;

  @JsonKey(name: 'topup_coin_min')
  final double? topupCoinMin;

  @JsonKey(name: 'enable_wash_dry')
  final bool? enableWashDry;

  @JsonKey(name: 'wash_dry_coin')
  final double? washDryCoin;

  @JsonKey(name: 'wash_dry_coin_min')
  final double? washDryCoinMin;

  @JsonKey(name: 'default_daily_coin')
  final double? defaultDailyCoin;

  factory CoinSettings.fromJson(Map<String, dynamic> json) =>
      _$CoinSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$CoinSettingsToJson(this);
}
