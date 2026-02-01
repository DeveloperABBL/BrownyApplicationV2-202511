// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_available_count_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CouponAvailableCountResponse _$CouponAvailableCountResponseFromJson(
  Map<String, dynamic> json,
) => CouponAvailableCountResponse(
  data: json['data'] == null
      ? null
      : CouponAvailableCountData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CouponAvailableCountResponseToJson(
  CouponAvailableCountResponse instance,
) => <String, dynamic>{'data': instance.data};

CouponAvailableCountData _$CouponAvailableCountDataFromJson(
  Map<String, dynamic> json,
) => CouponAvailableCountData(
  coupons: json['coupons'] == null
      ? null
      : CouponsCount.fromJson(json['coupons'] as Map<String, dynamic>),
  total: (json['total'] as num?)?.toInt(),
  creditBalance: json['credit_balance'] as String?,
  brownyCoin: (json['browny_coin'] as num?)?.toInt(),
);

Map<String, dynamic> _$CouponAvailableCountDataToJson(
  CouponAvailableCountData instance,
) => <String, dynamic>{
  'coupons': instance.coupons,
  'total': instance.total,
  'credit_balance': instance.creditBalance,
  'browny_coin': instance.brownyCoin,
};

CouponsCount _$CouponsCountFromJson(Map<String, dynamic> json) => CouponsCount(
  redemption: (json['redemption'] as num?)?.toInt(),
  discount: (json['discount'] as num?)?.toInt(),
  eVoucher: (json['e_voucher'] as num?)?.toInt(),
);

Map<String, dynamic> _$CouponsCountToJson(CouponsCount instance) =>
    <String, dynamic>{
      'redemption': instance.redemption,
      'discount': instance.discount,
      'e_voucher': instance.eVoucher,
    };
