// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browny_shop_pending_payment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrownyShopPendingPaymentResponse _$BrownyShopPendingPaymentResponseFromJson(
  Map<String, dynamic> json,
) => BrownyShopPendingPaymentResponse(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  errorType: json['error_type'] as String?,
  data: json['data'] == null
      ? null
      : BrownyShopPendingPaymentData.fromJson(
          json['data'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$BrownyShopPendingPaymentResponseToJson(
  BrownyShopPendingPaymentResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'error_type': instance.errorType,
  'data': instance.data,
};

BrownyShopPendingPaymentData _$BrownyShopPendingPaymentDataFromJson(
  Map<String, dynamic> json,
) => BrownyShopPendingPaymentData(
  hasPending: json['has_pending'] as bool?,
  orderId: json['order_id'] as String?,
  paymentRef: json['payment_ref'] as String?,
  status: json['status'] as String?,
);

Map<String, dynamic> _$BrownyShopPendingPaymentDataToJson(
  BrownyShopPendingPaymentData instance,
) => <String, dynamic>{
  'has_pending': instance.hasPending,
  'order_id': instance.orderId,
  'payment_ref': instance.paymentRef,
  'status': instance.status,
};
