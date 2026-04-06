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
