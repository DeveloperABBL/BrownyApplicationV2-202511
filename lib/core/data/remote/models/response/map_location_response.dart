import 'package:browny_applications_new/core/const/app_constants.dart';
import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'map_location_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart pub run build_runner build --delete-conflicting-outputs
// **************************************************************************

/// DONG 2026-01-28
///
/// Response model สำหรับ API fetch map locations
@JsonSerializable()
class MapLocationResponse {
  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'data')
  final List<StoreLocationItem>? data;

  MapLocationResponse({
    required this.success,
    this.data,
  });

  factory MapLocationResponse.fromJson(Map<String, dynamic> json) =>
      _$MapLocationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MapLocationResponseToJson(this);
}

/// DONG 2026-01-28
///
/// Model สำหรับข้อมูล location แต่ละรายการ
@JsonSerializable()
class StoreLocationItem {
  @JsonKey(includeFromJson: false, includeToJson: false)
  static const String kService1 = 'browny';

  @JsonKey(includeFromJson: false, includeToJson: false)
  static const String kService2 = 'browny_plus';

  @JsonKey(includeFromJson: false, includeToJson: false)
  static const String kService3 = 'charging_station';

  @JsonKey(includeFromJson: false, includeToJson: false)
  static const Set<String> servicesType = {
    kService1,
    kService2,
    kService3,
  };

  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'code')
  final String? code;

  @JsonKey(name: 'latitude')
  final String? latitude;

  @JsonKey(name: 'longitude')
  final String? longitude;

  @JsonKey(name: 'rating')
  final String? rating;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @JsonKey(name: 'total_washer')
  final String? totalWasher;

  @JsonKey(name: 'vacant_washer')
  final String? vacantWasher;

  @JsonKey(name: 'total_dryer')
  final String? totalDryer;

  @JsonKey(name: 'vacant_dryer')
  final String? vacantDryer;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  @JsonKey(name: 'address')
  final ContentLocalizeData? address;

  @JsonKey(name: 'marker_icon_active')
  final String? markerIconActiveUrl;

  @JsonKey(name: 'marker_icon_inactive')
  final String? markerIconInactiveUrl;

  /// BitmapDescriptor สำหรับ marker icon active (ไม่ได้จาก JSON)
  @JsonKey(includeFromJson: false, includeToJson: false)
  BitmapDescriptor? markerIconActive;

  /// BitmapDescriptor สำหรับ marker icon inactive (ไม่ได้จาก JSON)
  @JsonKey(includeFromJson: false, includeToJson: false)
  BitmapDescriptor? markerIconInactive;

  // เก็บ Icon สำหรับแสดงตอน Search
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? icon;

  // เก็บระยะห่างจากจุดมาถึง latlong ของ store
  // คำนวณแบบกระจัด
  @JsonKey(includeFromJson: false, includeToJson: false)
  final double? distance;

  StoreLocationItem({
    this.type,
    this.id,
    this.code,
    this.latitude,
    this.longitude,
    this.rating,
    this.imageUrl,
    this.totalWasher,
    this.vacantWasher,
    this.totalDryer,
    this.vacantDryer,
    this.name,
    this.address,
    this.markerIconActiveUrl,
    this.markerIconInactiveUrl,
    this.markerIconActive,
    this.markerIconInactive,
    this.icon,
    this.distance,
  });

  factory StoreLocationItem.fromJson(Map<String, dynamic> json) =>
      _$StoreLocationItemFromJson(json);

  Map<String, dynamic> toJson() => _$StoreLocationItemToJson(this);

  /// Helper: แปลง latitude เป็น double
  double get latitudeValue => double.tryParse(latitude ?? '') ?? 0.0;

  /// Helper: แปลง longitude เป็น double
  double get longitudeValue => double.tryParse(longitude ?? '') ?? 0.0;

  /// Helper: แปลง rating เป็น double
  double get ratingValue => double.tryParse(rating ?? '') ?? 0.0;

  /// Helper: แปลง total_washer เป็น int
  int get totalWasherValue => int.tryParse(totalWasher ?? '') ?? 0;

  /// Helper: แปลง vacant_washer เป็น int
  int get vacantWasherValue => int.tryParse(vacantWasher ?? '') ?? 0;

  /// Helper: แปลง total_dryer เป็น int
  int get totalDryerValue => int.tryParse(totalDryer ?? '') ?? 0;

  /// Helper: แปลง vacant_dryer เป็น int
  int get vacantDryerValue => int.tryParse(vacantDryer ?? '') ?? 0;

  /// Helper: ดึงชื่อตาม locale
  String getLocalizedName(String locale) {
    if (name == null) return '';
    return name!.getByLocaleCode(locale) ?? name!.th ?? name!.en ?? '';
  }

  String getDistaceDisplay(
    String locale, {
    bool needSymbol = false,
  }) {
    if (distance == null) {
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
    if (distance! < 0) {
      return '$distance $unit';
    }

    double distanceRounded = distance!.roundToDouble();
    if (needSymbol) {
      if (distanceRounded != distance!) {
        if (distanceRounded > distance!) {
          symbol = "<";
        } else {
          symbol = ">";
        }
      }
    }

    // ถ้าค่าเกิน 1000 เมตร จะคำนวณเป็น กม.
    if (distance! > 1000) {
      distanceRounded = (distance! / 1000.0);

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

  String getNearestDisplay(String locale) {
    final distanceDisplay = getDistaceDisplay(locale);
    switch (locale) {
      case 'zh':
        return 'ใกล้ที่สุด $distanceDisplay';
      case 'en':
        return 'ใกล้ที่สุด $distanceDisplay';
      default:
        return 'ใกล้ที่สุด $distanceDisplay';
    }
  }

  String getTypeToTypeName(String locale) {
    if (type == 'browny') {
      switch (locale) {
        case 'zh':
          return 'บริการซักอบ';
        case 'en':
          return 'บริการซักอบ';
        default:
          return 'บริการซักอบ';
      }
    }
    if (type == 'browny_plus') {
      switch (locale) {
        case 'zh':
          return 'บริการซัก อบ พับ';
        case 'en':
          return 'บริการซัก อบ พับ';
        default:
          return 'บริการซัก อบ พับ';
      }
    }
    if (type == 'charging_station') {
      switch (locale) {
        case 'zh':
          return 'บริการชาร์จ EV';
        case 'en':
          return 'บริการชาร์จ EV';
        default:
          return 'บริการชาร์จ EV';
      }
    }

    return '';
  }

  /// Helper: ดึง address ตาม locale
  String getLocalizedAddress(String locale) {
    if (address == null) return '';
    return address!.getByLocaleCode(locale) ?? address!.th ?? address!.en ?? '';
  }

  /// Copy with method สำหรับ update marker icons
  StoreLocationItem copyWith({
    String? type,
    int? id,
    String? code,
    String? latitude,
    String? longitude,
    String? rating,
    String? imageUrl,
    String? totalWasher,
    String? vacantWasher,
    String? totalDryer,
    String? vacantDryer,
    ContentLocalizeData? name,
    ContentLocalizeData? address,
    String? markerIconActiveUrl,
    String? markerIconInactiveUrl,
    BitmapDescriptor? markerIconActive,
    BitmapDescriptor? markerIconInactive,
    String? icon,
    double? distance,
  }) {
    return StoreLocationItem(
      type: type ?? this.type,
      id: id ?? this.id,
      code: code ?? this.code,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      totalWasher: totalWasher ?? this.totalWasher,
      vacantWasher: vacantWasher ?? this.vacantWasher,
      totalDryer: totalDryer ?? this.totalDryer,
      vacantDryer: vacantDryer ?? this.vacantDryer,
      name: name ?? this.name,
      address: address ?? this.address,
      markerIconActiveUrl: markerIconActiveUrl ?? this.markerIconActiveUrl,
      markerIconInactiveUrl:
          markerIconInactiveUrl ?? this.markerIconInactiveUrl,
      markerIconActive: markerIconActive ?? this.markerIconActive,
      markerIconInactive: markerIconInactive ?? this.markerIconInactive,
      icon: icon ?? this.icon,
      distance: distance ?? this.distance,
    );
  }
}
