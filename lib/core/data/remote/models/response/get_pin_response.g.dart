// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_pin_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetPinResponse _$GetPinResponseFromJson(Map<String, dynamic> json) =>
    GetPinResponse(
      success: json['success'] as bool,
      ciphertext: json['ciphertext'] as String?,
      cipher: json['cipher'] as String?,
    );

Map<String, dynamic> _$GetPinResponseToJson(GetPinResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'ciphertext': instance.ciphertext,
      'cipher': instance.cipher,
    };
