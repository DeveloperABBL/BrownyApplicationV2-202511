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

CoinClaimData _$CoinClaimDataFromJson(Map<String, dynamic> json) =>
    CoinClaimData(
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
          : ContentLocalizeData.fromJson(
              json['banners'] as Map<String, dynamic>,
            ),
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
    };

StreakItem _$StreakItemFromJson(Map<String, dynamic> json) => StreakItem(
  day: (json['day'] as num?)?.toInt(),
  amount: (json['amount'] as num?)?.toDouble(),
  highlight: json['highlight'] as bool?,
  claimedAt: json['claimed_at'] as String?,
);

Map<String, dynamic> _$StreakItemToJson(StreakItem instance) =>
    <String, dynamic>{
      'day': instance.day,
      'amount': instance.amount,
      'highlight': instance.highlight,
      'claimed_at': instance.claimedAt,
    };
