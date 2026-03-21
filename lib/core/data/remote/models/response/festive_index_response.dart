import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:json_annotation/json_annotation.dart';

part 'festive_index_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class FestiveIndexResponse {
  FestiveIndexResponse({
    this.hasEvent,
    this.data,
  });

  @JsonKey(name: 'has_event')
  final bool? hasEvent;

  @JsonKey(name: 'data')
  final List<FestiveData>? data;

  factory FestiveIndexResponse.fromJson(Map<String, dynamic> json) =>
      _$FestiveIndexResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FestiveIndexResponseToJson(this);
}

@JsonSerializable()
class FestiveData {
  FestiveData({
    this.id,
    this.banner,
    this.thumbnail,
    this.title,
    this.message,
    this.remain,
    this.expired,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'banner')
  final ContentLocalizeData? banner;

  @JsonKey(name: 'thumbnail')
  final ContentLocalizeData? thumbnail;

  @JsonKey(name: 'title')
  final ContentLocalizeData? title;

  @JsonKey(name: 'message')
  final ContentLocalizeData? message;

  @JsonKey(name: 'remain')
  final ContentLocalizeData? remain;

  @JsonKey(name: 'expired')
  final ContentLocalizeData? expired;

  String getRemainDisplay(String locale) {
    return remain?.getTextByLocale(locale) ?? '-';
  }

  String getExpiredDesisplay(String locale) {
    return expired?.getTextByLocale(locale) ?? '-';
  }

  /// ดึง URL ของ banner ตาม locale
  String getBannerUrl(String locale) => banner?.getByLocaleCode(locale) ?? '';

  /// ดึง URL ของ thumbnail ตาม locale
  String getThumbnailUrl(String locale) =>
      thumbnail?.getByLocaleCode(locale) ?? '';

  /// ดึงชื่อ title ตาม locale
  String getTitleDisplay(String locale) => title?.getByLocaleCode(locale) ?? '';

  /// ดึงข้อความ message ตาม locale
  String getMessageDisplay(String locale) =>
      message?.getByLocaleCode(locale) ?? '';

  factory FestiveData.fromJson(Map<String, dynamic> json) =>
      _$FestiveDataFromJson(json);
  Map<String, dynamic> toJson() => _$FestiveDataToJson(this);
}
