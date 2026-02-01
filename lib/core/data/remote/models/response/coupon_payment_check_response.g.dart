// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_payment_check_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CouponPaymentCheckResponse _$CouponPaymentCheckResponseFromJson(
  Map<String, dynamic> json,
) => CouponPaymentCheckResponse(
  status: json['status'] as String,
  redirect: json['redirect'] as String?,
);

Map<String, dynamic> _$CouponPaymentCheckResponseToJson(
  CouponPaymentCheckResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'redirect': instance.redirect,
};
