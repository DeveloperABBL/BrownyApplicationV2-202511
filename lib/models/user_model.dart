import 'package:browny_applications_new/core/data/remote/models/response/customer_profile_response.dart';
import 'package:browny_applications_new/models/avatar_data.dart';
import 'package:image_picker/image_picker.dart';
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
    List<AvatarData>? avatarDataList,
  }) : avatarDataList = avatarDataList ?? [];

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
    avatarDataList: [],
    isGuest: true,
  );

  factory UserModel.fromCustomerProfileData(
    CustomerProfileData data, {
    String loginPlatform = 'Phone/Email',
    bool isFriendRewardOn = false,
  }) {
    // แปลง List<String> จาก API เป็น List<AvatarData>
    final avatarDataList = (data.avatars ?? [])
        .map((url) => AvatarData.fromUrl(url))
        .toList();

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
      avatarDataList: avatarDataList,
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
    List<AvatarData>? avatarDataList,
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
      avatarDataList: avatarDataList ?? this.avatarDataList,
    );
  }

  @JsonKey(name: 'loginPlatform')
  final String loginPlatform;

  @JsonKey(name: 'isFriendRewardOn')
  final bool isFriendRewardOn;

  @JsonKey(name: 'isGuest')
  final bool isGuest;

  /// List ของ AvatarData ที่รวมทั้งจาก API และ ImagePicker
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<AvatarData> avatarDataList;

  /// Helper method: อัพเดท/เพิ่ม avatar ที่ pick จาก ImagePicker
  /// ถ้ามี picked avatar อยู่แล้ว จะ replace ไม่ใช่ add เพิ่ม
  /// Picked image จะอยู่ที่ index 0 เสมอ
  UserModel setPickedAvatar(XFile file) {
    final newAvatarData = AvatarData.fromFile(file);
    final updatedList = List<AvatarData>.from(avatarDataList);

    // หา index แรกที่เป็น picked image
    final pickedIndex = updatedList.indexWhere((avatar) => avatar.isFromPicker);

    if (pickedIndex != -1) {
      // ถ้ามี picked image อยู่แล้ว ให้ replace
      updatedList[pickedIndex] = newAvatarData;
    } else {
      // ถ้ายังไม่มี ให้ add เข้าไปข้างหน้า
      updatedList.insert(0, newAvatarData);
    }

    return copyWith(avatarDataList: updatedList);
  }

  /// Helper method: ลบ avatar ตาม index
  UserModel removeAvatarAt(int index) {
    if (index < 0 || index >= avatarDataList.length) {
      return this;
    }
    final updatedList = List<AvatarData>.from(avatarDataList)..removeAt(index);
    return copyWith(avatarDataList: updatedList);
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = _$UserModelFromJson(json);
    // แปลง avatars เป็น avatarDataList
    final avatarDataList = (user.avatars ?? [])
        .map((url) => AvatarData.fromUrl(url))
        .toList();
    return user.copyWith(avatarDataList: avatarDataList);
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
