import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/working_machine_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'working_machines_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class WorkingMachinesResponse extends BaseModelResponse {
  WorkingMachinesResponse({
    this.count,
    this.data,
    super.success,
    super.message,
    super.errorType,
  });

  @JsonKey(name: 'count')
  final int? count;

  @JsonKey(name: 'data')
  final List<WorkingMachineData>? data;

  factory WorkingMachinesResponse.fromJson(Map<String, dynamic> json) =>
      _$WorkingMachinesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WorkingMachinesResponseToJson(this);
}
