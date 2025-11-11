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
      id: fields[0] as String?,
      name: fields[1] as String?,
      email: fields[2] as String?,
      phone: fields[3] as String?,
      profileImage: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LoginCustomerData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.profileImage);
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
