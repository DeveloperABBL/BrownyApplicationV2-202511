// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_location_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapLocationResponse _$MapLocationResponseFromJson(Map<String, dynamic> json) =>
    MapLocationResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => StoreLocationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MapLocationResponseToJson(
  MapLocationResponse instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

StoreLocationItem _$StoreLocationItemFromJson(Map<String, dynamic> json) =>
    StoreLocationItem(
      type: json['type'] as String?,
      id: (json['id'] as num?)?.toInt(),
      code: json['code'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      rating: json['rating'] as String?,
      imageUrl: json['image_url'] as String?,
      totalWasher: json['total_washer'] as String?,
      vacantWasher: json['vacant_washer'] as String?,
      totalDryer: json['total_dryer'] as String?,
      vacantDryer: json['vacant_dryer'] as String?,
      name: json['name'] == null
          ? null
          : ContentLocalizeData.fromJson(json['name'] as Map<String, dynamic>),
      address: json['address'] == null
          ? null
          : ContentLocalizeData.fromJson(
              json['address'] as Map<String, dynamic>,
            ),
      markerIconActiveUrl: json['marker_icon_active'] as String?,
      markerIconInactiveUrl: json['marker_icon_inactive'] as String?,
    );

Map<String, dynamic> _$StoreLocationItemToJson(StoreLocationItem instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'code': instance.code,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'rating': instance.rating,
      'image_url': instance.imageUrl,
      'total_washer': instance.totalWasher,
      'vacant_washer': instance.vacantWasher,
      'total_dryer': instance.totalDryer,
      'vacant_dryer': instance.vacantDryer,
      'name': instance.name,
      'address': instance.address,
      'marker_icon_active': instance.markerIconActiveUrl,
      'marker_icon_inactive': instance.markerIconInactiveUrl,
    };
