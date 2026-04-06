// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'machine_payment_status_check_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MachinePaymentStatusCheckResponse _$MachinePaymentStatusCheckResponseFromJson(
  Map<String, dynamic> json,
) => MachinePaymentStatusCheckResponse(
  status: json['status'] as String,
  redirect: json['redirect'] as String?,
  orderId: json['order_id'] as String?,
);

Map<String, dynamic> _$MachinePaymentStatusCheckResponseToJson(
  MachinePaymentStatusCheckResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'redirect': instance.redirect,
  'order_id': instance.orderId,
};
