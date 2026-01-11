// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topup_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopupRequest _$TopupRequestFromJson(Map<String, dynamic> json) => TopupRequest(
  customerId: json['customer_id'] as String,
  amount: (json['amount'] as num).toInt(),
  gateway: json['gateway'] as String,
);

Map<String, dynamic> _$TopupRequestToJson(TopupRequest instance) =>
    <String, dynamic>{
      'customer_id': instance.customerId,
      'amount': instance.amount,
      'gateway': instance.gateway,
    };
