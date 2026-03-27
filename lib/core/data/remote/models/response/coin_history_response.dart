import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:browny_applications_new/core/utils/json_converters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'coin_history_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class CoinHistoryResponse extends BaseModelResponse {
  @JsonKey(name: 'data')
  final CoinHistoryData? data;

  CoinHistoryResponse({
    super.success,
    super.errorType,
    super.message,
    this.data,
  });

  factory CoinHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$CoinHistoryResponseFromJson(json);
  Map<String, dynamic> toJson() =>
      baseToJson(_$CoinHistoryResponseToJson(this));
}

@JsonSerializable()
class CoinHistoryData {
  @JsonKey(name: 'browny_coin')
  final String? brownyCoin;

  @JsonKey(name: 'expire_coin')
  final String? expireCoin;

  // @DateTimeConverter()
  @JsonKey(name: 'expire_date')
  final ContentLocalizeData? expireDate;

  @JsonKey(name: 'history')
  final List<CoinHistoryItem>? history;

  CoinHistoryData({
    this.brownyCoin,
    this.expireCoin,
    this.expireDate,
    this.history,
  });

  factory CoinHistoryData.fromJson(Map<String, dynamic> json) =>
      _$CoinHistoryDataFromJson(json);
  Map<String, dynamic> toJson() => _$CoinHistoryDataToJson(this);

  List<CoinHistoryItem> getHistoryReceived() =>
      history.orEmpty.where((e) => e.type.orEmpty == 'received').toList();

  List<CoinHistoryItem> getHistoryUsed() =>
      history.orEmpty.where((e) => e.type.orEmpty == 'used').toList();

  List<CoinHistoryItem> getHistoryExpired() =>
      history.orEmpty.where((e) => e.type.orEmpty == 'expired').toList();

  String getBrownyCoinDisplay() {
    return brownyCoin.ifNullOrEmpty('-');
  }

  String getExpiredDateDisplay(String locale) {
    return expireDate?.getByLocaleCode(locale) ?? '-';
    // if (expireDate == null) return '-';
    // final dateFormat = expireDate!.formatDateLocale(
    //   locale,
    //   pattern: 'dd MMMM yyyy',
    // );
    // switch (locale) {
    //   case 'en':
    //     return 'You have ${expireCoin.ifNullOrEmpty('-')} coins expiring on $dateFormat';
    //   case 'zh':
    //     return '您有${expireCoin.ifNullOrEmpty('-')}枚硬币将在$dateFormat过期';
    //   default:
    //     return 'คุณมี ${expireCoin.ifNullOrEmpty('-')} คอยน์ ที่จะหมดอายุใน $dateFormat';
    // }
  }
}

@JsonSerializable()
class CoinHistoryItem {
  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  @DateTimeConverter()
  @JsonKey(name: 'date')
  final DateTime? date;

  @JsonKey(name: 'amount')
  final String? amount;

  CoinHistoryItem({
    this.type,
    this.name,
    this.date,
    this.amount,
  });

  factory CoinHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$CoinHistoryItemFromJson(json);
  Map<String, dynamic> toJson() => _$CoinHistoryItemToJson(this);

  bool get isExpired => type.orEmpty == 'expired';

  bool get isPlus => type.orEmpty == 'received';

  String getNameDisplay(String locale) {
    if (name == null) return '';
    return name!.getByLocaleCode(locale)!;
  }

  String getAmountDisplay() {
    if (amount == null) return '-';

    if (isPlus) {
      return '+$amount';
    } else {
      return '-$amount';
    }
  }

  String getExpiredDateDisplay(String locale) {
    if (date == null) return '-';
    return date!.formatDateDDMMMMyyyyHHmmMinText(
      locale,
      pattern: 'dd MMM yyyy - HH:mm:ss',
    );
  }

  /// แปลง amount เป็น double
  double get amountValue {
    if (amount == null || amount!.isEmpty) return 0.0;
    return double.tryParse(
          amount.ifNullOrEmpty('0').replaceAll(',', ''),
        ) ??
        0.0;
  }
}

/// Class สำหรับจัดกลุ่มประวัติ Coin ตามเดือน
class CoinHistoryGroup {
  final DateTime groupDate;
  final List<CoinHistoryItem> items;

  CoinHistoryGroup({
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

  /// จำนวนรายการทั้งหมดในกลุ่ม
  int get totalItems => items.length;

  /// ยอดรวม Coin ทั้งหมดในกลุ่ม
  double get totalAmount {
    double sum = 0;
    for (var item in items) {
      sum += item.amountValue;
    }
    return sum;
  }
}

/// Extension สำหรับ List<CoinHistoryItem>
extension CoinHistoryItemListExtension on List<CoinHistoryItem> {
  /// จัดกลุ่มประวัติ Coin ตามเดือน (เรียงจากใหม่ไปเก่า)
  ///
  /// Returns: List<CoinHistoryGroup> เรียงตาม year (desc), month (desc)
  List<CoinHistoryGroup> groupByMonth() {
    if (isEmpty) return [];

    // สร้าง Map เพื่อจัดกลุ่ม key = "yyyy-MM"
    final Map<String, List<CoinHistoryItem>> grouped = {};

    for (var item in this) {
      final date = item.date;
      if (date == null) continue;

      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(item);
    }

    // แปลง Map เป็น List<CoinHistoryGroup> และเรียงลำดับ
    final groups = grouped.entries.map((entry) {
      final parts = entry.key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final groupDate = DateTime(year, month);

      return CoinHistoryGroup(
        groupDate: groupDate,
        items: entry.value,
      );
    }).toList();

    // เรียงจากใหม่ไปเก่า (year desc, month desc)
    groups.sort((a, b) {
      if (a.year != b.year) {
        return b.year.compareTo(a.year);
      }
      return b.month.compareTo(a.month);
    });

    return groups;
  }

  /// เรียงตามวันที่ (ใหม่ไปเก่า)
  List<CoinHistoryItem> sortByDateDesc() {
    final sorted = List<CoinHistoryItem>.from(this);
    sorted.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });
    return sorted;
  }

  /// เรียงตามวันที่ (เก่าไปใหม่)
  List<CoinHistoryItem> sortByDateAsc() {
    final sorted = List<CoinHistoryItem>.from(this);
    sorted.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return a.date!.compareTo(b.date!);
    });
    return sorted;
  }
}
