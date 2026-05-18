// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressResponse _$AddressResponseFromJson(Map<String, dynamic> json) =>
    AddressResponse(
      data: json['data'] == null
          ? null
          : AddressData.fromJson(json['data'] as Map<String, dynamic>),
      success: json['success'] as bool?,
      message: json['message'] as String?,
      errorType: json['error_type'] as String?,
    );

Map<String, dynamic> _$AddressResponseToJson(AddressResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'error_type': instance.errorType,
      'data': instance.data,
    };

AddressListResponse _$AddressListResponseFromJson(Map<String, dynamic> json) =>
    AddressListResponse(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => AddressData.fromJson(e as Map<String, dynamic>))
          .toList(),
      success: json['success'] as bool?,
      message: json['message'] as String?,
      errorType: json['error_type'] as String?,
    );

Map<String, dynamic> _$AddressListResponseToJson(
  AddressListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'data': instance.data,
};

AddressData _$AddressDataFromJson(Map<String, dynamic> json) => AddressData(
  id: (json['id'] as num?)?.toInt(),
  customerId: json['customer_id'] as String?,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  name: json['name'] as String?,
  phone: json['phone'] as String?,
  zipcode: json['zipcode'] as String?,
  province: json['province'] as String?,
  district: json['district'] as String?,
  subdistrict: json['subdistrict'] as String?,
  address: json['address'] as String?,
  note: json['note'] as String?,
  isDefault: json['is_default'] as bool?,
);

Map<String, dynamic> _$AddressDataToJson(AddressData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'name': instance.name,
      'phone': instance.phone,
      'zipcode': instance.zipcode,
      'province': instance.province,
      'district': instance.district,
      'subdistrict': instance.subdistrict,
      'address': instance.address,
      'note': instance.note,
      'is_default': instance.isDefault,
    };
