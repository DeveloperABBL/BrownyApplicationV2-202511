// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_credential.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerCredential _$CustomerCredentialFromJson(Map<String, dynamic> json) =>
    CustomerCredential(
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$CustomerCredentialToJson(CustomerCredential instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };
