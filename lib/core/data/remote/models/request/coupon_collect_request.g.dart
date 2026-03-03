// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_collect_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CouponCollectRequest _$CouponCollectRequestFromJson(
  Map<String, dynamic> json,
) => CouponCollectRequest(
  type: json['type'] as String,
  data: json['data'] as String,
  customerId: json['customer_id'] as String,
);

Map<String, dynamic> _$CouponCollectRequestToJson(
  CouponCollectRequest instance,
) => <String, dynamic>{
  'type': instance.type,
  'data': instance.data,
  'customer_id': instance.customerId,
};
