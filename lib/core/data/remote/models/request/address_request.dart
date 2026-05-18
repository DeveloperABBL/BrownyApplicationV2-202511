import 'package:json_annotation/json_annotation.dart';

part 'address_request.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-05-18
///
/// Request body สำหรับ API เพิ่ม/แก้ไขที่อยู่จัดส่งของลูกค้า
/// (POST /customer/{id}/addresses, PUT /addresses/{id})
@JsonSerializable()
class AddressRequest {
  AddressRequest({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.zipcode,
    required this.province,
    required this.district,
    required this.subdistrict,
    required this.addressLine,
    this.note,
  });

  @JsonKey(name: 'first_name')
  final String firstName;

  @JsonKey(name: 'last_name')
  final String lastName;

  @JsonKey(name: 'phone')
  final String phone;

  @JsonKey(name: 'zipcode')
  final String zipcode;

  @JsonKey(name: 'province')
  final String province;

  @JsonKey(name: 'district')
  final String district;

  @JsonKey(name: 'subdistrict')
  final String subdistrict;

  /// บ้านเลขที่/รายละเอียดที่อยู่ — request ใช้คีย์ `address_line`
  /// (response ส่งกลับมาเป็นคีย์ `address`)
  @JsonKey(name: 'address_line')
  final String addressLine;

  @JsonKey(name: 'note')
  final String? note;

  factory AddressRequest.fromJson(Map<String, dynamic> json) =>
      _$AddressRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddressRequestToJson(this);
}
