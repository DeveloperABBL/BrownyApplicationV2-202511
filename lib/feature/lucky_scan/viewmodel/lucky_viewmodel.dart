import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/festive_index_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/lucky_draw_response.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/lucky_scan/repository/lucky_repo.dart';
import 'package:flutter/foundation.dart';

class LuckyViewmodel extends AppViewModel {
  LuckyViewmodel({
    required super.context,
    required this.repo,
  });

  final LuckyDataSourceMixin repo;

  // ========== Dispose ==========
  @override
  void dispose() {
    _festiveIndexNotifier.dispose();
    _selectedFestiveNotifier.dispose();
    super.dispose();
  }

  // ========== ValueNotifier ==========
  final ValueNotifier<UiResult<FestiveIndexResponse>> _festiveIndexNotifier =
      ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<FestiveIndexResponse>> get festiveIndexNotifier =>
      _festiveIndexNotifier;

  final ValueNotifier<FestiveData?> _selectedFestiveNotifier = ValueNotifier(
    null,
  );
  ValueListenable<FestiveData?> get selectedFestiveNotifier =>
      _selectedFestiveNotifier;

  // ========== Logic ==========
  /// API fetch รายการ Festive Event (Lucky Scan campaigns)
  Future<void> fetchFestiveIndex() async {
    _festiveIndexNotifier.value = UiResult.loading();

    final result = await repo.fetchFestiveIndex();

    if (result.hasError) {
      _festiveIndexNotifier.value = UiResult.error(error: result.error);
      return;
    }

    if (result.isEmpty) {
      _festiveIndexNotifier.value = UiResult.empty();
      return;
    }

    final response = result.data;

    // แสดง data.first เสมอ เมื่อได้ข้อมูล
    final firstItem = (response.data?.isNotEmpty ?? false)
        ? response.data!.first
        : null;
    _selectedFestiveNotifier.value = firstItem;

    _festiveIndexNotifier.value = UiResult.success(data: response);
  }

  /// เลือก campaign ที่จะแสดงใน Blue zone / Conditions tab
  void selectFestive(FestiveData item) {
    _selectedFestiveNotifier.value = item;
  }

  /// API สแกน QR Lucky Draw — return UiResult โดยตรง (ไม่ใช้ notifier)
  Future<UiResult<LuckyDrawResponse>> postLuckyDraw({
    required String qrCode,
  }) async {
    final result = await repo.postLuckyDraw(
      customerId: currentCustomerProvider.current.id.orEmpty,
      qrCode: qrCode,
    );

    if (result.hasError) {
      return UiResult.error(error: result.error);
    }

    if (result.isEmpty) {
      return UiResult.empty();
    }

    return UiResult.success(data: result.data);
  }
}
