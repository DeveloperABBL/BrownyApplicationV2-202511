// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_history_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinHistoryResponse _$CoinHistoryResponseFromJson(Map<String, dynamic> json) =>
    CoinHistoryResponse(
      success: json['success'] as bool?,
      errorType: json['error_type'] as String?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : CoinHistoryData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CoinHistoryResponseToJson(
  CoinHistoryResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'data': instance.data,
};

CoinHistoryData _$CoinHistoryDataFromJson(Map<String, dynamic> json) =>
    CoinHistoryData(
      brownyCoin: json['browny_coin'] as String?,
      expireCoin: json['expire_coin'] as String?,
      expireDate: json['expire_date'] == null
          ? null
          : ContentLocalizeData.fromJson(
              json['expire_date'] as Map<String, dynamic>,
            ),
      history: (json['history'] as List<dynamic>?)
          ?.map((e) => CoinHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CoinHistoryDataToJson(CoinHistoryData instance) =>
    <String, dynamic>{
      'browny_coin': instance.brownyCoin,
      'expire_coin': instance.expireCoin,
      'expire_date': instance.expireDate,
      'history': instance.history,
    };

CoinHistoryItem _$CoinHistoryItemFromJson(Map<String, dynamic> json) =>
    CoinHistoryItem(
      type: json['type'] as String?,
      name: json['name'] == null
          ? null
          : ContentLocalizeData.fromJson(json['name'] as Map<String, dynamic>),
      date: const DateTimeConverter().fromJson(json['date'] as String?),
      amount: json['amount'] as String?,
    );

Map<String, dynamic> _$CoinHistoryItemToJson(CoinHistoryItem instance) =>
    <String, dynamic>{
      'type': instance.type,
      'name': instance.name,
      'date': const DateTimeConverter().toJson(instance.date),
      'amount': instance.amount,
    };
