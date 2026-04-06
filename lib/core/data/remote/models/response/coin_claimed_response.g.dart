// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_claimed_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinClaimedResponse _$CoinClaimedResponseFromJson(Map<String, dynamic> json) =>
    CoinClaimedResponse(
      success: json['success'] as bool?,
      errorType: json['error_type'] as String?,
      message: json['message'] as String?,
      resStatus: json['status'] as bool?,
      data: json['data'] == null
          ? null
          : CoinClaimData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CoinClaimedResponseToJson(
  CoinClaimedResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'status': instance.resStatus,
  'data': instance.data?.toJson(),
};

CloinClaimedData _$CloinClaimedDataFromJson(Map<String, dynamic> json) =>
    CloinClaimedData(
      claimedAmount: json['claimed_amount'] as String?,
      streakDay: json['streak_day'] as String?,
      brownyCoin: json['browny_coin'] as String?,
      claimedDate: json['claimed_date'] as String?,
      popupImages: json['popup_images'] == null
          ? null
          : ContentLocalizeData.fromJson(
              json['popup_images'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$CloinClaimedDataToJson(CloinClaimedData instance) =>
    <String, dynamic>{
      'claimed_amount': instance.claimedAmount,
      'streak_day': instance.streakDay,
      'browny_coin': instance.brownyCoin,
      'claimed_date': instance.claimedDate,
      'popup_images': instance.popupImages?.toJson(),
    };
