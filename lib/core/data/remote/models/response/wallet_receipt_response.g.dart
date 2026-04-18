// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_receipt_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletReceiptResponse _$WalletReceiptResponseFromJson(
  Map<String, dynamic> json,
) => WalletReceiptResponse(
  success: json['success'] as bool?,
  errorType: json['error_type'] as String?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : WalletReceiptData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$WalletReceiptResponseToJson(
  WalletReceiptResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'data': instance.data?.toJson(),
};

WalletReceiptData _$WalletReceiptDataFromJson(Map<String, dynamic> json) =>
    WalletReceiptData(
      dateTime: const DateTimeConverter().fromJson(json['dateTime'] as String?),
      gateway: json['gateway'] as String?,
      paymentRef: json['payment_ref'] as String?,
      wallet: json['wallet'] as String?,
      receiptNo: json['receipt_no'] as String?,
      transactionId: json['transaction_id'] as String?,
      amount: json['amount'] as String?,
      bonus: json['bonus'] as String?,
      qrImage: json['qr_image'] as String?,
    );

Map<String, dynamic> _$WalletReceiptDataToJson(WalletReceiptData instance) =>
    <String, dynamic>{
      'dateTime': const DateTimeConverter().toJson(instance.dateTime),
      'gateway': instance.gateway,
      'payment_ref': instance.paymentRef,
      'wallet': instance.wallet,
      'receipt_no': instance.receiptNo,
      'transaction_id': instance.transactionId,
      'amount': instance.amount,
      'bonus': instance.bonus,
      'qr_image': instance.qrImage,
    };
