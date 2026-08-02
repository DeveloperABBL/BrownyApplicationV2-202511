import 'dart:convert';

import 'package:browny_applications_new/core/data/remote/models/api_model_index.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

const walletHistory =
    '{"history": [{"type": "top_up","dateTime": "26-07-2026 / 00:00","amount": "150.00","description": "เติมเงิน","receipt_no": "RCT202616511"}]}';
void main() {
  test('Wallet History model', () {
    final walletHisory = WalletHistoryResponse.fromJson(
      jsonDecode(walletHistory),
    );
    final dateShowTh = walletHisory.history!.first.dateTime!
        .formatDateDDMMMMyyyyHHmmMinText(
          'th',
          pattern: 'dd MMM yyyy - HH:mm:ss',
        );
    print(dateShowTh);
    final dateShowEn = walletHisory.history!.first.dateTime!
        .formatDateDDMMMMyyyyHHmmMinText(
          'en',
          pattern: 'dd MMM yyyy - HH:mm:ss',
        );
    print(dateShowEn);
  });
}
