// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_claim_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinClaimResponse _$CoinClaimResponseFromJson(Map<String, dynamic> json) =>
    CoinClaimResponse(
      data: json['data'] == null
          ? null
          : CoinClaimData.fromJson(json['data'] as Map<String, dynamic>),
      success: json['success'] as bool?,
      errorType: json['error_type'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$CoinClaimResponseToJson(CoinClaimResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'error_type': instance.errorType,
      'data': instance.data?.toJson(),
    };

CoinClaimData _$CoinClaimDataFromJson(
  Map<String, dynamic> json,
) => CoinClaimData(
  customerId: json['customer_id'] as String?,
  streakDay: (json['streak_day'] as num?)?.toInt(),
  lastClaimedDate: json['last_claimed_date'] as String?,
  claimableToday: json['claimable_today'] as bool?,
  nextDay: (json['next_day'] as num?)?.toInt(),
  targetDay: (json['target_day'] as num?)?.toInt(),
  todayAmount: (json['today_amount'] as num?)?.toDouble(),
  maxDay: (json['max_day'] as num?)?.toInt(),
  streaks: (json['streaks'] as List<dynamic>?)
      ?.map((e) => StreakItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  banners: json['banners'] == null
      ? null
      : ContentLocalizeData.fromJson(json['banners'] as Map<String, dynamic>),
  todayHighlight: json['today_highlight'] as bool?,
  todayCalendarDate: json['today_calendar_date'] as String?,
  defaultDailyCoin: (json['default_daily_coin'] as num?)?.toDouble(),
  popupImages: json['popup_images'] == null
      ? null
      : ContentLocalizeData.fromJson(
          json['popup_images'] as Map<String, dynamic>,
        ),
  popupDetails: json['popup_details'] == null
      ? null
      : ContentLocalizeData.fromJson(
          json['popup_details'] as Map<String, dynamic>,
        ),
  coinSettings: json['coin_settings'] == null
      ? null
      : CoinSettings.fromJson(json['coin_settings'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CoinClaimDataToJson(CoinClaimData instance) =>
    <String, dynamic>{
      'customer_id': instance.customerId,
      'streak_day': instance.streakDay,
      'last_claimed_date': instance.lastClaimedDate,
      'claimable_today': instance.claimableToday,
      'next_day': instance.nextDay,
      'target_day': instance.targetDay,
      'today_amount': instance.todayAmount,
      'max_day': instance.maxDay,
      'streaks': instance.streaks?.map((e) => e.toJson()).toList(),
      'banners': instance.banners?.toJson(),
      'today_highlight': instance.todayHighlight,
      'today_calendar_date': instance.todayCalendarDate,
      'default_daily_coin': instance.defaultDailyCoin,
      'popup_images': instance.popupImages?.toJson(),
      'popup_details': instance.popupDetails?.toJson(),
      'coin_settings': instance.coinSettings?.toJson(),
    };

StreakItem _$StreakItemFromJson(Map<String, dynamic> json) => StreakItem(
  day: StreakItem._dayFromJson(json['day']),
  calendarDate: json['calendar_date'] as String?,
  amount: (json['amount'] as num?)?.toDouble(),
  highlight: json['highlight'] as bool?,
  isCustom: json['is_custom'] as bool?,
  claimedAt: json['claimed_at'] as String?,
);

Map<String, dynamic> _$StreakItemToJson(StreakItem instance) =>
    <String, dynamic>{
      'day': instance.day,
      'calendar_date': instance.calendarDate,
      'amount': instance.amount,
      'highlight': instance.highlight,
      'is_custom': instance.isCustom,
      'claimed_at': instance.claimedAt,
    };

CoinSettings _$CoinSettingsFromJson(Map<String, dynamic> json) => CoinSettings(
  enableLoginFirst: json['enable_login_first'] as bool?,
  loginFirstCoin: (json['login_first_coin'] as num?)?.toDouble(),
  enableTopup: json['enable_topup'] as bool?,
  topupCoin: (json['topup_coin'] as num?)?.toDouble(),
  topupCoinMin: (json['topup_coin_min'] as num?)?.toDouble(),
  enableWashDry: json['enable_wash_dry'] as bool?,
  washDryCoin: (json['wash_dry_coin'] as num?)?.toDouble(),
  washDryCoinMin: (json['wash_dry_coin_min'] as num?)?.toDouble(),
  defaultDailyCoin: (json['default_daily_coin'] as num?)?.toDouble(),
);

Map<String, dynamic> _$CoinSettingsToJson(CoinSettings instance) =>
    <String, dynamic>{
      'enable_login_first': instance.enableLoginFirst,
      'login_first_coin': instance.loginFirstCoin,
      'enable_topup': instance.enableTopup,
      'topup_coin': instance.topupCoin,
      'topup_coin_min': instance.topupCoinMin,
      'enable_wash_dry': instance.enableWashDry,
      'wash_dry_coin': instance.washDryCoin,
      'wash_dry_coin_min': instance.washDryCoinMin,
      'default_daily_coin': instance.defaultDailyCoin,
    };
