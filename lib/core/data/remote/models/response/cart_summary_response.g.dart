// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_summary_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartSummaryResponse _$CartSummaryResponseFromJson(Map<String, dynamic> json) =>
    CartSummaryResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      errorType: json['error_type'] as String?,
      data: json['data'] == null
          ? null
          : CheckoutSummaryData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CartSummaryResponseToJson(
  CartSummaryResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'data': instance.data,
};
