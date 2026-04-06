import 'package:browny_applications_new/core/const/app_constants.dart';
import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'store_detail_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class StoreDetailResponse {
  StoreDetailResponse({
    this.status,
    this.data,
  });

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'data')
  final StoreDataDetail? data;

  factory StoreDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$StoreDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StoreDetailResponseToJson(this);
}

@JsonSerializable()
class StoreDataDetail {
  StoreDataDetail({
    this.id,
    this.branchCode,
    this.firebaseCode,
    this.storeType,
    this.storeName,
    this.storeAddress,
    this.typeName,
    this.icon,
    this.image,
    this.googleMapLink,
    this.placeId,
    this.googleReviewLink,
    this.latitude,
    this.longitude,
    this.managerName,
    this.managerPhone,
    this.rating,
    this.services,
    this.distance,
    this.name,
    this.address,
    this.markerIconActive,
    this.markerIconInactive,
    this.machines,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'branch_code')
  final String? branchCode;

  @JsonKey(name: 'firebase_code')
  final String? firebaseCode;

  @JsonKey(name: 'store_type')
  final String? storeType;

  @JsonKey(name: 'store_name')
  final ContentLocalizeData? storeName;

  @JsonKey(name: 'store_address')
  final ContentLocalizeData? storeAddress;

  @JsonKey(name: 'type_name')
  final ContentLocalizeData? typeName;

  @JsonKey(name: 'icon')
  final String? icon;

  @JsonKey(name: 'image')
  final String? image;

  @JsonKey(name: 'google_map_link')
  final String? googleMapLink;

  @JsonKey(name: 'place_id')
  final String? placeId;

  @JsonKey(name: 'google_review_link')
  final String? googleReviewLink;

  @JsonKey(name: 'latitude')
  final String? latitude;

  @JsonKey(name: 'longitude')
  final String? longitude;

  @JsonKey(name: 'manager_name')
  final String? managerName;

  @JsonKey(name: 'manager_phone')
  final String? managerPhone;

  @JsonKey(name: 'rating')
  final String? rating;

  @JsonKey(name: 'services')
  final List<ServiceData>? services;

  @JsonKey(name: 'distance')
  final String? distance;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  @JsonKey(name: 'address')
  final ContentLocalizeData? address;

  @JsonKey(name: 'marker_icon_active')
  final String? markerIconActive;

  @JsonKey(name: 'marker_icon_inactive')
  final String? markerIconInactive;

  @JsonKey(name: 'machines')
  final MachinesData? machines;

  // ========== Utility Getters ==========

  /// ชื่อร้านค้า (ใช้ store_name ก่อน ถ้าไม่มีใช้ name)
  ContentLocalizeData? get displayName => storeName ?? name;
  String getStoreNameDisplay(String locale) {
    return displayName?.getByLocaleCode(locale) ?? '';
  }

  /// ที่อยู่ร้านค้า (ใช้ store_address ก่อน ถ้าไม่มีใช้ address)
  ContentLocalizeData? get displayAddress => storeAddress ?? address;
  String getDisplayAddressDisplay(String locale) {
    return displayAddress?.getByLocaleCode(locale) ?? '';
  }

  String getTypeNameDisplay(String locale) {
    return typeName?.getByLocaleCode(locale) ?? '';
  }

  /// ระยะทางเป็น double (เมตร)
  double? get distanceValue {
    if (distance == null) return null;
    return double.tryParse(distance!);
  }

  String getDistaceDisplay(
    String locale, {
    bool needSymbol = false,
  }) {
    if (distanceValue == null) {
      return '-';
    }
    // Unit ที่จะแสดงหน้า UI
    String unit;
    // symbol < > จากการคำนวณระยะห่างแบบ round แล้ว
    String symbol = '';

    switch (locale) {
      case 'zh':
      case 'en':
        unit = 'm';
        break;
      default:
        unit = 'ม.';
    }
    // ดักไว้ถ้าค่าติดลบ(อาจจะไม่เกิด) จะ return 0
    if (distanceValue! < 0) {
      return '$distanceValue $unit';
    }

    double distanceRounded = distanceValue!.roundToDouble();
    if (needSymbol) {
      if (distanceRounded != distanceValue!) {
        if (distanceRounded > distanceValue!) {
          symbol = "<";
        } else {
          symbol = ">";
        }
      }
    }

    // ถ้าค่าเกิน 1000 เมตร จะคำนวณเป็น กม.
    if (distanceValue! > 1000) {
      distanceRounded = (distanceValue! / 1000.0);

      switch (locale) {
        case 'zh':
        case 'en':
          unit = 'km';
          break;
        default:
          unit = 'กม.';
      }
    }
    return formatDistance(
      leadingSign: symbol,
      value: distanceRounded,
      trailingSign: ' $unit',
    );
    // return '$symbol${distanceRounded.toInt()} $unit';
  }

  /// ระยะทางเป็นกิโลเมตร
  double? get distanceInKm {
    final dist = distanceValue;
    if (dist == null) return null;
    return dist / 1000;
  }

  /// Rating เป็น double
  double? get ratingValue {
    if (rating == null) return null;
    return double.tryParse(rating!);
  }

  /// Latitude เป็น double
  double get latitudeValue {
    if (latitude == null) return 0.0;
    return double.tryParse(latitude!) ?? 0.0;
  }

  /// Longitude เป็น double
  double get longitudeValue {
    if (longitude == null) return 0.0;
    return double.tryParse(longitude!) ?? 0.0;
  }

  /// จำนวนเครื่องซักทั้งหมด
  int get totalWashers => machines?.washer?.length ?? 0;

  /// จำนวนเครื่องอบทั้งหมด
  int get totalDryers => machines?.dryer?.length ?? 0;

  /// จำนวนเครื่องซักที่ว่าง (active = true)
  int get availableWasherCount =>
      machines?.washer?.where((m) => m.active == true).length ?? 0;

  /// จำนวนเครื่องอบที่ว่าง (active = true)
  int get availableDryerCount =>
      machines?.dryer?.where((m) => m.active == true).length ?? 0;

  /// เครื่องซักทั้งหมดว่าง
  bool get hasAvailableWashers => availableWasherCount > 0;

  /// เครื่องอบทั้งหมดว่าง
  bool get hasAvailableDryers => availableDryerCount > 0;

  /// มีเครื่องว่างอย่างน้อย 1 เครื่อง (ซักหรืออบ)
  bool get hasAvailableMachines => hasAvailableWashers || hasAvailableDryers;

  factory StoreDataDetail.fromJson(Map<String, dynamic> json) =>
      _$StoreDataDetailFromJson(json);

  Map<String, dynamic> toJson() => _$StoreDataDetailToJson(this);
}

@JsonSerializable()
class ServiceData {
  ServiceData({
    this.name,
    this.icon,
  });

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  @JsonKey(name: 'icon')
  final String? icon;

