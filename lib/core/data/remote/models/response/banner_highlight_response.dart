import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/data/remote/models/response/banner_response.dart';
import 'package:browny_applications_new/core/utils/json_converters.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';

part 'banner_highlight_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class BannerHighlightResponse extends BaseModelResponse {
  @JsonKey(name: 'data')
  final List<BannerHighlightData>? data;

  BannerHighlightResponse({
    super.success,
    super.errorType,
    super.message,
    this.data,
  });

  factory BannerHighlightResponse.fromJson(Map<String, dynamic> json) =>
      _$BannerHighlightResponseFromJson(json);
  Map<String, dynamic> toJson() =>
      baseToJson(_$BannerHighlightResponseToJson(this));
}

@JsonSerializable()
class BannerHighlightData {
  BannerHighlightData({
    this.id,
    this.name,
    this.type,
    this.target,
    this.category,
    this.image,
    this.title,
    this.subtitle,
    this.dateTime,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'target')
  final String? target;

  @JsonKey(name: 'category')
  final CategoryData? category;

  @JsonKey(name: 'image')
  final ContentLocalizeData? image;

  @JsonKey(name: 'title')
  final ContentLocalizeData? title;

  @JsonKey(name: 'subtitle')
  final ContentLocalizeData? subtitle;

  @DateTimeConverter()
  @JsonKey(name: 'date_time')
  final DateTime? dateTime;

  factory BannerHighlightData.fromJson(Map<String, dynamic> json) =>
      _$BannerHighlightDataFromJson(json);
  Map<String, dynamic> toJson() => _$BannerHighlightDataToJson(this);
}
