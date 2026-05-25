import 'package:json_annotation/json_annotation.dart';

part 'address_master_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-19
///
/// ข้อมูลจังหวัด 1 รายการ — จาก GET /provinces
///
/// NOTE: master ที่อยู่มีเฉพาะ name_th + name_en (ไม่มี zh) จึงไม่ใช้
/// [ContentLocalizeData] — fallback zh → en
@JsonSerializable()
class ProvinceData {
  ProvinceData({
    this.id,
    this.nameTh,
    this.nameEn,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name_th')
  final String? nameTh;

  @JsonKey(name: 'name_en')
  final String? nameEn;

  /// ชื่อจังหวัดตาม locale — th = nameTh, ที่เหลือ fallback nameEn → nameTh
  String getNameDisplay(String locale) {
    if (locale == 'th') return nameTh ?? '';
    return (nameEn ?? '').isNotEmpty ? nameEn! : (nameTh ?? '');
  }

  factory ProvinceData.fromJson(Map<String, dynamic> json) =>
      _$ProvinceDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProvinceDataToJson(this);
}

/// DONG 2026-05-19
///
/// ข้อมูลอำเภอ 1 รายการ — จาก GET /districts?province_id={id}
///
/// 422 ถ้า province_id ไม่ถูกต้อง — body: `{"message": "The selected province id is invalid."}`
@JsonSerializable()
class DistrictData {
  DistrictData({
    this.id,
    this.nameTh,
    this.nameEn,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name_th')
  final String? nameTh;

  @JsonKey(name: 'name_en')
  final String? nameEn;

  /// ชื่ออำเภอตาม locale — th = nameTh, ที่เหลือ fallback nameEn → nameTh
  String getNameDisplay(String locale) {
    if (locale == 'th') return nameTh ?? '';
    return (nameEn ?? '').isNotEmpty ? nameEn! : (nameTh ?? '');
  }

  factory DistrictData.fromJson(Map<String, dynamic> json) =>
      _$DistrictDataFromJson(json);

  Map<String, dynamic> toJson() => _$DistrictDataToJson(this);
}

/// DONG 2026-05-19
///
/// ข้อมูลตำบล 1 รายการ + รหัสไปรษณีย์ —
/// จาก GET /subdistricts?district_id={id}
///
/// 422 ถ้า district_id ไม่ถูกต้อง — body: `{"message": "The selected district id is invalid."}`
@JsonSerializable()
class SubdistrictData {
  SubdistrictData({
    this.id,
    this.nameTh,
    this.nameEn,
    this.zipCode,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name_th')
  final String? nameTh;

  @JsonKey(name: 'name_en')
  final String? nameEn;

  @JsonKey(name: 'zip_code')
  final String? zipCode;

  /// ชื่อตำบลตาม locale — th = nameTh, ที่เหลือ fallback nameEn → nameTh
  String getNameDisplay(String locale) {
    if (locale == 'th') return nameTh ?? '';
    return (nameEn ?? '').isNotEmpty ? nameEn! : (nameTh ?? '');
  }

  factory SubdistrictData.fromJson(Map<String, dynamic> json) =>
      _$SubdistrictDataFromJson(json);

  Map<String, dynamic> toJson() => _$SubdistrictDataToJson(this);
}

/// DONG 2026-05-19
///
/// 1 รายการจาก GET /locations — flat list ของทุก province/district/subdistrict
///
/// id = subdistrict id, data = ข้อมูล provinces+district+subdistrict+zip
/// (มีเฉพาะภาษาไทยจาก master)
@JsonSerializable()
class LocationItemData {
  LocationItemData({
    this.id,
    this.data,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'data')
  final LocationDetailData? data;

  factory LocationItemData.fromJson(Map<String, dynamic> json) =>
      _$LocationItemDataFromJson(json);

  Map<String, dynamic> toJson() => _$LocationItemDataToJson(this);
}

/// รายละเอียดที่อยู่แบบ flat — เฉพาะภาษาไทยจาก master
@JsonSerializable()
class LocationDetailData {
  LocationDetailData({
    this.provinceNameTh,
    this.districtNameTh,
    this.subDistrictNameTh,
    this.zipCode,
  });

  @JsonKey(name: 'province_name_th')
  final String? provinceNameTh;

  @JsonKey(name: 'district_name_th')
  final String? districtNameTh;

  @JsonKey(name: 'sub_district_name_th')
  final String? subDistrictNameTh;

  @JsonKey(name: 'zip_code')
  final String? zipCode;

  factory LocationDetailData.fromJson(Map<String, dynamic> json) =>
      _$LocationDetailDataFromJson(json);

  Map<String, dynamic> toJson() => _$LocationDetailDataToJson(this);
}
