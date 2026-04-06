// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_list_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CouponListRequest _$CouponListRequestFromJson(Map<String, dynamic> json) =>
    CouponListRequest(
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      customerId: json['customer_id'] as String?,
    );

Map<String, dynamic> _$CouponListRequestToJson(CouponListRequest instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'customer_id': instance.customerId,
    };
