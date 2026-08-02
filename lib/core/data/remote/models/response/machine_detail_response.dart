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
    this.isOrderCleared = false,
    super.success,
    super.message,
    super.errorType,
  });

  /// DONG 2026-08-02
  ///
  /// `true` = API เคลียร์ข้อมูล order (order_id / receipt_no) ทิ้งแล้ว
  /// แปลว่าเครื่องทำงานเสร็จเรียบร้อย
  ///
  /// จำเป็นต้องเก็บแยกไว้ เพราะ [retainDataFrom] จะเติมข้อมูล order เดิม
  /// กลับเข้ามาใน object นี้เพื่อใช้แสดงผล ทำให้ดูจาก [orderId] / [receiptNo]
  /// ตรงๆ ไม่ได้อีกต่อไป
  ///
  /// ไม่ได้มาจาก JSON — ถูกกำหนดค่าใน [retainDataFrom] เท่านั้น
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isOrderCleared;

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

  /// เครื่องกำลังซ่อมบำรุง
  bool get isMaintenance => status?.toLowerCase() == 'maintenance';

  /// เครื่องปิดการใช้งานผ่าน App
  bool get isInactive => status?.toLowerCase() == 'inactive';

  /// เช็คว่าเครื่องเป็นสถานะ Failed หรือไม่
  bool get isFailed => !isAvailable && !isBusy;

  /// DONG 2026-08-02
  ///
  /// เช็คว่ามี order ผูกอยู่กับเครื่องหรือไม่
  ///
  /// API จะส่ง order_id / receipt_no มาเสมอ ทั้งตอนที่เครื่องยังไม่เริ่มทำงาน
  /// และตอนที่กำลังทำงานอยู่ แต่จะเคลียร์เป็นค่าว่างเมื่อเครื่องทำงานเสร็จแล้ว
  bool get hasOrder =>
      !isOrderCleared &&
      (orderId.orEmpty.isNotEmpty || receiptNo.orEmpty.isNotEmpty);

  /// DONG 2026-08-02
  ///
  /// เครื่องทำงานเสร็จเรียบร้อยแล้ว
  ///
  /// เมื่อเครื่องทำงานเสร็จ status จะกลับมาเป็น `Vacant` เหมือนตอนที่ยังไม่เริ่ม
  /// ทำงาน ต่างกันตรงที่ order_id / receipt_no จะถูกเคลียร์ทิ้ง จึงต้องใช้
  /// [hasOrder] มาแยกอีกชั้น
  bool get isCompleted => isAvailable && !hasOrder;

  /// DONG 2026-08-02
  ///
  /// เครื่องยังไม่เริ่มทำงาน (จ่ายเงินแล้ว แต่ผู้ใช้ยังไม่กดปุ่มที่หน้าเครื่อง)
  bool get isNotStarted => !isBusy && !isCompleted;

  /// DONG 2026-08-02
  ///
  /// countdown ฝั่ง app นับจนหมดแล้ว แต่ API ยังรายงานว่าเครื่องทำงานอยู่
  ///
  /// countdown ในหน้าจอนับถอยหลังเองฝั่ง client จึงมักหมดก่อนที่ backend
  /// จะอัพเดท status เป็นเสร็จสิ้นจริง ช่วงนี้ต้อง poll ต่อเพื่อรอ status ใหม่
  /// ไม่งั้นสถานะจะค้างที่ `กำลังทำงาน` ตลอดจนกว่าผู้ใช้จะ refresh เอง
  ///
  /// [remaining] คือเวลาที่เหลือจาก countdown ฝั่ง app
  bool isAwaitingCompletion(Duration? remaining) =>
      isBusy && remaining == Duration.zero;

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

  MachineDetailResponse copyWith({
    int? id,
    String? orderId,
    String? receiptNo,
    ContentLocalizeData? storeName,
    String? status,
    DateTime? startTime,
    String? finishDatatime,
    String? remainingTime,
    String? machineNo,
    String? machineImage,
    ContentLocalizeData? name,
    List<ProgramData>? addTime,
    String? programImage,
    ContentLocalizeData? programName,
    ContentLocalizeData? machineType,
    bool? isOrderCleared,
    bool? success,
    String? message,
    String? errorType,
  }) {
    return MachineDetailResponse(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      receiptNo: receiptNo ?? this.receiptNo,
      storeName: storeName ?? this.storeName,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      finishDatatime: finishDatatime ?? this.finishDatatime,
      remainingTime: remainingTime ?? this.remainingTime,
      machineNo: machineNo ?? this.machineNo,
      machineImage: machineImage ?? this.machineImage,
      name: name ?? this.name,
      addTime: addTime ?? this.addTime,
      programImage: programImage ?? this.programImage,
      programName: programName ?? this.programName,
      machineType: machineType ?? this.machineType,
      isOrderCleared: isOrderCleared ?? this.isOrderCleared,
      success: success ?? this.success,
      message: message ?? this.message,
      errorType: errorType ?? this.errorType,
    );
  }

  /// DONG 2026-08-02
  ///
  /// เมื่อเครื่องทำงานเสร็จ API จะเคลียร์ข้อมูลของ order ทิ้งทั้งหมด
  /// (order_id, receipt_no, startTime, finish_datatime, program_name,
  /// program_image, addTime) ทำให้หน้าจอที่เปิดค้างไว้ข้อมูลหายไปหมด
  ///
  /// method นี้จะเติมเฉพาะค่าที่หายไป จาก [previous] (response ก่อนหน้า)
  /// เพื่อให้หน้าจอยังแสดงข้อมูล order เดิมได้ต่อ
  ///
  /// ยกเว้น [status] กับ [remainingTime] ที่ใช้ค่าจาก response ใหม่เสมอ
  /// เพราะเป็นข้อมูลสถานะแบบ realtime
  MachineDetailResponse retainDataFrom(MachineDetailResponse? previous) {
    // ต้องอ่านสถานะ order จาก response ที่ API ส่งมา ก่อนจะเติมค่าเดิมกลับเข้าไป
    final orderCleared = orderId.orEmpty.isEmpty && receiptNo.orEmpty.isEmpty;

    if (previous == null) {
      return copyWith(isOrderCleared: orderCleared);
    }

    return copyWith(
      isOrderCleared: orderCleared,
      id: id ?? previous.id,
      orderId: _keepText(orderId, previous.orderId),
      receiptNo: _keepText(receiptNo, previous.receiptNo),
      storeName: _keepContent(storeName, previous.storeName),
      startTime: startTime ?? previous.startTime,
      finishDatatime: _keepText(finishDatatime, previous.finishDatatime),
      machineNo: _keepText(machineNo, previous.machineNo),
      machineImage: _keepText(machineImage, previous.machineImage),
      name: _keepContent(name, previous.name),
      addTime: (addTime?.isNotEmpty ?? false) ? addTime : previous.addTime,
      programImage: _keepText(programImage, previous.programImage),
      programName: _keepContent(programName, previous.programName),
      machineType: _keepContent(machineType, previous.machineType),
    );
  }

  /// คืนค่า [next] ถ้ามีข้อความ ถ้าเป็นค่าว่างให้คืนค่าเดิม [previous]
  static String? _keepText(String? next, String? previous) =>
      next.orEmpty.isNotEmpty ? next : previous;

  /// คืนค่า [next] ถ้ามีข้อความอย่างน้อย 1 ภาษา ถ้าว่างให้คืนค่าเดิม [previous]
  static ContentLocalizeData? _keepContent(
    ContentLocalizeData? next,
    ContentLocalizeData? previous,
  ) => (next?.isNotEmpty ?? false) ? next : previous;

  factory MachineDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$MachineDetailResponseFromJson(json);
  Map<String, dynamic> toJson() =>
      baseToJson(_$MachineDetailResponseToJson(this));
}
