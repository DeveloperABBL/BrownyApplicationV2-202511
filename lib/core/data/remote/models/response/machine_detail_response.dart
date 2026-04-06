import 'dart:ui';

import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/data/remote/models/response/machine_programs_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/json_converters.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/icons/assets.gen.dart';
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
    this.orderId,
    this.receiptNo,
    this.storeName,
    this.status,
    this.startTime,
    this.finishDatatime,
    this.remainingTime,
    this.machineNo,
    this.machineImage,
    this.name,
    this.addTime,
    this.programImage,
    this.programName,
    this.machineType,
    super.success,
    super.message,
    super.errorType,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'order_id')
  final String? orderId;

  @JsonKey(name: 'receipt_no')
  final String? receiptNo;

  @JsonKey(name: 'store_name')
  final ContentLocalizeData? storeName;

  @JsonKey(name: 'status')
  final String? status;

  @DateTimeConverter()
  @JsonKey(name: 'startTime')
  final DateTime? startTime;

  @JsonKey(name: 'finish_datatime')
  final String? finishDatatime;

  @JsonKey(name: 'remaining_time')
  final String? remainingTime;

  @JsonKey(name: 'machine_no')
  final String? machineNo;

  @JsonKey(name: 'machine_image')
  final String? machineImage;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  @JsonKey(name: 'addTime')
  final List<ProgramData>? addTime;

  @JsonKey(name: 'program_image')
  final String? programImage;

  @JsonKey(name: 'program_name')
  final ContentLocalizeData? programName;

  @JsonKey(name: 'machine_type')
  final ContentLocalizeData? machineType;

  String getProgramNameDisplay(String locale) {
    if (programName == null) return '';
    return programName!.getByLocaleCode(locale) ?? '';
  }

  /// ดึงชื่อร้านตาม locale
  String getStoreNameDisplay(String locale) {
    return storeName?.getByLocaleCode(locale) ?? '';
  }

  /// ดึงชื่อเครื่องตาม locale
  String getMachineNameDisplay(String locale) {
    return name?.getByLocaleCode(locale) ?? '';
  }

  DateTime? getRemainigtime(String locale) {
    return remainingTime.convertToDateTime('HH:mm:ss', locale);
  }

  String getRemainingTimeDisplay(String locale) {
    return getRemainigtime(locale)?.formatForShow('HH:mm') ?? '-';
  }

  String getStatusDisplay(String locale) {
    final statusLower = status.orEmpty.toLowerCase();
    const statusMap = {
      'en': {
        'busy': 'In Use',
        'vacant': 'Success',
        'default': 'Failed',
      },
      'zh': {
        'busy': '使用中',
        'vacant': '已完成',
        'default': '故障',
      },
      'th': {
        'busy': 'กำลังทำงาน',
        'vacant': 'สำเร็จ',
        'default': 'ขัดข้อง',
      },
    };

    final localizedMap = statusMap[locale] ?? statusMap['th']!;
    return localizedMap[statusLower] ?? localizedMap['default'] ?? '';
  }

  /// เช็คว่าเครื่องว่างหรือไม่
  bool get isAvailable => status?.toLowerCase() == 'vacant';

  /// เช็คว่าเครื่องกำลังทำงานหรือไม่
  bool get isBusy => status?.toLowerCase() == 'busy';

  /// เช็คว่าเครื่องสามารถเชื่อมต่อได้หรือไม่
  bool get isTimeOut => status?.toLowerCase() == 'timeout';

  /// เช็คว่าเครื่องเป็นสถานะ Failed หรือไม่
  bool get isFailed => !isAvailable && !isBusy;

  Color get getColorByStatus {
    if (isFailed) {
      return AppColors.error;
    }
    if (isAvailable) {
      return AppColors.primary;
    }

    return AppColors.yellow3;
  }

  /// เช็คว่าเป็นเครื่องอบหรือไม่
  bool get isDryer => machineType?.en.orEmpty.toLowerCase() == 'dryer';

  AssetGenImage getDryerExtendingTimeDisplay(String locale) {
    switch (locale) {
      case 'en':
        return Assets.services.dryerExtendTimeEn;
      case 'zh':
        return Assets.services.dryerExtendTimeZh;
      default:
        return Assets.services.dryerExtendTime;
    }
  }

  factory MachineDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$MachineDetailResponseFromJson(json);
  Map<String, dynamic> toJson() =>
      baseToJson(_$MachineDetailResponseToJson(this));
}
