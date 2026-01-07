// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_credential.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerCredential _$CustomerCredentialFromJson(Map<String, dynamic> json) =>
    CustomerCredential(
      username: json['username'] as String,
      password: json['password'] as String,
      referrerContact: json['referrer_contact'] as String?,
      customerId: json['customer_id'] as String?,
    );

Map<String, dynamic> _$CustomerCredentialToJson(CustomerCredential instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'referrer_contact': instance.referrerContact,
      'customer_id': instance.customerId,
    };
