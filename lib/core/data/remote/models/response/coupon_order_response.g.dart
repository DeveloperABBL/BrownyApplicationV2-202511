// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CouponOrderResponse _$CouponOrderResponseFromJson(Map<String, dynamic> json) =>
    CouponOrderResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : CouponOrderData.fromJson(json['data'] as Map<String, dynamic>),
      walletBalance: (json['wallet_balance'] as num?)?.toDouble(),
      redirectUrl: json['redirect_url'] as String?,
      paid: json['paid'] as bool?,
      priceRequired: (json['price_required'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CouponOrderResponseToJson(
  CouponOrderResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
  'wallet_balance': instance.walletBalance,
  'redirect_url': instance.redirectUrl,
  'paid': instance.paid,
  'price_required': instance.priceRequired,
};

CouponOrderData _$CouponOrderDataFromJson(Map<String, dynamic> json) =>
    CouponOrderData(
      id: (json['id'] as num?)?.toInt(),
      orderNo: json['order_no'] as String?,
      customerId: json['customer_id'] as String?,
      couponPackageId: (json['coupon_package_id'] as num?)?.toInt(),
      quantity: (json['quantity'] as num?)?.toInt(),
      price: json['price'] as String?,
      totalPrice: json['total_price'],
      paymentMethod: json['payment_method'] as String?,
      paymentStatus: json['payment_status'] as String?,
      paymentRef: json['payment_ref'] as String?,
      gatewayTransactionId: json['gateway_transaction_id'] as String?,
      responsePayload: json['response_payload'],
      respondedAt: json['responded_at'] as String?,
      receiptNo: json['receipt_no'] as String?,
      receiptAt: json['receipt_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$CouponOrderDataToJson(CouponOrderData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_no': instance.orderNo,
      'customer_id': instance.customerId,
      'coupon_package_id': instance.couponPackageId,
      'quantity': instance.quantity,
      'price': instance.price,
      'total_price': instance.totalPrice,
      'payment_method': instance.paymentMethod,
      'payment_status': instance.paymentStatus,
      'payment_ref': instance.paymentRef,
      'gateway_transaction_id': instance.gatewayTransactionId,
      'response_payload': instance.responsePayload,
      'responded_at': instance.respondedAt,
      'receipt_no': instance.receiptNo,
      'receipt_at': instance.receiptAt,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
