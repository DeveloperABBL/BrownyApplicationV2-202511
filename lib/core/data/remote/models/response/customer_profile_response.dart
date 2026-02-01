import 'package:json_annotation/json_annotation.dart';
import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';

part 'customer_profile_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable(explicitToJson: true)
class CustomerProfileResponse extends BaseModelResponse {
  CustomerProfileResponse({
    required this.data,
    super.success,
    super.errorType,
    super.message,
  });

  @JsonKey(name: 'data')
  final CustomerProfileData data;

  CustomerProfileResponse copyWith({
    CustomerProfileData? data,
    bool? success,
    String? errorType,
    String? message,
  }) {
    return CustomerProfileResponse(
      data: data ?? this.data,
      success: success ?? this.success,
      errorType: errorType ?? this.errorType,
      message: message ?? this.message,
    );
  }

  factory CustomerProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$CustomerProfileResponseFromJson(json);
  Map<String, dynamic> toJson() =>
      baseToJson(_$CustomerProfileResponseToJson(this));
}

@JsonSerializable()
class CustomerProfileData {
  CustomerProfileData({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.gender,
    this.birthday,
    this.image,
    this.creditBalance,
    this.brownyCoin,
    this.avatars,
    this.couponsRedemption,
    this.couponsDiscount,
    this.couponsEVoucher,
    this.totalCoupons,
  });

  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'phone')
  final String? phone;

  @JsonKey(name: 'gender')
  final String? gender;

  @JsonKey(name: 'birthdate')
  final String? birthday;

  @JsonKey(name: 'profile_image')
  final String? image;

  @JsonKey(name: 'credit_balance')
  final String? creditBalance;

  @JsonKey(name: 'browny_coin')
  final String? brownyCoin;

  @JsonKey(name: 'avatars')
  final List<String>? avatars;

  @JsonKey(name: 'coupons_redemption')
  final int? couponsRedemption;

  @JsonKey(name: 'coupons_discount')
  final int? couponsDiscount;

  @JsonKey(name: 'coupons_e_voucher')
  final int? couponsEVoucher;

  @JsonKey(name: 'total_coupons')
  final int? totalCoupons;

  CustomerProfileData copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? birthday,
    String? image,
    String? creditBalance,
    String? brownyCoin,
    List<String>? avatars,
    int? couponsRedemption,
    int? couponsDiscount,
    int? couponsEVoucher,
    int? totalCoupons,
  }) {
    return CustomerProfileData(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      image: image ?? this.image,
      creditBalance: creditBalance ?? this.creditBalance,
      brownyCoin: brownyCoin ?? this.brownyCoin,
      avatars: avatars ?? this.avatars,
      couponsRedemption: couponsRedemption ?? this.couponsRedemption,
      couponsDiscount: couponsDiscount ?? this.couponsDiscount,
      couponsEVoucher: couponsEVoucher ?? this.couponsEVoucher,
      totalCoupons: totalCoupons ?? this.totalCoupons,
    );
  }

  factory CustomerProfileData.fromJson(Map<String, dynamic> json) =>
      _$CustomerProfileDataFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerProfileDataToJson(this);
}
