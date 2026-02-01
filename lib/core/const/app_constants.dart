import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:intl/intl.dart';

/// Local storage key
const String kCustomerData = 'kCustomerData';
const String kCustomerProfile = 'kCustomerProfile';

/// ใช้ในการจัดรูปแบบของข้อความที่เป็นประเภทตัวเลขให้มีรูปแบบเป็นCurrency number
/// Example :
/// ```dart
/// '฿${(formatCurrency.format(standardPrice)).toString()}'
/// ```
String formatCurrency({
  num? value,
  String? string,
  bool decimal = true,
  String? leadingSign,
  String? trailingSign,
}) {
  String mLeadSing = leadingSign.orEmpty;
  String mTrailingSign = trailingSign.orEmpty;
  String formatCurrentcy = decimal ? '#,##0.00' : '#,##0';
  try {
    if (value != null) {
      return '$mLeadSing${NumberFormat(
        formatCurrentcy,
      ).format(value).toString()}$mTrailingSign';
    }
  } catch (ignore) {
    print(ignore);
  }

  try {
    if (string != null) {
      return '$mLeadSing${NumberFormat(
        formatCurrentcy,
      ).format(num.parse(string.replaceAll(',', ''))).toString()}$mTrailingSign';
    }
  } catch (ignore) {
    print(ignore);
  }

  return '$mLeadSing${NumberFormat(
    formatCurrentcy,
  ).format(0.0).toString()}$mTrailingSign';
}

String formatDistance({
  num? value,
  String? string,
  String? leadingSign,
  String? trailingSign,
}) {
  String mLeadSing = leadingSign.orEmpty;
  String mTrailingSign = trailingSign.orEmpty;
  String formatCurrentcy = '#,##0.0';
  try {
    if (value != null) {
      return '$mLeadSing${NumberFormat(
        formatCurrentcy,
      ).format(value).toString()}$mTrailingSign';
    }
  } catch (ignore) {
    print(ignore);
  }

  try {
    if (string != null) {
      return '$mLeadSing${NumberFormat(
        formatCurrentcy,
      ).format(num.parse(string.replaceAll(',', ''))).toString()}$mTrailingSign';
    }
  } catch (ignore) {
    print(ignore);
  }

  return '$mLeadSing${NumberFormat(
    formatCurrentcy,
  ).format(0.0).toString()}$mTrailingSign';
}
