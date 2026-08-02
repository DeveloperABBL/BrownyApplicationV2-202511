import 'package:json_annotation/json_annotation.dart';

part 'content_localize_data.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************
@JsonSerializable()
class ContentLocalizeData {
  ContentLocalizeData({
    this.th,
    this.en,
    this.zh,
  });

  @JsonKey(name: 'th')
  final String? th;

  @JsonKey(name: 'en')
  final String? en;

  @JsonKey(name: 'zh')
  final String? zh;

  /// DONG 2026-08-02
  ///
  /// เช็คว่าไม่มีข้อความในทุกภาษา
  /// (บาง API จะส่ง `{"th": "", "en": "", "zh": ""}` กลับมาแทนที่จะส่ง null)
  bool get isEmpty =>
      (th?.isEmpty ?? true) && (en?.isEmpty ?? true) && (zh?.isEmpty ?? true);

  /// มีข้อความอย่างน้อย 1 ภาษา
  bool get isNotEmpty => !isEmpty;

  String? getByLocaleCode(String locale) {
    switch (locale) {
      case 'en':
        return en;
      case 'zh':
        return zh;
      default:
        return th;
    }
  }

  factory ContentLocalizeData.fromJson(Map<String, dynamic> json) =>
      _$ContentLocalizeDataFromJson(json);

  Map<String, dynamic> toJson() => _$ContentLocalizeDataToJson(this);
}