  factory ServiceData.fromJson(Map<String, dynamic> json) =>
      _$ServiceDataFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceDataToJson(this);
}

@JsonSerializable()
class MachinesData {
  MachinesData({
    this.washer,
    this.dryer,
  });

  @JsonKey(name: 'washer')
  final List<MachineData>? washer;

  @JsonKey(name: 'dryer')
  final List<MachineData>? dryer;

  /// เครื่องซักที่ว่าง
  List<MachineData> get availableWashers =>
      washer?.where((m) => m.active == true).toList() ?? [];

  /// เครื่องอบที่ว่าง
  List<MachineData> get availableDryers =>
      dryer?.where((m) => m.active == true).toList() ?? [];

  /// เครื่องซักที่ไม่ว่าง
  List<MachineData> get busyWashers =>
      washer?.where((m) => m.active != true).toList() ?? [];

  /// เครื่องอบที่ไม่ว่าง
  List<MachineData> get busyDryers =>
      dryer?.where((m) => m.active != true).toList() ?? [];

  factory MachinesData.fromJson(Map<String, dynamic> json) =>
      _$MachinesDataFromJson(json);

  Map<String, dynamic> toJson() => _$MachinesDataToJson(this);
}

@JsonSerializable()
class MachineData {
  MachineData({
    this.id,
    this.name,
    this.status,
    this.active,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'status')
  final ContentLocalizeData? status;

  @JsonKey(name: 'active')
  final bool? active;

  /// เครื่องว่าง (available)
  bool get isMachineAcive => active == true;

  bool isAvailable(String locale) {
    if (status == null) return false;

    switch (locale) {
      case 'en':
        return status!.getByLocaleCode(locale)!.contains('Vacant');
      case 'zh':
        return status!.getByLocaleCode(locale)!.contains('空闲');
      default:
        return status!.getByLocaleCode(locale)!.contains('ว่าง');
    }
  }

  /// เครื่องไม่ว่าง (busy)
  bool get isBusy => active != true;

  factory MachineData.fromJson(Map<String, dynamic> json) =>
      _$MachineDataFromJson(json);

  Map<String, dynamic> toJson() => _$MachineDataToJson(this);
}
