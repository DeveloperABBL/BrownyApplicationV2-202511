import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/json_converters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wallet_history_response.g.dart';

@JsonSerializable()
class WalletHistoryResponse {
  final List<WalletHistoryItem>? history;

  WalletHistoryResponse({
    this.history,
  });

  factory WalletHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$WalletHistoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WalletHistoryResponseToJson(this);
}

@JsonSerializable()
class WalletHistoryItem {
  /// ประเภทธุรกรรม (e.g., "purchase", "topup", "refund")
  @JsonKey(name: 'type')
  final String? type;

  /// วันเวลาที่ทำธุรกรรม (format: "dd-MM-yyyy / HH:mm")
  @DateTimeStartWithDayConverter()
  @JsonKey(name: 'dateTime')
  final DateTime? dateTime;

  /// จำนวนเงิน (format: "200.00")
  @JsonKey(name: 'amount')
  final String? amount;

  /// คำอธิบายธุรกรรม
  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'receipt_no')
  final String? receiptNo;

  WalletHistoryItem({
    this.type,
    this.dateTime,
    this.amount,
    this.description,
    this.receiptNo,
  });

  factory WalletHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$WalletHistoryItemFromJson(json);

  Map<String, dynamic> toJson() => _$WalletHistoryItemToJson(this);

  /// แปลง amount เป็น double
  double get amountValue {
    if (amount == null || amount!.isEmpty) return 0.0;
    return double.tryParse(
          amount.ifNullOrEmpty('0').replaceAll(',', ''),
        )?.abs() ??
        0.0;
  }

  String get getAmountDisplay {
    return amount.ifNullOrEmpty('0.0');
  }

  /// Format amount สำหรับแสดงผล (e.g., "200.00 ฿")
  String getFormattedAmount({String currency = '฿'}) {
    if (amount == null) return '-';
    return '$amount $currency';
  }

  /// Format dateTime ตาม locale
  ///
  /// ตัวอย่าง:
  /// - Thai: "15 ก.พ. 2026 - 12:38:00 น."
  /// - English: "15 Feb 2026 - 12:38:00"
  /// - Chinese: "15 Feb 2026 - 12:38:00"
  String formatDateTime(String locale) {
    if (dateTime == null) return '-';
    return dateTime!.formatDateDDMMMMyyyyHHmmMinText(
      locale,
      pattern: 'dd MMM yyyy - HH:mm:ss',
    );
  }

  String getDescriptionDisplay(String locale) {
    if (type.orEmpty == 'purchase') {
      switch (locale) {
        case 'en':
          return 'โอนเงิน/ชำระเงิน';
        case 'zh':
          return 'โอนเงิน/ชำระเงิน';
        default:
          return 'โอนเงิน/ชำระเงิน';
      }
    } else if (type.orEmpty == 'refund') {
      switch (locale) {
        case 'en':
          return 'คืนเงิน';
        case 'zh':
          return 'คืนเงิน';
        default:
          return 'คืนเงิน';
      }
    } else if (type.orEmpty == 'top_up') {
      switch (locale) {
        case 'en':
          return 'เติมเงิน';
        case 'zh':
          return 'เติมเงิน';
        default:
          return 'เติมเงิน';
      }
    } else {
      return description.orEmpty;
    }
  }

  /// เช็คว่าเป็นธุรกรรมเติมเงินหรือไม่
  bool get isTopup => type?.toLowerCase() == 'top_up';

  /// เช็คว่าเป็นธุรกรรมซื้อหรือไม่
  bool get isPurchase => type?.toLowerCase() == 'purchase';

  /// เช็คว่าเป็นธุรกรรมคืนเงินหรือไม่
  bool get isRefund => type?.toLowerCase() == 'refund';
}

/// Class สำหรับจัดกลุ่มประวัติธุรกรรมตามเดือน
class WalletHistoryGroup {
  final DateTime groupDate;
  final List<WalletHistoryItem> items;

  WalletHistoryGroup({
    required this.groupDate,
    required this.items,
  });

  /// Month number (1-12)
  int get month => groupDate.month;

  /// Year
  int get year => groupDate.year;

  /// Format: "02 2026"
  String get monthYearText => '${month.toString().padLeft(2, '0')} $year';

  /// Format groupDate ตาม locale
  ///
  /// - Thai: "กุมภาพันธ์ 2026"
  /// - English: "February 2026"
  /// - Chinese: "February 2026"
  String formatGroupDate(String locale) {
    return groupDate.formatDateLocale(
      locale,
      pattern: 'MMMM yyyy',
    );
  }

