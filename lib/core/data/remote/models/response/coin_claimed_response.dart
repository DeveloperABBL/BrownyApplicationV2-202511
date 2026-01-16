import 'package:browny_applications_new/core/data/remote/models/response/coin_claim_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/introductions_response.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';

part 'coin_claimed_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// dart run build_runner watch (auto gen)
// **************************************************************************

@JsonSerializable(explicitToJson: true)
class CoinClaimedResponse extends BaseModelResponse {
  CoinClaimedResponse({
    super.success,
    super.errorType,
    super.message,
    this.resStatus,
    this.data,
  });

  @JsonKey(name: 'status')
  final bool? resStatus;

  @JsonKey(name: 'data')
  final CoinClaimData? data;

  factory CoinClaimedResponse.fromJson(Map<String, dynamic> json) =>
      _$CoinClaimedResponseFromJson(json);
  Map<String, dynamic> toJson() =>
      baseToJson(_$CoinClaimedResponseToJson(this));
}

@JsonSerializable(explicitToJson: true)
class CloinClaimedData {
  CloinClaimedData({
    required this.claimedAmount,
    required this.streakDay,
    required this.brownyCoin,
    required this.claimedDate,
    required this.popupImages,
  });

  @JsonKey(name: 'claimed_amount')
  final String? claimedAmount;

  @JsonKey(name: 'streak_day')
  final String? streakDay;

  @JsonKey(name: 'browny_coin')
  final String? brownyCoin;

  @JsonKey(name: 'claimed_date')
  final String? claimedDate;

  @JsonKey(name: 'popup_images')
  final ContentLocalizeData? popupImages;

  factory CloinClaimedData.fromJson(Map<String, dynamic> json) =>
      _$CloinClaimedDataFromJson(json);

  Map<String, dynamic> toJson() => _$CloinClaimedDataToJson(this);
}
