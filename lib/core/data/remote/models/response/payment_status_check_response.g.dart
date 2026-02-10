// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_status_check_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentStatusCheckResponse _$PaymentStatusCheckResponseFromJson(
  Map<String, dynamic> json,
) => PaymentStatusCheckResponse(
  status: json['status'] as String,
  redirect: json['redirect'] as String?,
  orderId: (json['order_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$PaymentStatusCheckResponseToJson(
  PaymentStatusCheckResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'redirect': instance.redirect,
  'order_id': instance.orderId,
};
