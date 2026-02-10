import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_customer_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart pub run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// {
///   "success": true,
///   "message": "เข้าสู่ระบบสำเร็จ",
///   "data": {
///     "id": "uuid",
///     "name": null,
///     "email": null,
///     "phone": "0912345678",
///     "profile_image": null
///   }
/// }
@JsonSerializable(explicitToJson: true)
class LoginCustomerResponse extends BaseModelResponse {
  LoginCustomerResponse({
    super.success,
    super.errorType,
    super.message,
    this.data,
  });

  @JsonKey(name: 'data')
  final LoginCustomerData? data;

  factory LoginCustomerResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginCustomerResponseFromJson(json);
  Map<String, dynamic> toJson() =>
      baseToJson(_$LoginCustomerResponseToJson(this));
}

@JsonSerializable()
class LoginCustomerData {
  LoginCustomerData({
    required this.customerId,
    required this.loginPlatform,
    required this.email,
    required this.phone,
    required this.name,
    required this.profileImage,
    required this.firstLogin,
  });

  @JsonKey(name: 'id')
  final String? customerId;

  @JsonKey(name: 'loginPlatform')
  final String? loginPlatform;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'phone')
  final String? phone;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'profile_image')
  final String? profileImage;

  @JsonKey(name: 'first_login')
  final bool? firstLogin;

  factory LoginCustomerData.fromJson(Map<String, dynamic> json) =>
      _$LoginCustomerDataFromJson(json);

  Map<String, dynamic> toJson() => _$LoginCustomerDataToJson(this);
}
