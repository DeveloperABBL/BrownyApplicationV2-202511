// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'machine_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MachineDetailResponse _$MachineDetailResponseFromJson(
  Map<String, dynamic> json,
) => MachineDetailResponse(
  id: (json['id'] as num?)?.toInt(),
  orderId: json['order_id'] as String?,
  receiptNo: json['receipt_no'] as String?,
  storeName: json['store_name'] == null
      ? null
      : ContentLocalizeData.fromJson(
          json['store_name'] as Map<String, dynamic>,
        ),
  status: json['status'] as String?,
  startTime: json['startTime'] as String?,
  finishDatatime: json['finish_datatime'] as String?,
  remainingTime: json['remaining_time'] as String?,
  machineNo: json['machine_no'] as String?,
  machineImage: json['machine_image'] as String?,
  name: json['name'] == null
      ? null
      : ContentLocalizeData.fromJson(json['name'] as Map<String, dynamic>),
  addTime: (json['addTime'] as List<dynamic>?)
      ?.map((e) => ProgramData.fromJson(e as Map<String, dynamic>))
      .toList(),
  programImage: json['program_image'] as String?,
  success: json['success'] as bool?,
  message: json['message'] as String?,
  errorType: json['error_type'] as String?,
);

Map<String, dynamic> _$MachineDetailResponseToJson(
  MachineDetailResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'id': instance.id,
  'order_id': instance.orderId,
  'receipt_no': instance.receiptNo,
  'store_name': instance.storeName,
  'status': instance.status,
  'startTime': instance.startTime,
  'finish_datatime': instance.finishDatatime,
  'remaining_time': instance.remainingTime,
  'machine_no': instance.machineNo,
  'machine_image': instance.machineImage,
  'name': instance.name,
  'addTime': instance.addTime,
  'program_image': instance.programImage,
};
