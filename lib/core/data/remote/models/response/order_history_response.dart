import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_history_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class OrderHistoryResponse {
  OrderHistoryResponse({
    this.data,
    this.meta,
  });

  @JsonKey(name: 'data')
  final List<OrderHistoryItem>? data;

  @JsonKey(name: 'meta')
  final OrderHistoryMeta? meta;

  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderHistoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OrderHistoryResponseToJson(this);
}

@JsonSerializable()
class OrderHistoryMeta {
  OrderHistoryMeta({
    this.currentPage,
    this.perPage,
    this.total,
    this.lastPage,
  });

  @JsonKey(name: 'current_page')
  final int? currentPage;

  @JsonKey(name: 'per_page')
  final int? perPage;

  @JsonKey(name: 'total')
  final int? total;

  @JsonKey(name: 'last_page')
  final int? lastPage;

  /// เช็คว่ามีหน้าถัดไปหรือไม่
  bool get hasNextPage =>
      currentPage != null && lastPage != null && currentPage! < lastPage!;

  factory OrderHistoryMeta.fromJson(Map<String, dynamic> json) =>
      _$OrderHistoryMetaFromJson(json);

  Map<String, dynamic> toJson() => _$OrderHistoryMetaToJson(this);
}

@JsonSerializable()
class OrderHistoryItem {
  OrderHistoryItem({
    this.type,
    this.orderId,
    this.receiptNo,
    this.receiptAt,
    this.store,
    this.machineNo,
    this.machineType,
    this.image,
    this.luckNo,
    this.program,
    this.paymentMethod,
    this.amount,
    this.packageName,
  });

  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'order_id')
  final String? orderId;

  @JsonKey(name: 'receipt_no')
  final String? receiptNo;

  @JsonKey(name: 'receipt_at')
  final String? receiptAt;

  @JsonKey(name: 'store')
  final OrderHistoryStore? store;

  @JsonKey(name: 'machine_no')
  final int? machineNo;

  @JsonKey(name: 'image')
  final String? image;

  @JsonKey(name: 'machine_type')
  final ContentLocalizeData? machineType;

  @JsonKey(name: 'luck_no')
  final String? luckNo;

  @JsonKey(name: 'program')
  final OrderHistoryProgram? program;

  @JsonKey(name: 'payment_method')
  final OrderHistoryPaymentMethod? paymentMethod;

  @JsonKey(name: 'amount')
  final String? amount;

  /// สำหรับ type = coupon_package_order เท่านั้น
  @JsonKey(name: 'package_name')
  final ContentLocalizeData? packageName;

  /// เช็คว่าเป็น order ประเภทการใช้เครื่อง
  bool get isMachineOrder => type == 'machine_order';

  /// เช็คว่าเป็น order ประเภทซื้อแพ็กเกจคูปอง
  bool get isCouponPackageOrder => type == 'coupon_package_order';

  /// ดึงชื่อแพ็กเกจตาม locale (สำหรับ coupon_package_order)
  String getPackageNameDisplay(String locale) {
    return packageName?.getByLocaleCode(locale) ?? '';
  }

  /// ดึงเครื่องตาม locale (สำหรับ machine_order)
  String getMachineTypeDisplay(String locale) {
    return machineType?.getByLocaleCode(locale) ?? '';
  }

  /// แปลง receiptAt (String) ไปเป็น DateTime
  DateTime? get receiptAtDateTime {
    if (receiptAt == null) return null;
    try {
      return DateTime.parse(receiptAt!);
    } catch (_) {}
    try {
      return DateTime(
        int.parse(receiptAt!.substring(0, 4)),
        int.parse(receiptAt!.substring(5, 7)),
        int.parse(receiptAt!.substring(8, 10)),
        receiptAt!.length >= 16 ? int.parse(receiptAt!.substring(11, 13)) : 0,
        receiptAt!.length >= 16 ? int.parse(receiptAt!.substring(14, 16)) : 0,
      );
    } catch (_) {}
    return null;
  }

  /// แสดงวันที่และเวลา receipt ตาม locale
  String receiptAtDisplay(String locale) {
    final dt = receiptAtDateTime;
    if (dt == null) return receiptAt ?? '';
    return dt.formatDateDDMMMMyyyyHHmmMinText(
      pattern: 'dd MMM yyyy HH:mm',
      locale,
    );
  }

  factory OrderHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$OrderHistoryItemFromJson(json);

  Map<String, dynamic> toJson() => _$OrderHistoryItemToJson(this);
}

@JsonSerializable()
class OrderHistoryStore {
  OrderHistoryStore({
    this.id,
    this.name,
  });

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  /// ดึงชื่อร้านตาม locale
  String getNameDisplay(String locale) {
    return name?.getByLocaleCode(locale) ?? '';
  }

  factory OrderHistoryStore.fromJson(Map<String, dynamic> json) =>
      _$OrderHistoryStoreFromJson(json);

  Map<String, dynamic> toJson() => _$OrderHistoryStoreToJson(this);
}

@JsonSerializable()
class OrderHistoryProgram {
  OrderHistoryProgram({
    this.code,
    this.name,
  });

  @JsonKey(name: 'code')
  final String? code;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  /// ดึงชื่อโปรแกรมตาม locale
  String getNameDisplay(String locale) {
    return name?.getByLocaleCode(locale) ?? '';
  }

  factory OrderHistoryProgram.fromJson(Map<String, dynamic> json) =>
      _$OrderHistoryProgramFromJson(json);

  Map<String, dynamic> toJson() => _$OrderHistoryProgramToJson(this);
}

@JsonSerializable()
class OrderHistoryPaymentMethod {
  OrderHistoryPaymentMethod({
    this.key,
    this.name,
    this.image,
  });

  @JsonKey(name: 'key')
  final String? key;

  @JsonKey(name: 'name')
  final ContentLocalizeData? name;

  @JsonKey(name: 'image')
  final String? image;

  /// ดึงชื่อช่องทางชำระเงินตาม locale
  String getNameDisplay(String locale) {
    return name?.getByLocaleCode(locale) ?? '';
  }

  factory OrderHistoryPaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$OrderHistoryPaymentMethodFromJson(json);

  Map<String, dynamic> toJson() => _$OrderHistoryPaymentMethodToJson(this);
}
