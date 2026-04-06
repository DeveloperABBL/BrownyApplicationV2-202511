// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMethodResponse _$PaymentMethodResponseFromJson(
  Map<String, dynamic> json,
) => PaymentMethodResponse(
  payments: (json['payments'] as List<dynamic>?)
      ?.map((e) => PaymentMethodData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PaymentMethodResponseToJson(
  PaymentMethodResponse instance,
) => <String, dynamic>{
  'payments': instance.payments?.map((e) => e.toJson()).toList(),
};

PaymentMethodData _$PaymentMethodDataFromJson(Map<String, dynamic> json) =>
    PaymentMethodData(
      code: json['code'] as String?,
      name: json['name'] as String?,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$PaymentMethodDataToJson(PaymentMethodData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'image': instance.image,
    };
