import 'dart:async';
import 'package:browny_applications_new/core/const/app_constants.dart';
import 'package:browny_applications_new/core/data/remote/models/request/topup_request.dart';
import 'package:browny_applications_new/core/data/remote/models/response/topup_request_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/wallet_receipt_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/wallet/error/wallet_exception.dart';
import 'package:browny_applications_new/feature/wallet/models/receipt_data_model.dart';
import 'package:browny_applications_new/feature/wallet/models/wallet_model.dart';
import 'package:browny_applications_new/feature/wallet/repository/wallet_repo.dart';
import 'package:browny_applications_new/res/strings/app_strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum WalletProcessState {
  // สำหรับเติมเงิน
  topup,
  // สำหรับ Scan เปิดกล้อง
  scan,
  // สำหรับประวัติ
  history,
}

class WalletViewModel extends AppViewModelObscureHandler {
  WalletViewModel({
    required super.context,
    super.initIsObscure = false,
    WalletDataSourceMixin? walletRepo,
  }) {
    repo = walletRepo ?? WalletRepo();
  }

  // ========= repo =========
  late WalletDataSourceMixin repo;

  // ========= dispose =========
  Timer? _statusCheckTimer;

  @override
  void dispose() {
    _procesStateNotfier.dispose();
    _recieptDataNotifier.dispose();
    _walletDataNotifier.dispose();
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  // ========= valueNotifier, controller =========
  final ValueNotifier<WalletProcessState> _procesStateNotfier = ValueNotifier(
    WalletProcessState.topup,
  );
  ValueListenable<WalletProcessState> get procesStateNotfier =>
      _procesStateNotfier;

  /// เก็บ Response จากที่ ChechStatus
  /// จะถูก Assign จาก [startPaymentStatusCheck] เท่านั่น
  late final ValueNotifier<UiResult<ReceiptDataModel>> _recieptDataNotifier =
      ValueNotifier(UiResult.loading());
  ValueListenable<UiResult<ReceiptDataModel>> get recieptDataNotifier =>
      _recieptDataNotifier;

  final ValueNotifier<UiResult<WalletModel>> _walletDataNotifier =
      ValueNotifier(
        UiResult.loading(),
      );
  ValueListenable<UiResult<WalletModel>> get walletNotifier =>
      _walletDataNotifier;

  TextEditingController amountController = TextEditingController();

  // ========= Logic =========

  bool _amountValidNotifier = false;
  // เก็บ Response จากที่ Request ชำระ
  TopupRequestResponse? _topupResponse;
  TopupRequestResponse? get topupResponse => _topupResponse;

  Future<UiResult<TopupRequestResponse>> onSummitClick() async {
    if (_amountValidNotifier) {
      final result = await repo.requestTopup(
        TopupRequest(
          customerId: currentCustomerProvider.current.id!,
          amount: int.parse(amountController.text.commaReplacer()),
          gateway: 'promptpay',
        ),
      );

      if (result.hasData) {
        _topupResponse = result.data;
        return UiResult.success(data: result.data);
      }

      return UiResult.error(error: result.error);
    }

    return UiResult.empty();
  }

  void selectAmount(int amount) {
    final currentData = _walletDataNotifier.value.data;
    if (currentData == null) return;

    amountController.text = amount.toString();

    int newSelectedIndex = currentData.amountBadge.indexOf(amount);
    if (newSelectedIndex >= 0) {
      _walletDataNotifier.value = UiResult.success(
        data: currentData.copyWith(
          selectedAmount: currentData.amountBadge.indexOf(amount),
        ),
      );

      return;
    }

    if (newSelectedIndex == -1 && currentData.selectedAmount > -1) {
      _walletDataNotifier.value = UiResult.success(
        data: currentData.copyWith(
          selectedAmount: -1,
        ),
      );
      return;
    }
  }

  void onTextAmountChange(String value) {
    selectAmount(
      double.parse(
        value.orEmpty.ifEmpty('0').commaReplacer(),
      ).toInt(),
    );
  }

  String? amountValidator(String? value) {
    int inputAmount = double.parse(
      value.orEmpty.ifEmpty('0').commaReplacer(),
    ).toInt();
    String? ret;
    // if (inputAmount < 100) {
    //   ret = context.wording.minimumTopUpValidation;
    // }

    if (inputAmount > 2000) {
      ret = context.wording.maximumTopUpValidation;
    }

    amountController.text = inputAmount == 0
        ? ''
        : formatCurrency(value: inputAmount, decimal: false);

    _amountValidNotifier = (ret == null);
    ret = inputAmount == 0 ? null : ret;
    return ret;
  }

  /// เริ่มตรวจสอบสถานะการชำระเงินทุก 30 วินาที
  void startPaymentStatusCheck(VoidCallback onSuccess) {
    final paymentRef = topupResponse!.paymentRef!;
    _statusCheckTimer?.cancel();

    // Start status check timer
    _statusCheckTimer = Timer.periodic(
      const Duration(seconds: 7),
      (timer) async {
        // ======= mock =======
        // stopPaymentStatusCheck();
        // onSuccess.call();
        // return;

        // ======= real =======
        final result = await repo.checkWalletStatusPayment(paymentRef);

        if (result.hasData) {
          final data = result.data;
          if (data.confirmedAt != null) {
            // Payment confirmed - stop timers
            stopPaymentStatusCheck();

            // Refresh credit balance
            await fetchCredit();
            onSuccess.call();
          }
        }
      },
    );
  }

  /// หยุดการตรวจสอบสถานะการชำระเงิน
  void stopPaymentStatusCheck() {
    _statusCheckTimer?.cancel();
  }

  Future<void> fetchCredit() async {
    final oldWalletData = _walletDataNotifier.value.data;

    final result = await repo.fetchCustomerCredit(
      currentCustomerProvider.current.id!,
    );

    if (result.isEmpty || result.hasError) {
      _walletDataNotifier.value = UiResult.empty();
      return;
    }
    final amountBadgeRestul = await repo.fetchAmountBadge();

    _walletDataNotifier.value = UiResult.success(
      data:
          WalletModel.fromCustomerProfileData(
            result.data,
          ).copyWith(
            amountBadge: amountBadgeRestul.data,
            selectedAmount: amountBadgeRestul.data.indexOf(
              oldWalletData?.selectedAmount ?? 0,
            ),
          ),
    );
  }

  Future<void> fetchReceiptData(BuildContext context) async {
    // ======= mock =======
    // final locale = Localizations.localeOf(context);
    // _recieptDataNotifier.value = UiResult.success(
    //   data: ReceiptDataModel.fromWalletReceiptData(
    //     locale.languageCode.orEmpty.ifEmpty('th'),
    //     WalletReceiptData(
    //       amount: '100',
    //       dateTime: DateTime.now(),
    //       paymentRef: topupResponse?.paymentRef,
    //       gateway: 'promptpay',
    //       receiptNo: 'RCPT202506101430',
    //       transactionId: 'TXN123456789',
    //     ),
    //   ),
    // );
    // return;

    // ======= real =======
    if (!_recieptDataNotifier.value.isLoading) {
      _recieptDataNotifier.value = UiResult.loading();
    }

    final paymentRef = topupResponse!.paymentRef!;
    final result = await repo.fetchReciept(paymentRef);

    if (result.hasError) {
      _recieptDataNotifier.value = UiResult.error(error: Unprocessable());
      return;
    }

    if (result.isSuccess && context.mounted) {
      final locale = Localizations.localeOf(context);
      _recieptDataNotifier.value = UiResult.success(
        data: ReceiptDataModel.fromWalletReceiptData(
          locale.countryCode.orEmpty.ifEmpty('th'),
          result.data.data!,
        ),
      );
    }
  }

  void clearValue() {
    onTextAmountChange('');
  }

  void onProcessStateChange(WalletProcessState toState) {
    final currentState = _procesStateNotfier.value;
    if (currentState == toState) return;

    _procesStateNotfier.value = toState;
  }
}
