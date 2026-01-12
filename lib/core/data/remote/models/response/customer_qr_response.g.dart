// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_qr_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerQRResponse _$CustomerQRResponseFromJson(Map<String, dynamic> json) =>
    CustomerQRResponse(
      success: json['success'] as bool?,
      errorType: json['error_type'] as String?,
      message: json['message'] as String?,
      url: json['url'] as String?,
      ads: json['ads'] as String?,
    );

Map<String, dynamic> _$CustomerQRResponseToJson(CustomerQRResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'error_type': instance.errorType,
      'url': instance.url,
      'ads': instance.ads,
    };
