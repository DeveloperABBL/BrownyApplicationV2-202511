// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartResponse _$CartResponseFromJson(Map<String, dynamic> json) => CartResponse(
  data: json['data'] == null
      ? null
      : CartData.fromJson(json['data'] as Map<String, dynamic>),
  success: json['success'] as bool?,
  message: json['message'] as String?,
  errorType: json['error_type'] as String?,
);

Map<String, dynamic> _$CartResponseToJson(CartResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'error_type': instance.errorType,
      'data': instance.data,
    };

CartData _$CartDataFromJson(Map<String, dynamic> json) => CartData(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => CartItemData.fromJson(e as Map<String, dynamic>))
      .toList(),
  totals: json['totals'] == null
      ? null
      : CartTotalsData.fromJson(json['totals'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CartDataToJson(CartData instance) => <String, dynamic>{
  'items': instance.items,
  'totals': instance.totals,
};

CartTotalsData _$CartTotalsDataFromJson(Map<String, dynamic> json) =>
    CartTotalsData(
      totalLineCoin: json['total_line_coin'] as num?,
      totalLineMoney: json['total_line_money'] as num?,
      computedFrom: json['computed_from'] as String?,
    );

Map<String, dynamic> _$CartTotalsDataToJson(CartTotalsData instance) =>
    <String, dynamic>{
      'total_line_coin': instance.totalLineCoin,
      'total_line_money': instance.totalLineMoney,
      'computed_from': instance.computedFrom,
    };
