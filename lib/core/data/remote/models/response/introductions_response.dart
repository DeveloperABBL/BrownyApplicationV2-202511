import 'package:json_annotation/json_annotation.dart';
import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';

part 'introductions_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable(explicitToJson: true)
class IntroductionsResponse extends BaseModelResponse {
  IntroductionsResponse({
    this.imageUrl,
    this.title,
    this.subtitle,
    super.success,
    super.errorType,
    super.message,
  });

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @JsonKey(name: 'title')
  final ContentLocalizeData? title;

  @JsonKey(name: 'subtitle')
  final ContentLocalizeData? subtitle;

  factory IntroductionsResponse.fromJson(Map<String, dynamic> json) =>
      _$IntroductionsResponseFromJson(json);

  Map<String, dynamic> toJson() => baseToJson(
    _$IntroductionsResponseToJson(this),
  );
}

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
