import 'dart:collection';

import 'package:browny_applications_new/core/data/remote/models/response/map_location_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/map/repository/map_repo.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapViewModel extends AppViewModel {
  MapViewModel({
    required super.context,
    required this.repo,
  });

  // ========== Repository ==========
  final MapDataSourceMixin repo;

  // ========== Notifier, Controller ==========
  final List<StoreLocationItem> _storeList = [];
  List<StoreLocationItem> get storeList => _storeList;

  TextEditingController textSerchController = TextEditingController();

  // ========== Logic, Function ==========
  final Map<String, StoreLocationItem?> _servicesAvailable = {
    for (var element in StoreLocationItem.servicesType) element: null,
  };
  Map<String, StoreLocationItem?> get servicesAvialble => _servicesAvailable;

  Future<UiResult<List<StoreLocationItem>>> fetchStoreLocation({
    LatLng? currentPosition,
  }) async {
    final result = await repo.fetchMapLocations(
      currentPosition: currentPosition,
    );

    if (result.isEmpty || result.hasError) {
      return UiResult.empty();
    }
    _storeList.addAll(result.data);

    // Distinct Service Type ที่ API ส่งลงมาเป็นเก็บไว้
    final setServices = _storeList.map((e) => e.type).toSet();
    // Sort เอาที่ Distance ใกล้ที่สุดขึ้นบน
    _storeList.sort(
      // น้อยไปมาก
      (left, right) => left.distance?.compareTo(right.distance ?? 0) ?? 1,
    );

    // loop หา service ที่ Available เป็น key และ Service nearest เป็น Value
    for (final service in setServices) {
      _servicesAvailable[service.orEmpty] = _storeList.firstWhere(
        (e) => e.type == service,
      );
    }

    return UiResult.success(data: _storeList);
  }
}
