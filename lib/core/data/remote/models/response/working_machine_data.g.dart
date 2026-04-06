// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'working_machine_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkingMachineData _$WorkingMachineDataFromJson(Map<String, dynamic> json) =>
    WorkingMachineData(
      id: (json['id'] as num?)?.toInt(),
      machineImage: json['machine_image'] as String?,
      finishDatatime: json['finish_datatime'] as String?,
      remainingTime: json['remaining_time'] as String?,
      name: json['name'] == null
          ? null
          : ContentLocalizeData.fromJson(json['name'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WorkingMachineDataToJson(WorkingMachineData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'machine_image': instance.machineImage,
      'finish_datatime': instance.finishDatatime,
      'remaining_time': instance.remainingTime,
      'name': instance.name,
    };
