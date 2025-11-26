import 'package:browny_applications_new/core/data/remote/models/response/customer_profile_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// ´
// **************************************************************************

@JsonSerializable()
class UserModel extends CustomerProfileData {
  UserModel({
    required this.loginPlatform,
    required this.isFriendRewardOn,
    required this.isGuest,
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.gender,
    required super.birthday,
    required super.image,
    required super.creditBalance,
    required super.brownyCoin,
    required super.avatars,
  });

  factory UserModel.guest() => UserModel(
    name: '',
    phone: '',
    email: '',
    birthday: '',
    image: '',
    gender: '',
    loginPlatform: '',
    isFriendRewardOn: false,
    id: '',
    creditBalance: '',
    brownyCoin: '',
    avatars: [],
    isGuest: true,
  );

  factory UserModel.fromCustomerProfileData(
    CustomerProfileData data, {
    String loginPlatform = 'Phone/Email',
    bool isFriendRewardOn = false,
  }) {
    return UserModel(
      id: data.id,
      name: data.name,
      email: data.email,
      phone: data.phone,
      gender: data.gender,
      birthday: data.birthday,
      image: data.image,
      creditBalance: data.creditBalance,
      brownyCoin: data.brownyCoin,
      avatars: data.avatars,
      loginPlatform: loginPlatform,
      isFriendRewardOn: isFriendRewardOn,
      isGuest: false,
    );
  }

  @override
  UserModel copyWith({
    String? loginPlatform,
    bool? isFriendRewardOn,
    bool? isGuest,
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
  }) {
    return UserModel(
      loginPlatform: loginPlatform ?? this.loginPlatform,
      isFriendRewardOn: isFriendRewardOn ?? this.isFriendRewardOn,
      isGuest: isGuest ?? this.isGuest,
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
    );
  }

  @JsonKey(name: 'loginPlatform')
  final String loginPlatform;

  @JsonKey(name: 'isFriendRewardOn')
  final bool isFriendRewardOn;

  @JsonKey(name: 'isGuest')
  final bool isGuest;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
