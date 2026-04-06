import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'working_machine_data.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class WorkingMachineData {
  WorkingMachineData({
    this.id,
    this.machineImage,
    this.finishDatatime,
    this.remainingTime,
    this.name,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'machine_image')
  final String? machineImage;

  @JsonKey(name: 'finish_datatime')
  final String? finishDatatime;

  @JsonKey(name: 'remaining_time')
  final String? remainingTime;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  /// ดึงชื่อเครื่องตาม locale
  String getNameDisplay(String locale) {
    return name?.getByLocaleCode(locale) ?? '';
  }

  factory WorkingMachineData.fromJson(Map<String, dynamic> json) =>
      _$WorkingMachineDataFromJson(json);

  Map<String, dynamic> toJson() => _$WorkingMachineDataToJson(this);
}
