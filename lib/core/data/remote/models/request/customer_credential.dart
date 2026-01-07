import 'package:json_annotation/json_annotation.dart';

part 'customer_credential.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart pub run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class CustomerCredential {
  @JsonKey(name: 'username')
  final String username;

  @JsonKey(name: 'password')
  final String password;

  @JsonKey(name: 'referrer_contact')
  final String? referrerContact;

  @JsonKey(name: 'customer_id')
  final String? customerId;

  CustomerCredential({
    required this.username,
    required this.password,
    this.referrerContact,
    this.customerId,
  });

  factory CustomerCredential.fromJson(Map<String, dynamic> json) =>
      _$CustomerCredentialFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerCredentialToJson(this);
}
