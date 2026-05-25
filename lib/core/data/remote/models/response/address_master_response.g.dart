// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_master_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProvinceData _$ProvinceDataFromJson(Map<String, dynamic> json) => ProvinceData(
  id: (json['id'] as num?)?.toInt(),
  nameTh: json['name_th'] as String?,
  nameEn: json['name_en'] as String?,
);

Map<String, dynamic> _$ProvinceDataToJson(ProvinceData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_th': instance.nameTh,
      'name_en': instance.nameEn,
    };

DistrictData _$DistrictDataFromJson(Map<String, dynamic> json) => DistrictData(
  id: (json['id'] as num?)?.toInt(),
  nameTh: json['name_th'] as String?,
  nameEn: json['name_en'] as String?,
);

Map<String, dynamic> _$DistrictDataToJson(DistrictData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_th': instance.nameTh,
      'name_en': instance.nameEn,
    };

SubdistrictData _$SubdistrictDataFromJson(Map<String, dynamic> json) =>
    SubdistrictData(
      id: (json['id'] as num?)?.toInt(),
      nameTh: json['name_th'] as String?,
      nameEn: json['name_en'] as String?,
      zipCode: json['zip_code'] as String?,
    );

Map<String, dynamic> _$SubdistrictDataToJson(SubdistrictData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_th': instance.nameTh,
      'name_en': instance.nameEn,
      'zip_code': instance.zipCode,
    };

LocationItemData _$LocationItemDataFromJson(Map<String, dynamic> json) =>
    LocationItemData(
      id: (json['id'] as num?)?.toInt(),
      data: json['data'] == null
          ? null
          : LocationDetailData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LocationItemDataToJson(LocationItemData instance) =>
    <String, dynamic>{'id': instance.id, 'data': instance.data};

LocationDetailData _$LocationDetailDataFromJson(Map<String, dynamic> json) =>
    LocationDetailData(
      provinceNameTh: json['province_name_th'] as String?,
      districtNameTh: json['district_name_th'] as String?,
      subDistrictNameTh: json['sub_district_name_th'] as String?,
      zipCode: json['zip_code'] as String?,
    );

Map<String, dynamic> _$LocationDetailDataToJson(LocationDetailData instance) =>
    <String, dynamic>{
      'province_name_th': instance.provinceNameTh,
      'district_name_th': instance.districtNameTh,
      'sub_district_name_th': instance.subDistrictNameTh,
      'zip_code': instance.zipCode,
    };
