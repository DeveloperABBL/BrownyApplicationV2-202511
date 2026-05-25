// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationSearchResponse _$LocationSearchResponseFromJson(
  Map<String, dynamic> json,
) => LocationSearchResponse(
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => LocationSearchData.fromJson(e as Map<String, dynamic>))
      .toList(),
  success: json['success'] as bool?,
  message: json['message'] as String?,
  errorType: json['error_type'] as String?,
);

Map<String, dynamic> _$LocationSearchResponseToJson(
  LocationSearchResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'data': instance.data,
};

LocationSearchData _$LocationSearchDataFromJson(Map<String, dynamic> json) =>
    LocationSearchData(
      subdistrictId: json['subdistrict_id'] as String?,
      subdistrict: json['subdistrict'] as String?,
      district: json['district'] as String?,
      province: json['province'] as String?,
      zipcode: json['zipcode'] as String?,
      label: json['label'] as String?,
    );

Map<String, dynamic> _$LocationSearchDataToJson(LocationSearchData instance) =>
    <String, dynamic>{
      'subdistrict_id': instance.subdistrictId,
      'subdistrict': instance.subdistrict,
      'district': instance.district,
      'province': instance.province,
      'zipcode': instance.zipcode,
      'label': instance.label,
    };
