import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'machine_detail_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class MachineDetailResponse extends BaseModelResponse {
  MachineDetailResponse({
    this.id,
    this.storeName,
    this.status,
    this.finishDatatime,
    this.remainingTime,
    this.machineNo,
    this.name,
    super.success,
    super.message,
    super.errorType,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'store_name')
  final ContentLocalizeData? storeName;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'finish_datatime')
  final String? finishDatatime;

  @JsonKey(name: 'remaining_time')
  final String? remainingTime;

  @JsonKey(name: 'machine_no')
  final String? machineNo;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  /// ดึงชื่อร้านตาม locale
  String getStoreNameDisplay(String locale) {
    return storeName?.getByLocaleCode(locale) ?? '';
  }

  /// ดึงชื่อเครื่องตาม locale
  String getMachineNameDisplay(String locale) {
    return name?.getByLocaleCode(locale) ?? '';
  }

  /// เช็คว่าเครื่องว่างหรือไม่
  bool get isAvailable => status?.toLowerCase() == 'vacant';

  /// เช็คว่าเครื่องกำลังทำงานหรือไม่
  bool get isBusy => status?.toLowerCase() == 'busy';

  /// เช็คว่าเครื่องสามารถเชื่อมต่อได้หรือไม่
  bool get isTimeOut => status?.toLowerCase() == 'timeout';

  factory MachineDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$MachineDetailResponseFromJson(json);
  Map<String, dynamic> toJson() =>
      baseToJson(_$MachineDetailResponseToJson(this));
}
