// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topup_request_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopupRequestResponse _$TopupRequestResponseFromJson(
  Map<String, dynamic> json,
) => TopupRequestResponse(
  success: json['success'] as bool?,
  errorType: json['error_type'] as String?,
  message: json['message'] as String?,
  paymentRef: json['payment_ref'] as String?,
  qrCodeData: json['qrcode'] as String?,
  confirmedAt: const DateTimeConverter().fromJson(
    json['confirmed_at'] as String?,
  ),
  amount: json['amount'] as String?,
);

Map<String, dynamic> _$TopupRequestResponseToJson(
  TopupRequestResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'error_type': instance.errorType,
  'success': instance.success,
  'payment_ref': instance.paymentRef,
  'qrcode': instance.qrCodeData,
  'confirmed_at': const DateTimeConverter().toJson(instance.confirmedAt),
  'amount': instance.amount,
};
