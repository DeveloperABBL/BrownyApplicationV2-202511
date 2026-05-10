// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductDetailResponse _$ProductDetailResponseFromJson(
  Map<String, dynamic> json,
) => ProductDetailResponse(
  product: json['product'] == null
      ? null
      : ProductData.fromJson(json['product'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProductDetailResponseToJson(
  ProductDetailResponse instance,
) => <String, dynamic>{'product': instance.product};
