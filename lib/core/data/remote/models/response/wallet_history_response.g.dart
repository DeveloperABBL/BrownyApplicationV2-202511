// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_history_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletHistoryResponse _$WalletHistoryResponseFromJson(
  Map<String, dynamic> json,
) => WalletHistoryResponse(
  history: (json['history'] as List<dynamic>?)
      ?.map((e) => WalletHistoryItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$WalletHistoryResponseToJson(
  WalletHistoryResponse instance,
) => <String, dynamic>{'history': instance.history};

WalletHistoryItem _$WalletHistoryItemFromJson(Map<String, dynamic> json) =>
    WalletHistoryItem(
      type: json['type'] as String?,
      dateTime: const DateTimeStartWithDayConverter().fromJson(
        json['dateTime'] as String?,
      ),
      amount: json['amount'] as String?,
      description: json['description'] as String?,
      receiptNo: json['receipt_no'] as String?,
    );

Map<String, dynamic> _$WalletHistoryItemToJson(
  WalletHistoryItem instance,
) => <String, dynamic>{
  'type': instance.type,
  'dateTime': const DateTimeStartWithDayConverter().toJson(instance.dateTime),
  'amount': instance.amount,
  'description': instance.description,
  'receipt_no': instance.receiptNo,
};
