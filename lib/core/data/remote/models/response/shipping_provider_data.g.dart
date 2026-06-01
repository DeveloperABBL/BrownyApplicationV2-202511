// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipping_provider_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShippingProviderData _$ShippingProviderDataFromJson(
  Map<String, dynamic> json,
) => ShippingProviderData(
  id: (json['id'] as num?)?.toInt(),
  code: json['code'] as String?,
  name: json['name'] as String?,
  logoUrl: json['logo_url'] as String?,
  trackUrl: json['track_url'] as String?,
);

Map<String, dynamic> _$ShippingProviderDataToJson(
  ShippingProviderData instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'logo_url': instance.logoUrl,
  'track_url': instance.trackUrl,
};
