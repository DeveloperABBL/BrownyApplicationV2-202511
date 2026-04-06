// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'machine_order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MachineOrderResponse _$MachineOrderResponseFromJson(
  Map<String, dynamic> json,
) => MachineOrderResponse(
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : MachineOrderData.fromJson(json['data'] as Map<String, dynamic>),
  redirectUrl: json['redirect_url'] as String?,
  qrAndWechat: json['qr_and_wechat'] as String?,
);

Map<String, dynamic> _$MachineOrderResponseToJson(
  MachineOrderResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'data': instance.data,
  'redirect_url': instance.redirectUrl,
  'qr_and_wechat': instance.qrAndWechat,
};

MachineOrderData _$MachineOrderDataFromJson(Map<String, dynamic> json) =>
    MachineOrderData(
      customerId: json['customer_id'] as String?,
      customerPhone: json['customer_phone'] as String?,
      storeMachineId: (json['store_machine_id'] as num?)?.toInt(),
      programCode: json['program_code'] as String?,
      programName: json['program_name'] as String?,
      addTimeValue: (json['add_time_value'] as num?)?.toInt(),
      couponCustomerId: (json['coupon_customer_id'] as num?)?.toInt(),
      discountId: json['discount_id'] as String?,
      couponDiscount: json['coupon_discount'] as String?,
      systemDiscount: json['system_discount'] as String?,
      discountAmount: json['discount_amount'] as String?,
      priceOriginal: json['price_original'] as String?,
      priceFinal: json['price_final'] as String?,
      paymentMethod: json['payment_method'] as String?,
      paymentStatus: json['payment_status'] as String?,
      paymentRef: json['payment_ref'] as String?,
      machineStatus: json['machine_status'] as String?,
      deviceLogId: json['device_log_id'] as String?,
      id: json['id'] as String?,
      updatedAt: json['updated_at'] as String?,
      createdAt: json['created_at'] as String?,
      responsePayload: json['response_payload'] == null
          ? null
          : ResponsePayload.fromJson(
              json['response_payload'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$MachineOrderDataToJson(MachineOrderData instance) =>
    <String, dynamic>{
      'customer_id': instance.customerId,
      'customer_phone': instance.customerPhone,
      'store_machine_id': instance.storeMachineId,
      'program_code': instance.programCode,
      'program_name': instance.programName,
      'add_time_value': instance.addTimeValue,
      'coupon_customer_id': instance.couponCustomerId,
      'discount_id': instance.discountId,
      'coupon_discount': instance.couponDiscount,
      'response_payload': instance.responsePayload,
      'system_discount': instance.systemDiscount,
      'discount_amount': instance.discountAmount,
      'price_original': instance.priceOriginal,
      'price_final': instance.priceFinal,
      'payment_method': instance.paymentMethod,
      'payment_status': instance.paymentStatus,
      'payment_ref': instance.paymentRef,
      'machine_status': instance.machineStatus,
      'device_log_id': instance.deviceLogId,
      'id': instance.id,
      'updated_at': instance.updatedAt,
      'created_at': instance.createdAt,
    };
