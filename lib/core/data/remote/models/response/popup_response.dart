import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'popup_response.g.dart';

/// Response model สำหรับ API fetch popups
///
/// Returns: List of PopupData
@JsonSerializable()
class PopupData {
  /// ID ของ popup
  @JsonKey(name: 'id')
  final int id;

  /// ชื่อ campaign
  @JsonKey(name: 'name')
  final String name;

  /// หน้าที่จะแสดง popup (เช่น ["home", "program"])
  @JsonKey(name: 'show_on')
  final List<String> showOn;

  /// สถานะการเปิดใช้งาน ("true" หรือ "false")
  @JsonKey(name: 'active')
  final String active;

  /// Action ของโปรแกรม (เช่น "join")
  @JsonKey(name: 'program_action')
  final String programAction;

  /// Target ของโปรแกรม
  @JsonKey(name: 'program_target')
  final String programTarget;

  /// Auto click target (เช่น "washer")
  @JsonKey(name: 'auto_click_target')
  final String autoClickTarget;

  /// วันเริ่มต้นแสดง popup
  @JsonKey(name: 'start_date')
  final String startDate;

  /// วันสิ้นสุดแสดง popup
  @JsonKey(name: 'end_date')
  final String endDate;

  /// วันที่สร้างข้อมูล
  @JsonKey(name: 'created_at')
  final String createdAt;

  /// วันที่แก้ไขข้อมูลล่าสุด
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  /// ข้อความ popup แยกตามภาษา
  @JsonKey(name: 'text')
  final ContentLocalizeData text;

  /// URL รูปภาพ popup แยกตามภาษา
  @JsonKey(name: 'image')
  final ContentLocalizeData image;

  PopupData({
    required this.id,
    required this.name,
    required this.showOn,
    required this.active,
    required this.programAction,
    required this.programTarget,
    required this.autoClickTarget,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
    required this.text,
    required this.image,
  });

  factory PopupData.fromJson(Map<String, dynamic> json) =>
      _$PopupDataFromJson(json);

  Map<String, dynamic> toJson() => _$PopupDataToJson(this);

  /// Helper: ตรวจสอบว่า popup นี้ active หรือไม่
  bool get isActive => active.toLowerCase() == 'true';

  /// Helper: ตรวจสอบว่า popup นี้ควรแสดงในหน้านี้หรือไม่
  bool shouldShowOn(String page) => showOn.contains(page);

  /// Helper: ตรวจสอบว่า popup นี้อยู่ในช่วงเวลาที่กำหนดหรือไม่
  bool isInDateRange() {
    final now = DateTime.now();
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    return now.isAfter(start) && now.isBefore(end);
  }
}
