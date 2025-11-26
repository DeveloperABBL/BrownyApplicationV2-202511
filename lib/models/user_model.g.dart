// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  loginPlatform: json['loginPlatform'] as String,
  isFriendRewardOn: json['isFriendRewardOn'] as bool,
  isGuest: json['isGuest'] as bool,
  id: json['id'] as String?,
  name: json['name'] as String?,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  gender: json['gender'] as String?,
  birthday: json['birthday'] as String?,
  image: json['profile_image'] as String?,
  creditBalance: json['credit_balance'] as String?,
  brownyCoin: json['browny_coin'] as String?,
  avatars: (json['avatars'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'gender': instance.gender,
  'birthday': instance.birthday,
  'profile_image': instance.image,
  'credit_balance': instance.creditBalance,
  'browny_coin': instance.brownyCoin,
  'avatars': instance.avatars,
  'loginPlatform': instance.loginPlatform,
  'isFriendRewardOn': instance.isFriendRewardOn,
  'isGuest': instance.isGuest,
};
