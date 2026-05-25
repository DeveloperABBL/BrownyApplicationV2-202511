import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'address_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-18
///
/// Response model สำหรับ API ที่อยู่จัดส่งแบบรายการเดียว
/// (POST /customer/{id}/addresses, PUT /addresses/{id})
@JsonSerializable()
class AddressResponse extends BaseModelResponse {
  AddressResponse({
    this.data,
    super.success,
    super.message,
    super.errorType,
  });

  @JsonKey(name: 'data')
  final AddressData? data;

  factory AddressResponse.fromJson(Map<String, dynamic> json) =>
      _$AddressResponseFromJson(json);

  Map<String, dynamic> toJson() => baseToJson(_$AddressResponseToJson(this));
}

/// DONG 2026-05-18
///
/// Response model สำหรับ API GET /customer/{id}/addresses
/// (รายการที่อยู่จัดส่งทั้งหมดของลูกค้า)
@JsonSerializable()
class AddressListResponse extends BaseModelResponse {
  AddressListResponse({
    this.data,
    super.success,
    super.message,
    super.errorType,
  });

  @JsonKey(name: 'data')
  final List<AddressData>? data;

  factory AddressListResponse.fromJson(Map<String, dynamic> json) =>
      _$AddressListResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      baseToJson(_$AddressListResponseToJson(this));
}

/// ข้อมูลที่อยู่จัดส่ง 1 รายการ
@JsonSerializable()
class AddressData {
  AddressData({
    this.id,
    this.customerId,
    this.firstName,
    this.lastName,
    this.name,
    this.phone,
    this.zipcode,
    this.province,
    this.district,
    this.subdistrict,
    this.address,
    this.fullAddressServer,
    this.note,
    this.isDefault,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'customer_id')
  final String? customerId;

  /// ชื่อจริง — มีใน response ของ GET list / POST
  @JsonKey(name: 'first_name')
  final String? firstName;

  /// นามสกุล — มีใน response ของ GET list / POST
  @JsonKey(name: 'last_name')
  final String? lastName;

  /// ชื่อ-นามสกุลรวม — มีใน response ของ PUT (แทน first_name/last_name)
  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'phone')
  final String? phone;

  @JsonKey(name: 'zipcode')
  final String? zipcode;

  @JsonKey(name: 'province')
  final String? province;

  @JsonKey(name: 'district')
  final String? district;

  @JsonKey(name: 'subdistrict')
  final String? subdistrict;

  /// บ้านเลขที่/รายละเอียดที่อยู่ — response ใช้คีย์ `address`
  @JsonKey(name: 'address')
  final String? address;

  /// ที่อยู่แบบเต็มที่ server format มาให้ — มีใน GET /customer/{id}/addresses
  /// รูปแบบ: "{address} {subdistrict} {district} {province} {zipcode}"
  @JsonKey(name: 'full_address')
  final String? fullAddressServer;

  @JsonKey(name: 'note')
  final String? note;

  @JsonKey(name: 'is_default')
  final bool? isDefault;

  /// ชื่อที่ใช้แสดงผล — ใช้ `name` ถ้ามี (response ของ PUT)
  /// ไม่งั้นรวม `first_name` + `last_name`
  String get displayName {
    final full = name?.trim() ?? '';
    if (full.isNotEmpty) return full;
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }

  /// เช็คว่าเป็นที่อยู่เริ่มต้นหรือไม่
  bool get isDefaultAddress => isDefault ?? false;

  /// ที่อยู่แบบเต็มบรรทัดเดียว — ใช้ค่า [fullAddressServer] จาก API ก่อน
  /// (มีใน GET list); ไม่งั้นรวมเอง (address + ตำบล/อำเภอ/จังหวัด/รหัสไปรษณีย์
  /// ข้าม field ว่าง) — สำหรับ response ที่ไม่มี full_address (เช่น POST/PUT)
  String get fullAddress {
    final fromServer = fullAddressServer?.trim() ?? '';
    if (fromServer.isNotEmpty) return fromServer;
    return [
      address,
      subdistrict,
      district,
      province,
      zipcode,
    ].where((e) => e != null && e.trim().isNotEmpty)
        .map((e) => e!.trim())
        .join(' ');
  }

  factory AddressData.fromJson(Map<String, dynamic> json) =>
      _$AddressDataFromJson(json);

  Map<String, dynamic> toJson() => _$AddressDataToJson(this);
}
