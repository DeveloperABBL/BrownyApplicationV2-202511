// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'machine_order_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MachineOrderRequest _$MachineOrderRequestFromJson(Map<String, dynamic> json) =>
    MachineOrderRequest(
      customerId: json['customer_id'] as String?,
      customerPhone: json['customer_phone'] as String,
      storeMachineId: (json['store_machine_id'] as num).toInt(),
      programCode: json['program_code'] as String,
      addTimeValue: (json['add_time_value'] as num?)?.toInt(),
      paymentMethod: json['payment_method'] as String,
      couponCustomerId: (json['coupon_customer_id'] as num?)?.toInt(),
      discountId: json['discount_id'] as String?,
      notificationToken: json['notification_token'] as String?,
    );

Map<String, dynamic> _$MachineOrderRequestToJson(
  MachineOrderRequest instance,
) => <String, dynamic>{
  'customer_id': instance.customerId,
  'customer_phone': instance.customerPhone,
  'store_machine_id': instance.storeMachineId,
  'program_code': instance.programCode,
  'add_time_value': instance.addTimeValue,
  'payment_method': instance.paymentMethod,
  'coupon_customer_id': instance.couponCustomerId,
  'discount_id': instance.discountId,
  'notification_token': instance.notificationToken,
};
