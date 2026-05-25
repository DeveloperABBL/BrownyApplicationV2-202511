import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'location_search_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-19
///
/// Response model สำหรับ API GET /locations/search
/// (ค้นหาที่อยู่ — รหัสไปรษณีย์ / ตำบล / อำเภอ / จังหวัด)
///
/// ใช้กับ picker เลือกที่อยู่ในหน้า [ShipToDetailPage]
@JsonSerializable()
class LocationSearchResponse extends BaseModelResponse {
  LocationSearchResponse({
    this.data,
    super.success,
    super.message,
    super.errorType,
  });

  @JsonKey(name: 'data')
  final List<LocationSearchData>? data;

  factory LocationSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$LocationSearchResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      baseToJson(_$LocationSearchResponseToJson(this));
}

/// ผลลัพธ์ค้นหาที่อยู่ 1 รายการ — ตำบล + อำเภอ + จังหวัด + รหัสไปรษณีย์
@JsonSerializable()
class LocationSearchData {
  LocationSearchData({
    this.subdistrictId,
    this.subdistrict,
    this.district,
    this.province,
    this.zipcode,
    this.label,
  });

  @JsonKey(name: 'subdistrict_id')
  final String? subdistrictId;

  @JsonKey(name: 'subdistrict')
  final String? subdistrict;

  @JsonKey(name: 'district')
  final String? district;

  @JsonKey(name: 'province')
  final String? province;

  @JsonKey(name: 'zipcode')
  final String? zipcode;

  /// ข้อความแสดงผลที่ server format มาให้แล้ว
  /// รูปแบบ "ตำบล, อำเภอ, จังหวัด รหัสไปรษณีย์"
  @JsonKey(name: 'label')
  final String? label;

  factory LocationSearchData.fromJson(Map<String, dynamic> json) =>
      _$LocationSearchDataFromJson(json);

  Map<String, dynamic> toJson() => _$LocationSearchDataToJson(this);
}
