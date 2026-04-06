// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'working_machines_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkingMachinesResponse _$WorkingMachinesResponseFromJson(
  Map<String, dynamic> json,
) => WorkingMachinesResponse(
  count: (json['count'] as num?)?.toInt(),
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => WorkingMachineData.fromJson(e as Map<String, dynamic>))
      .toList(),
  success: json['success'] as bool?,
  message: json['message'] as String?,
  errorType: json['error_type'] as String?,
);

Map<String, dynamic> _$WorkingMachinesResponseToJson(
  WorkingMachinesResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'count': instance.count,
  'data': instance.data,
};
