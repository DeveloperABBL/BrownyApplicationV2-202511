import 'package:browny_applications_new/core/data/remote/models/response/coin_claimed_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coin_history_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
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
    _coinHistoryNotifier.dispose();
    _coinHistoryGroupsNotifier.dispose();
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
  // ข้อมูลประวัติ Browny Coin
  late final ValueNotifier<UiResult<CoinHistoryResponse>> _coinHistoryNotifier =
      ValueNotifier(
        UiResult.loading(),
      );
  ValueListenable<UiResult<CoinHistoryResponse>> get coinHistoryNotifier =>
      _coinHistoryNotifier;

  // ข้อมูลประวัติ Browny Coin ที่ถูกจัดกลุ่มตามเดือน
  late final ValueNotifier<UiResult<List<CoinHistoryGroup>>>
  _coinHistoryGroupsNotifier = ValueNotifier(
    UiResult.loading(),
  );
  ValueListenable<UiResult<List<CoinHistoryGroup>>>
  get coinHistoryGroupsNotifier => _coinHistoryGroupsNotifier;

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

  Future<void> fetchCoinHistory() async {
    _coinHistoryNotifier.value = UiResult.loading();
    _coinHistoryGroupsNotifier.value = UiResult.loading();

    String id = currentCustomerProvider.current.id!;
    final result = await _repo.fetchCoinHistory(id);

    if (result.isEmpty) {
      _coinHistoryNotifier.value = UiResult.empty();
      _coinHistoryGroupsNotifier.value = UiResult.empty();
      return;
    }

    if (result.hasError) {
      _coinHistoryNotifier.value = UiResult.error(error: result.error);
      _coinHistoryGroupsNotifier.value = UiResult.error(error: result.error);
      return;
    }

    _coinHistoryNotifier.value = UiResult.success(data: result.data);

    // จัดกลุ่มประวัติตามเดือน
    final history = result.data.data?.history ?? [];
    final groups = history.groupByMonth();
    _coinHistoryGroupsNotifier.value = UiResult.success(data: groups);
  }

  String descriptionPopupCondition(BuildContext context) {
    switch (context.languageCode) {
      case 'en':
        return '''
Terms and Conditions
• For every XX THB spent on washing and drying, receive 1 Browny Coin
• Every 10 Browny Coins have a value of 1 THB
• You have XXX coins that will expire in October X, 202X
''';
      case 'zh':
        return '''
条款和条件
• 每消费XX泰铢洗烘服务，可获得1个Browny Coin
• 每10个Browny Coin价值1泰铢
• 您有XXX个硬币将于202X年10月X日到期
''';
      default:
        return '''
เงื่อนไข
• ทุกๆ XX บาท ในการซักอบ ได้รับ 1 Browny Coin
• ทุกๆ 10 Browny Coin มีมูลค่า 1 บาท
• คุณมี XXX เหรียญ ที่จะหมดอายุใน X ตุลาคม 202X
''';
    }
  }
}
