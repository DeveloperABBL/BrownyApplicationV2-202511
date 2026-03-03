// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'machine_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MachineStatusResponse _$MachineStatusResponseFromJson(
  Map<String, dynamic> json,
) => MachineStatusResponse(
  status: json['status'] as String?,
  message: json['message'] as String?,
  storeMachineId: (json['store_machine_id'] as num?)?.toInt(),
  qr: json['qr'] as String?,
);

Map<String, dynamic> _$MachineStatusResponseToJson(
  MachineStatusResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'message': instance.message,
  'store_machine_id': instance.storeMachineId,
  'qr': instance.qr,
};
