// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_customer_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginCustomerResponse _$LoginCustomerResponseFromJson(
  Map<String, dynamic> json,
) => LoginCustomerResponse(
  success: json['success'] as bool?,
  errorType: json['error_type'] as String?,
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : LoginCustomerData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LoginCustomerResponseToJson(
  LoginCustomerResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'data': instance.data?.toJson(),
};

LoginCustomerData _$LoginCustomerDataFromJson(Map<String, dynamic> json) =>
    LoginCustomerData(
      customerId: json['id'] as String?,
      loginPlatform: json['loginPlatform'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      name: json['name'] as String?,
      profileImage: json['profile_image'] as String?,
    );

Map<String, dynamic> _$LoginCustomerDataToJson(LoginCustomerData instance) =>
    <String, dynamic>{
      'id': instance.customerId,
      'loginPlatform': instance.loginPlatform,
      'email': instance.email,
      'phone': instance.phone,
      'name': instance.name,
      'profile_image': instance.profileImage,
    };
