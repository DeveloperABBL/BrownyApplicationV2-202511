// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class LoginCustomerDataAdapter extends TypeAdapter<LoginCustomerData> {
  @override
  final typeId = 0;

  @override
  LoginCustomerData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoginCustomerData(
      customerId: fields[5] as String?,
      loginPlatform: fields[6] as String?,
      email: fields[2] as String?,
      phone: fields[3] as String?,
      name: fields[1] as String?,
      profileImage: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LoginCustomerData obj) {
    writer
      ..writeByte(6)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.profileImage)
      ..writeByte(5)
      ..write(obj.customerId)
      ..writeByte(6)
      ..write(obj.loginPlatform);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginCustomerDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CustomerProfileDataAdapter extends TypeAdapter<CustomerProfileData> {
  @override
  final typeId = 1;

  @override
  CustomerProfileData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerProfileData(
      id: fields[0] as String?,
      name: fields[1] as String?,
      email: fields[2] as String?,
      phone: fields[3] as String?,
      gender: fields[4] as String?,
      birthday: fields[5] as String?,
      image: fields[6] as String?,
      creditBalance: fields[7] as String?,
      brownyCoin: fields[9] as String?,
      avatars: (fields[8] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, CustomerProfileData obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.gender)
      ..writeByte(5)
      ..write(obj.birthday)
      ..writeByte(6)
      ..write(obj.image)
      ..writeByte(7)
      ..write(obj.creditBalance)
      ..writeByte(8)
      ..write(obj.avatars)
      ..writeByte(9)
      ..write(obj.brownyCoin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerProfileDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
