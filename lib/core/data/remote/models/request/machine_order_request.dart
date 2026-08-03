import 'package:json_annotation/json_annotation.dart';

part 'machine_order_request.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class MachineOrderRequest {
  MachineOrderRequest({
    this.customerId,
    required this.customerPhone,
    required this.storeMachineId,
    required this.programCode,
    this.addTimeValue,
    required this.paymentMethod,
    this.couponCustomerId,
    this.discountId,
    this.notificationToken,
    this.useCoin,
  });

  @JsonKey(name: 'customer_id')
  final String? customerId;

  @JsonKey(name: 'customer_phone')
  final String customerPhone;

  @JsonKey(name: 'store_machine_id')
  final int storeMachineId;

  @JsonKey(name: 'program_code')
  final String programCode;

  @JsonKey(name: 'add_time_value')
  final int? addTimeValue;

  @JsonKey(name: 'payment_method')
  final String paymentMethod;

  @JsonKey(name: 'coupon_customer_id')
  final int? couponCustomerId;

  @JsonKey(name: 'discount_id')
  final String? discountId;

  @JsonKey(name: 'notification_token')
  final String? notificationToken;

  /// ใช้ Browny Coin เป็นส่วนลด (10 coins = 1 บาท)
  @JsonKey(name: 'use_coin', includeIfNull: false)
  final bool? useCoin;

  factory MachineOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$MachineOrderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MachineOrderRequestToJson(this);
}
