import 'package:intl/intl.dart';

/// Local storage key
const String kCustomerData = 'kCustomerData';
const String kCustomerProfile = 'kCustomerProfile';

/// ใช้ในการจัดรูปแบบของข้อความที่เป็นประเภทตัวเลขให้มีรูปแบบเป็นCurrency number
/// Example :
/// ```dart
/// '฿${(formatCurrency.format(standardPrice)).toString()}'
/// ```
String formatCurrency({num? value, String? string}) {
  try {
    if (value != null) {
      return NumberFormat('#,##0.00').format(value).toString();
    }
  } catch (ignore) {}

  try {
    if (string != null) {
      return NumberFormat(
        '#,##0.00',
      ).format(string.replaceAll(',', '')).toString();
    }
  } catch (ignore) {}

  return NumberFormat('#,##0.00').format(0.0).toString();
}
