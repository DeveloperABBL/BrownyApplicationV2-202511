import 'package:json_annotation/json_annotation.dart';

part 'coupon_order_request.g.dart';

@JsonSerializable()
class CouponOrderRequest {
  @JsonKey(name: 'customer_id')
  final String customerId;

  @JsonKey(name: 'coupon_package_id')
  final int couponPackageId;

  @JsonKey(name: 'quantity')
  final int quantity;

  @JsonKey(name: 'payment_method')
  final String paymentMethod;

  /// ใช้ Browny Coin เป็นส่วนลด (10 coins = 1 บาท)
  @JsonKey(name: 'use_coin', includeIfNull: false)
  final bool? useCoin;

  CouponOrderRequest({
    required this.customerId,
    required this.couponPackageId,
    required this.quantity,
    required this.paymentMethod,
    this.useCoin,
  });

  factory CouponOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$CouponOrderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CouponOrderRequestToJson(this);
}
