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
  orderId: json['order_id'],
  paymentStatus: json['payment_status'] as String?,
  receiptNo: json['receipt_no'] as String?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$PaymentStatusCheckResponseToJson(
  PaymentStatusCheckResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'redirect': instance.redirect,
  'order_id': instance.orderId,
  'payment_status': instance.paymentStatus,
  'receipt_no': instance.receiptNo,
  'message': instance.message,
};
