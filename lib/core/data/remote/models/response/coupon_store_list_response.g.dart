// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_store_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CouponStoreListResponse _$CouponStoreListResponseFromJson(
  Map<String, dynamic> json,
) => CouponStoreListResponse(
  success: json['success'] as bool?,
  errorType: json['error_type'] as String?,
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => CouponStoreData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CouponStoreListResponseToJson(
  CouponStoreListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'data': instance.data,
};

CouponStoreData _$CouponStoreDataFromJson(Map<String, dynamic> json) =>
    CouponStoreData(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] == null
          ? null
          : ContentLocalizeData.fromJson(json['name'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CouponStoreDataToJson(CouponStoreData instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
