// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_receipt_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CouponReceiptResponse _$CouponReceiptResponseFromJson(
  Map<String, dynamic> json,
) => CouponReceiptResponse(
  status: json['status'] as String?,
  data: json['data'] == null
      ? null
      : CouponReceiptData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CouponReceiptResponseToJson(
  CouponReceiptResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'data': instance.data?.toJson(),
};

CouponReceiptData _$CouponReceiptDataFromJson(Map<String, dynamic> json) =>
    CouponReceiptData(
      receiptAt: const DateTimeConverter().fromJson(
        json['receipt_at'] as String?,
      ),
      totalPrice: json['total_price'] as String?,
      netPrice: json['net_price'] as String?,
      savePrice: json['save_price'] as String?,
      receiptNo: json['receipt_no'] as String?,
      paymentMethod: json['payment_method'] as String?,
      paymentIcon: json['payment_icon'] as String?,
      packageName: json['package_name'] == null
          ? null
          : ContentLocalizeData.fromJson(
              json['package_name'] as Map<String, dynamic>,
            ),
      luckyNo: json['lucky_no'] as String?,
      luckyImage: json['lucky_image'] as String?,
      qrImage: json['qr_image'] as String?,
    );

Map<String, dynamic> _$CouponReceiptDataToJson(CouponReceiptData instance) =>
    <String, dynamic>{
      'receipt_at': const DateTimeConverter().toJson(instance.receiptAt),
      'total_price': instance.totalPrice,
      'net_price': instance.netPrice,
      'save_price': instance.savePrice,
      'receipt_no': instance.receiptNo,
      'payment_method': instance.paymentMethod,
      'payment_icon': instance.paymentIcon,
      'package_name': instance.packageName?.toJson(),
      'lucky_no': instance.luckyNo,
      'lucky_image': instance.luckyImage,
      'qr_image': instance.qrImage,
    };
