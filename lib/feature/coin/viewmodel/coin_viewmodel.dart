import 'package:browny_applications_new/core/data/remote/models/response/coin_claimed_response.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/coin/models/coin_data_model.dart';
import 'package:browny_applications_new/feature/coin/repository/coin_claim_repo.dart';
import 'package:browny_applications_new/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CoinViewmModel extends AppViewModel {
  CoinViewmModel({
    required super.context,
    required CoinDataSourceMixin repo,
  }) : _repo = repo;

  final CoinDataSourceMixin _repo;

  // ========== dispose ==========
  @override
  void dispose() {
    _toDayDataNotifier.dispose();
    _coinClaimDataNotifier.dispose();
    super.dispose();
  }

  // ========== ValueNotifier, Controller ==========
  // ข้อมูลวันที่ที่จะแสดง
  final ValueNotifier<UiResult<String>> _toDayDataNotifier = ValueNotifier(
    UiResult.empty(),
  );
  ValueListenable<UiResult<String>> get toDayDataNotifier => _toDayDataNotifier;
  // ข้อมูล coin สำหรับ claim ทั้งหมด
  final ValueNotifier<UiResult<CoinDataModel>> _coinClaimDataNotifier =
      ValueNotifier(
        UiResult.loading(),
      );
  ValueListenable<UiResult<CoinDataModel>> get coinClaimDataNotifier =>
      _coinClaimDataNotifier;

  // ========== Logic ==========
  Future<UiResult<CoinClaimedResponse>> coinClaiming() async {
    String id = currentCustomerProvider.current.id!;
    final result = await _repo.coinClaiming(id);
    if (result.isError) {
      return UiResult.error(error: result.error);
    }

    await fetchCoinCliamData();
    return UiResult.success(data: result.data);
  }

  Future<void> fetchCoinCliamData() async {
    String id = currentCustomerProvider.current.id!;
    final profileResult = await _repo.fetchProfileInfo(id);

    if (profileResult.isError || profileResult.isEmpty) {
      // Error จะ claim ไม่ได้
      _coinClaimDataNotifier.value = UiResult.error(
        error: Exception(profileResult.error.toString()),
      );
      return;
    }

    final result = await _repo.fetchCoinClaimData(id);

    if (result.isEmpty) {
      _coinClaimDataNotifier.value = UiResult.empty();
      return;
    }
    if (result.hasError) {
      _coinClaimDataNotifier.value = UiResult.error(error: result.error);
      return;
    }

    final profileDataLocal = await _repo.customerProfileData();
    // update ข้อมูล profile ทั้งหมด
    currentCustomerProvider.newUser = UserModel.fromCustomerProfileData(
      profileResult.data.copyWith(
        creditBalance: profileDataLocal.data.creditBalance,
        brownyCoin: profileDataLocal.data.brownyCoin,
      ),
    );

    // render ข้อมูล claim
    if (context.mounted) {
      final data = CoinDataModel.fromCoinClaimData(
        Localizations.localeOf(context).languageCode,
        result.data.data!,
      );

      _toDayDataNotifier.value = UiResult.success(
        data: data.streaksDisplay.firstWhere((e) => e.isToday).day,
      );

      _coinClaimDataNotifier.value = UiResult.success(
        data: data,
      );
    }
  }
}
