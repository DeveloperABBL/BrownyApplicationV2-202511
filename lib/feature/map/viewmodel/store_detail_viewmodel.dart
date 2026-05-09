import 'dart:async';

import 'package:browny_applications_new/core/data/remote/models/response/store_detail_response.dart';
import 'package:browny_applications_new/core/utils/location_helper.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/map/repository/map_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class StoreDetailViewModel extends AppViewModel {
  StoreDetailViewModel({
    required super.context,
    required this.repo,
    required StoreDataDetail initialStore,
  }) {
    storeNotifier = ValueNotifier(initialStore);
    _resolveCurrentLocation().then((_) => _startRefreshTimer());
  }

  final MapDataSourceMixin repo;

  late final ValueNotifier<StoreDataDetail> storeNotifier;
  StoreDataDetail get store => storeNotifier.value;

  Timer? _refreshTimer;

  /// Cache ตำแหน่งปัจจุบันของผู้ใช้ ใช้ส่งให้ fetchStoreDetail
  /// เพื่อให้ backend คำนวณระยะห่างจากร้านได้ถูกต้อง
  String? _currentLat;
  String? _currentLng;

  Future<void> _resolveCurrentLocation() async {
    try {
      final position = await LocationHelper.getCurrentPosition();
      _currentLat = position.latitude.toString();
      _currentLng = position.longitude.toString();
    } catch (e) {
      debugPrint('StoreDetailViewModel: cannot get current position: $e');
    }
  }

  void pauseRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void resumeRefresh() {
    if (_refreshTimer != null) return;
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final storeId = store.id?.toString() ?? '';
      if (storeId.isEmpty) return;

      final result = await repo.fetchStoreDetail(
        storeId: storeId,
        latitude: _currentLat,
        longitude: _currentLng,
      );

      if (result.isSuccess) {
        storeNotifier.value = result.data;
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    storeNotifier.dispose();
    super.dispose();
  }
}
