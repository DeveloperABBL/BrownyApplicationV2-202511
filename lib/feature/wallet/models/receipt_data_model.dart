import 'package:browny_applications_new/core/data/remote/models/response/wallet_receipt_response.dart';
import 'package:intl/date_symbol_data_local.dart' as date_symbol;
import 'package:intl/intl.dart';

class ReceiptDataModel extends WalletReceiptData {
  ReceiptDataModel({
    required super.dateTime,
    required super.gateway,
    required super.paymentRef,
    required super.wallet,
    required super.receiptNo,
    required super.transactionId,
    required super.amount,
    required this.locale,
  });

  final String locale;

  factory ReceiptDataModel.empty() => ReceiptDataModel(
    dateTime: null,
    gateway: null,
    paymentRef: null,
    wallet: null,
    receiptNo: null,
    transactionId: null,
    amount: null,
    locale: '',
  );

  factory ReceiptDataModel.fromWalletReceiptData(
    String locale,
    WalletReceiptData data,
  ) {
    return ReceiptDataModel(
      dateTime: data.dateTime,
      gateway: data.gateway,
      paymentRef: data.paymentRef,
      wallet: data.wallet,
      receiptNo: data.receiptNo,
      transactionId: data.transactionId,
      amount: data.amount,
      locale: locale,
    );
  }

  String get confirmedDateTime {
    date_symbol.initializeDateFormatting(locale);
    String pattern;
    DateTime dateTimeData = super.dateTime!;
    switch (locale) {
      case 'en':
      case 'zh':
        pattern = 'dd MMM yy HH:mm';
        break;
      default:
        dateTimeData = dateTimeData.copyWith(year: dateTimeData.year + 543);
        pattern = 'dd MMM yy HH:mm น.';
    }

    return DateFormat(pattern, locale).format(dateTimeData);
  }
}
