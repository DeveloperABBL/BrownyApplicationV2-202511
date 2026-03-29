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
      firstLogin: fields[7] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, LoginCustomerData obj) {
    writer
      ..writeByte(7)
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
      ..write(obj.loginPlatform)
      ..writeByte(7)
      ..write(obj.firstLogin);
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
      couponsRedemption: (fields[10] as num?)?.toInt(),
      couponsDiscount: (fields[11] as num?)?.toInt(),
      couponsEVoucher: (fields[12] as num?)?.toInt(),
      totalCoupons: (fields[13] as num?)?.toInt(),
      coinValue: fields[14] as String?,
      currentCoin: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerProfileData obj) {
    writer
      ..writeByte(16)
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
      ..write(obj.brownyCoin)
      ..writeByte(10)
      ..write(obj.couponsRedemption)
      ..writeByte(11)
      ..write(obj.couponsDiscount)
      ..writeByte(12)
      ..write(obj.couponsEVoucher)
      ..writeByte(13)
      ..write(obj.totalCoupons)
      ..writeByte(14)
      ..write(obj.coinValue)
      ..writeByte(15)
      ..write(obj.currentCoin);
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

class StoreSearchHistoryAdapter extends TypeAdapter<StoreSearchHistory> {
  @override
  final typeId = 2;

  @override
  StoreSearchHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoreSearchHistory(
      packageId: (fields[0] as num).toInt(),
      storeId: (fields[1] as num?)?.toInt(),
      storeName: fields[2] as String,
      packageName: fields[3] as String,
      groupOption: fields[4] as String?,
      distance: fields[5] as String?,
      searchedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, StoreSearchHistory obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.packageId)
      ..writeByte(1)
      ..write(obj.storeId)
      ..writeByte(2)
      ..write(obj.storeName)
      ..writeByte(3)
      ..write(obj.packageName)
      ..writeByte(4)
      ..write(obj.groupOption)
      ..writeByte(5)
      ..write(obj.distance)
      ..writeByte(6)
      ..write(obj.searchedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreSearchHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
