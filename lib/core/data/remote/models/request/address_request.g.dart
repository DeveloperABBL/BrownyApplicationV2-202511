// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressRequest _$AddressRequestFromJson(Map<String, dynamic> json) =>
    AddressRequest(
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String,
      zipcode: json['zipcode'] as String,
      province: json['province'] as String,
      district: json['district'] as String,
      subdistrict: json['subdistrict'] as String,
      addressLine: json['address_line'] as String,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$AddressRequestToJson(AddressRequest instance) =>
    <String, dynamic>{
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone': instance.phone,
      'zipcode': instance.zipcode,
      'province': instance.province,
      'district': instance.district,
      'subdistrict': instance.subdistrict,
      'address_line': instance.addressLine,
      'note': instance.note,
    };