  /// Format: "กุมภาพันธ์ 2026" (Thai locale)
  String get monthYearThaiText => formatGroupDate('th');

  /// Format: "February 2026" (English locale)
  String get monthYearEnglishText => formatGroupDate('en');

  /// Format: "Feb 2026" (Short English)
  String get monthYearShortText {
    return groupDate.formatDateLocale(
      'en',
      pattern: 'MMM yyyy',
    );
  }

  /// จำนวนรายการทั้งหมดในกลุ่ม
  int get totalItems => items.length;

  /// ยอดรวมของธุรกรรมทั้งหมดในกลุ่ม
  double get totalAmount {
    double sum = 0;
    for (var item in items) {
      sum += item.amountValue;
    }
    return sum;
  }

  /// จำนวนธุรกรรมเติมเงิน
  int get topupCount => items.where((item) => item.isTopup).length;

  /// จำนวนธุรกรรมซื้อ
  int get purchaseCount => items.where((item) => item.isPurchase).length;

  /// จำนวนธุรกรรมคืนเงิน
  int get refundCount => items.where((item) => item.isRefund).length;
}

/// Extension สำหรับ WalletHistoryResponse
extension WalletHistoryResponseExtension on WalletHistoryResponse {
  /// จัดกลุ่มประวัติธุรกรรมตามเดือน (เรียงจากใหม่ไปเก่า)
  ///
  /// Returns: List<WalletHistoryGroup> เรียงตาม year (desc), month (desc)
  ///
  /// ตัวอย่าง:
  /// ```dart
  /// final groups = response.groupByMonth();
  /// for (var group in groups) {
  ///   print('${group.monthYearThaiText}: ${group.totalItems} รายการ');
  ///   for (var item in group.items) {
  ///     print('  - ${item.description}: ${item.getFormattedAmount()}');
  ///   }
  /// }
  /// ```
  List<WalletHistoryGroup> groupByMonth() {
    if (history == null || history!.isEmpty) return [];

    // สร้าง Map เพื่อจัดกลุ่ม key = "yyyy-MM"
    final Map<String, List<WalletHistoryItem>> grouped = {};

    for (var item in history!) {
      final dateTime = item.dateTime;
      if (dateTime == null) continue;

      final key =
          '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}';

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(item);
    }

    // แปลง Map เป็น List<WalletHistoryGroup>
    final List<WalletHistoryGroup> groups = [];
    grouped.forEach((key, items) {
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      groups.add(
        WalletHistoryGroup(
          groupDate: DateTime(year, month),
          items: items,
        ),
      );
    });

    // เรียงจากใหม่ไปเก่า (year desc, month desc)
    groups.sort((a, b) => b.groupDate.compareTo(a.groupDate));

    return groups;
  }

  /// จำนวนกลุ่มทั้งหมด
  int get totalGroups => groupByMonth().length;

  /// ยอดรวมธุรกรรมทั้งหมด
  double get totalAmount {
    double sum = 0;
    for (var item in history ?? []) {
      sum += item.amountValue ?? 0;
    }
    return sum;
  }

  /// จำนวนรายการทั้งหมด
  int get totalItems => history?.length ?? 0;
}

/// Extension สำหรับ List<WalletHistoryItem>
extension WalletHistoryItemListExtension on List<WalletHistoryItem> {
  /// เรียงตามวันที่ (ใหม่ไปเก่า)
  List<WalletHistoryItem> sortByDateDesc() {
    final sorted = List<WalletHistoryItem>.from(this);
    sorted.sort((a, b) {
      final dateA = a.dateTime;
      final dateB = b.dateTime;
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA);
    });
    return sorted;
  }

  /// เรียงตามวันที่ (เก่าไปใหม่)
  List<WalletHistoryItem> sortByDateAsc() {
    final sorted = List<WalletHistoryItem>.from(this);
    sorted.sort((a, b) {
      final dateA = a.dateTime;
      final dateB = b.dateTime;
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateA.compareTo(dateB);
    });
    return sorted;
  }

  /// Filter เฉพาะธุรกรรมเติมเงิน
  List<WalletHistoryItem> get topupOnly =>
      where((item) => item.isTopup).toList();

  /// Filter เฉพาะธุรกรรมซื้อ
  List<WalletHistoryItem> get purchaseOnly =>
      where((item) => item.isPurchase).toList();

  /// Filter เฉพาะธุรกรรมคืนเงิน
  List<WalletHistoryItem> get refundOnly =>
      where((item) => item.isRefund).toList();

  /// ยอดรวมทั้งหมด
  double get totalAmount {
    double sum = 0;
    for (var item in this) {
      sum += item.amountValue;
    }
    return sum;
  }
}
