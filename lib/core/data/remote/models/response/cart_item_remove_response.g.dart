// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_remove_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItemRemoveResponse _$CartItemRemoveResponseFromJson(
  Map<String, dynamic> json,
) => CartItemRemoveResponse(
  data: json['data'] == null
      ? null
      : CartItemRemoveData.fromJson(json['data'] as Map<String, dynamic>),
  success: json['success'] as bool?,
  message: json['message'] as String?,
  errorType: json['error_type'] as String?,
);

Map<String, dynamic> _$CartItemRemoveResponseToJson(
  CartItemRemoveResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'data': instance.data,
};

CartItemRemoveData _$CartItemRemoveDataFromJson(Map<String, dynamic> json) =>
    CartItemRemoveData(
      removed: json['removed'] as bool?,
      id: (json['id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CartItemRemoveDataToJson(CartItemRemoveData instance) =>
    <String, dynamic>{'removed': instance.removed, 'id': instance.id};
