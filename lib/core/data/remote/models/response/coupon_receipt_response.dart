import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/utils/json_converters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'coupon_receipt_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable(explicitToJson: true)
class CouponReceiptResponse {
  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'data')
  final CouponReceiptData? data;

  CouponReceiptResponse({
    this.status,
    this.data,
  });

  factory CouponReceiptResponse.fromJson(Map<String, dynamic> json) =>
      _$CouponReceiptResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CouponReceiptResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CouponReceiptData {
  @JsonKey(name: 'receipt_at')
  @DateTimeConverter()
  final DateTime? receiptAt;

  @JsonKey(name: 'total_price')
  final String? totalPrice;

  @JsonKey(name: 'net_price')
  final String? netPrice;

  @JsonKey(name: 'save_price')
  final String? savePrice;

  @JsonKey(name: 'receipt_no')
  final String? receiptNo;

  @JsonKey(name: 'payment_method')
  final String? paymentMethod;

  @JsonKey(name: 'payment_icon')
  final String? paymentIcon;

  @JsonKey(name: 'package_name')
  final ContentLocalizeData? packageName;

  @JsonKey(name: 'lucky_no')
  final String? luckyNo;

  @JsonKey(name: 'lucky_image')
  final String? luckyImage;

  @JsonKey(name: 'qr_image')
  final String? qrImage;

  @JsonKey(name: 'bonus')
  final String? bonus;

  CouponReceiptData({
    this.receiptAt,
    this.totalPrice,
    this.netPrice,
    this.savePrice,
    this.receiptNo,
    this.paymentMethod,
    this.paymentIcon,
    this.packageName,
    this.luckyNo,
    this.luckyImage,
    this.qrImage,
    this.bonus,
  });

  factory CouponReceiptData.fromJson(Map<String, dynamic> json) =>
      _$CouponReceiptDataFromJson(json);
  Map<String, dynamic> toJson() => _$CouponReceiptDataToJson(this);
}
