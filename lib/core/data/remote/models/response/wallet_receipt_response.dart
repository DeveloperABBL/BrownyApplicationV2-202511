import 'package:browny_applications_new/core/utils/json_converters.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';

part 'wallet_receipt_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable(explicitToJson: true)
class WalletReceiptResponse extends BaseModelResponse {
  @JsonKey(name: 'data')
  final WalletReceiptData? data;

  WalletReceiptResponse({
    super.success,
    super.errorType,
    super.message,
    this.data,
  });

  factory WalletReceiptResponse.fromJson(Map<String, dynamic> json) =>
      _$WalletReceiptResponseFromJson(json);
  Map<String, dynamic> toJson() =>
      baseToJson(_$WalletReceiptResponseToJson(this));
}

@JsonSerializable()
class WalletReceiptData {
  @JsonKey(name: 'dateTime')
  @DateTimeConverter()
  final DateTime? dateTime;

  @JsonKey(name: 'gateway')
  final String? gateway;

  @JsonKey(name: 'payment_ref')
  final String? paymentRef;

  @JsonKey(name: 'wallet')
  final String? wallet;

  @JsonKey(name: 'receipt_no')
  final String? receiptNo;

  @JsonKey(name: 'transaction_id')
  final String? transactionId;

  @JsonKey(name: 'amount')
  final String? amount;

  @JsonKey(name: 'bonus')
  final String? bonus;

  @JsonKey(name: 'qr_image')
  final String? qrImage;

  WalletReceiptData({
    this.dateTime,
    this.gateway,
    this.paymentRef,
    this.wallet,
    this.receiptNo,
    this.transactionId,
    this.amount,
    this.bonus,
    this.qrImage,
  });

  factory WalletReceiptData.fromJson(Map<String, dynamic> json) =>
      _$WalletReceiptDataFromJson(json);
  Map<String, dynamic> toJson() => _$WalletReceiptDataToJson(this);
}
