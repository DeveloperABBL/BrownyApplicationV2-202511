// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreDetailResponse _$StoreDetailResponseFromJson(Map<String, dynamic> json) =>
    StoreDetailResponse(
      status: json['status'] as String?,
      data: json['data'] == null
          ? null
          : StoreDataDetail.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StoreDetailResponseToJson(
  StoreDetailResponse instance,
) => <String, dynamic>{'status': instance.status, 'data': instance.data};

StoreDataDetail _$StoreDataDetailFromJson(
  Map<String, dynamic> json,
) => StoreDataDetail(
  id: (json['id'] as num?)?.toInt(),
  branchCode: json['branch_code'] as String?,
  firebaseCode: json['firebase_code'] as String?,
  storeType: json['store_type'] as String?,
  storeName: json['store_name'] == null
      ? null
      : ContentLocalizeData.fromJson(
          json['store_name'] as Map<String, dynamic>,
        ),
  storeAddress: json['store_address'] == null
      ? null
      : ContentLocalizeData.fromJson(
          json['store_address'] as Map<String, dynamic>,
        ),
  typeName: json['type_name'] == null
      ? null
      : ContentLocalizeData.fromJson(json['type_name'] as Map<String, dynamic>),
  icon: json['icon'] as String?,
  image: json['image'] as String?,
  googleMapLink: json['google_map_link'] as String?,
  placeId: json['place_id'] as String?,
  googleReviewLink: json['google_review_link'] as String?,
  latitude: json['latitude'] as String?,
  longitude: json['longitude'] as String?,
  managerName: json['manager_name'] as String?,
  managerPhone: json['manager_phone'] as String?,
  rating: json['rating'] as String?,
  services: (json['services'] as List<dynamic>?)
      ?.map((e) => ServiceData.fromJson(e as Map<String, dynamic>))
      .toList(),
  distance: json['distance'] as String?,
  name: json['name'] == null
      ? null
      : ContentLocalizeData.fromJson(json['name'] as Map<String, dynamic>),
  address: json['address'] == null
      ? null
      : ContentLocalizeData.fromJson(json['address'] as Map<String, dynamic>),
  markerIconActive: json['marker_icon_active'] as String?,
  markerIconInactive: json['marker_icon_inactive'] as String?,
  machines: json['machines'] == null
      ? null
      : MachinesData.fromJson(json['machines'] as Map<String, dynamic>),
);

Map<String, dynamic> _$StoreDataDetailToJson(StoreDataDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'branch_code': instance.branchCode,
      'firebase_code': instance.firebaseCode,
      'store_type': instance.storeType,
      'store_name': instance.storeName,
      'store_address': instance.storeAddress,
      'type_name': instance.typeName,
      'icon': instance.icon,
      'image': instance.image,
      'google_map_link': instance.googleMapLink,
      'place_id': instance.placeId,
      'google_review_link': instance.googleReviewLink,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'manager_name': instance.managerName,
      'manager_phone': instance.managerPhone,
      'rating': instance.rating,
      'services': instance.services,
      'distance': instance.distance,
      'name': instance.name,
      'address': instance.address,
      'marker_icon_active': instance.markerIconActive,
      'marker_icon_inactive': instance.markerIconInactive,
      'machines': instance.machines,
    };

ServiceData _$ServiceDataFromJson(Map<String, dynamic> json) => ServiceData(
  name: json['name'] == null
      ? null
      : ContentLocalizeData.fromJson(json['name'] as Map<String, dynamic>),
  icon: json['icon'] as String?,
);

Map<String, dynamic> _$ServiceDataToJson(ServiceData instance) =>
    <String, dynamic>{'name': instance.name, 'icon': instance.icon};

MachinesData _$MachinesDataFromJson(Map<String, dynamic> json) => MachinesData(
  washer: (json['washer'] as List<dynamic>?)
      ?.map((e) => MachineData.fromJson(e as Map<String, dynamic>))
      .toList(),
  dryer: (json['dryer'] as List<dynamic>?)
      ?.map((e) => MachineData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MachinesDataToJson(MachinesData instance) =>
    <String, dynamic>{'washer': instance.washer, 'dryer': instance.dryer};

MachineData _$MachineDataFromJson(Map<String, dynamic> json) => MachineData(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  status: json['status'] == null
      ? null
      : ContentLocalizeData.fromJson(json['status'] as Map<String, dynamic>),
  active: json['active'] as bool?,
);

Map<String, dynamic> _$MachineDataToJson(MachineData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'active': instance.active,
    };
