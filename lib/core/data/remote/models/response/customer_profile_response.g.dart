// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerProfileResponse _$CustomerProfileResponseFromJson(
  Map<String, dynamic> json,
) => CustomerProfileResponse(
  data: CustomerProfileData.fromJson(json['data'] as Map<String, dynamic>),
  success: json['success'] as bool?,
  errorType: json['error_type'] as String?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$CustomerProfileResponseToJson(
  CustomerProfileResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'data': instance.data.toJson(),
};

CustomerProfileData _$CustomerProfileDataFromJson(Map<String, dynamic> json) =>
    CustomerProfileData(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      birthday: json['birthdate'] as String?,
      image: json['profile_image'] as String?,
      creditBalance: json['credit_balance'] as String?,
      brownyCoin: json['browny_coin'] as String?,
      avatars: (json['avatars'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      couponsRedemption: (json['coupons_redemption'] as num?)?.toInt(),
      couponsDiscount: (json['coupons_discount'] as num?)?.toInt(),
      couponsEVoucher: (json['coupons_e_voucher'] as num?)?.toInt(),
      totalCoupons: (json['total_coupons'] as num?)?.toInt(),
      coinValue: json['coin_value'] as String?,
      currentCoin: json['current_coin'] as String?,
    );

Map<String, dynamic> _$CustomerProfileDataToJson(
  CustomerProfileData instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'gender': instance.gender,
  'birthdate': instance.birthday,
  'profile_image': instance.image,
  'credit_balance': instance.creditBalance,
  'browny_coin': instance.brownyCoin,
  'avatars': instance.avatars,
  'coupons_redemption': instance.couponsRedemption,
  'coupons_discount': instance.couponsDiscount,
  'coupons_e_voucher': instance.couponsEVoucher,
  'total_coupons': instance.totalCoupons,
  'coin_value': instance.coinValue,
  'current_coin': instance.currentCoin,
};
