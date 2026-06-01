import 'package:json_annotation/json_annotation.dart';

part 'machine_status_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class MachineStatusResponse {
  MachineStatusResponse({
    this.status,
    this.message,
    this.storeMachineId,
    this.qr,
  });

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'store_machine_id')
  final int? storeMachineId;

  @JsonKey(name: 'qr')
  final String? qr;

  /// เช็คว่าเครื่องว่างหรือไม่
  bool get isAvailable => status?.toLowerCase() == 'available';

  /// เช็คว่าเครื่องกำลังทำงานหรือไม่
  bool get isBusy => status?.toLowerCase() == 'busy';

  /// เช็คว่าเครื่องไม่พร้อมใช้งานหรือไม่
  bool get isTimeOut => status?.toLowerCase() == 'timeout';

  /// เครื่องปิดปรับปรุง
  bool get isMaintenance => status?.toLowerCase() == 'maintenance';

  bool get isUnavailable => !isAvailable && !isBusy && !isTimeOut;

  factory MachineStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$MachineStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MachineStatusResponseToJson(this);
}
