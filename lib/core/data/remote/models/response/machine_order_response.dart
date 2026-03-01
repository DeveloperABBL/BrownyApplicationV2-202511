import 'package:browny_applications_new/core/data/remote/models/response/coupon_order_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'machine_order_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class MachineOrderResponse {
  MachineOrderResponse({
    required this.message,
    this.data,
    this.redirectUrl,
    this.qrAndWechat,
  });

  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'data')
  final MachineOrderData? data;

  @JsonKey(name: 'redirect_url')
  final String? redirectUrl;

  @JsonKey(name: 'qr_and_wechat')
  final String? qrAndWechat;

  /// เช็คว่าสร้างคำสั่งสำเร็จหรือไม่
  bool get isSuccess => data != null;

  factory MachineOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$MachineOrderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MachineOrderResponseToJson(this);
}

@JsonSerializable()
class MachineOrderData {
  MachineOrderData({
    this.customerId,
    this.customerPhone,
    this.storeMachineId,
    this.programCode,
    this.programName,
    this.addTimeValue,
    this.couponCustomerId,
    this.discountId,
    this.couponDiscount,
    this.systemDiscount,
    this.discountAmount,
    this.priceOriginal,
    this.priceFinal,
    this.paymentMethod,
    this.paymentStatus,
    this.paymentRef,
    this.machineStatus,
    this.deviceLogId,
    this.id,
    this.updatedAt,
    this.createdAt,
    this.responsePayload,
  });

  @JsonKey(name: 'customer_id')
  final String? customerId;

  @JsonKey(name: 'customer_phone')
  final String? customerPhone;

  @JsonKey(name: 'store_machine_id')
  final int? storeMachineId;

  @JsonKey(name: 'program_code')
  final String? programCode;

  @JsonKey(name: 'program_name')
  final String? programName;

  @JsonKey(name: 'add_time_value')
  final int? addTimeValue;

  @JsonKey(name: 'coupon_customer_id')
  final int? couponCustomerId;

  @JsonKey(name: 'discount_id')
  final String? discountId;

  @JsonKey(name: 'coupon_discount')
  final String? couponDiscount;

  @JsonKey(name: 'response_payload')
  final ResponsePayload? responsePayload;

  @JsonKey(name: 'system_discount')
  final String? systemDiscount;

  @JsonKey(name: 'discount_amount')
  final String? discountAmount;

  @JsonKey(name: 'price_original')
  final String? priceOriginal;

  @JsonKey(name: 'price_final')
  final String? priceFinal;

  @JsonKey(name: 'payment_method')
  final String? paymentMethod;

  @JsonKey(name: 'payment_status')
  final String? paymentStatus;

  @JsonKey(name: 'payment_ref')
  final String? paymentRef;

  @JsonKey(name: 'machine_status')
  final String? machineStatus;

  @JsonKey(name: 'device_log_id')
  final String? deviceLogId;

  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  /// เช็คว่าสถานะการชำระเงินเป็น pending หรือไม่
  bool get isPaymentPending => paymentStatus?.toLowerCase() == 'pending';

  /// เช็คว่าสถานะการชำระเงินเป็น paid หรือไม่
  bool get isPaymentPaid => paymentStatus?.toLowerCase() == 'paid';

  /// เช็คว่าสถานะเครื่องเป็น pending หรือไม่
  bool get isMachinePending => machineStatus?.toLowerCase() == 'pending';

  factory MachineOrderData.fromJson(Map<String, dynamic> json) =>
      _$MachineOrderDataFromJson(json);

  Map<String, dynamic> toJson() => _$MachineOrderDataToJson(this);
}
