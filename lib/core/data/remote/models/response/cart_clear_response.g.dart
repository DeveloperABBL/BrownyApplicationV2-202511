// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_clear_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartClearResponse _$CartClearResponseFromJson(Map<String, dynamic> json) =>
    CartClearResponse(
      data: json['data'] == null
          ? null
          : CartClearData.fromJson(json['data'] as Map<String, dynamic>),
      success: json['success'] as bool?,
      message: json['message'] as String?,
      errorType: json['error_type'] as String?,
    );

Map<String, dynamic> _$CartClearResponseToJson(CartClearResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'error_type': instance.errorType,
      'data': instance.data,
    };

CartClearData _$CartClearDataFromJson(Map<String, dynamic> json) =>
    CartClearData(deletedCount: (json['deleted_count'] as num?)?.toInt());

Map<String, dynamic> _$CartClearDataToJson(CartClearData instance) =>
    <String, dynamic>{'deleted_count': instance.deletedCount};
