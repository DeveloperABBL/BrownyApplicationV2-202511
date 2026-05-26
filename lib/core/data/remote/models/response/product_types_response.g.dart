// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_types_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductTypesResponse _$ProductTypesResponseFromJson(
  Map<String, dynamic> json,
) => ProductTypesResponse(
  productType: (json['product_type'] as List<dynamic>?)
      ?.map((e) => ProductTypeData.fromJson(e as Map<String, dynamic>))
      .toList(),
  success: json['success'] as bool?,
  message: json['message'] as String?,
  errorType: json['error_type'] as String?,
);

Map<String, dynamic> _$ProductTypesResponseToJson(
  ProductTypesResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'product_type': instance.productType,
};

ProductTypeData _$ProductTypeDataFromJson(Map<String, dynamic> json) =>
    ProductTypeData(
      id: json['id'],
      name: json['name'] == null
          ? null
          : ContentLocalizeData.fromJson(json['name'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProductTypeDataToJson(ProductTypeData instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
