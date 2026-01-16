import 'package:browny_applications_new/core/data/remote/models/response/introductions_response.dart';
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

  factory CoinClaimData.fromJson(Map<String, dynamic> json) =>
      _$CoinClaimDataFromJson(json);
  Map<String, dynamic> toJson() => _$CoinClaimDataToJson(this);
}

@JsonSerializable()
class StreakItem {
  StreakItem({
    this.day,
    this.amount,
    this.highlight,
    this.claimedAt,
  });

  @JsonKey(name: 'day')
  final int? day;

  @JsonKey(name: 'amount')
  final double? amount;

  @JsonKey(name: 'highlight')
  final bool? highlight;

  @JsonKey(name: 'claimed_at')
  final String? claimedAt;

  factory StreakItem.fromJson(Map<String, dynamic> json) =>
      _$StreakItemFromJson(json);
  Map<String, dynamic> toJson() => _$StreakItemToJson(this);
}
