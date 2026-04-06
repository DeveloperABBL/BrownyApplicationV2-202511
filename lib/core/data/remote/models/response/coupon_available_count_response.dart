import 'package:browny_applications_new/core/core_index.dart';
import 'package:json_annotation/json_annotation.dart';

part 'coupon_available_count_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class CouponAvailableCountResponse {
  @JsonKey(name: 'data')
  final CouponAvailableCountData? data;

  CouponAvailableCountResponse({this.data});

  factory CouponAvailableCountResponse.fromJson(Map<String, dynamic> json) =>
      _$CouponAvailableCountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CouponAvailableCountResponseToJson(this);
}

@JsonSerializable()
class CouponAvailableCountData {
  @JsonKey(name: 'coupons')
  final CouponsCount? coupons;

  @JsonKey(name: 'total')
  final int? total;

  @JsonKey(name: 'credit_balance')
  final String? creditBalance;

  @JsonKey(name: 'browny_coin')
  final int? brownyCoin;

  CouponAvailableCountData({
    this.coupons,
    this.total,
    this.creditBalance,
    this.brownyCoin,
  });

  factory CouponAvailableCountData.fromJson(Map<String, dynamic> json) =>
      _$CouponAvailableCountDataFromJson(json);

  Map<String, dynamic> toJson() => _$CouponAvailableCountDataToJson(this);
}

@JsonSerializable()
class CouponsCount {
  @JsonKey(name: 'redemption')
  final int? redemption;

  @JsonKey(name: 'discount')
  final int? discount;

  @JsonKey(name: 'e_voucher')
  final String? _eVoucher;

  int get eVoucher => int.tryParse(_eVoucher.orEmpty.ifNullOrEmpty('0')) ?? 0;

  CouponsCount({
    this.redemption,
    this.discount,
    String? eVoucher,
  }) : _eVoucher = eVoucher;

  factory CouponsCount.fromJson(Map<String, dynamic> json) =>
      _$CouponsCountFromJson(json);

  Map<String, dynamic> toJson() => _$CouponsCountToJson(this);
}
