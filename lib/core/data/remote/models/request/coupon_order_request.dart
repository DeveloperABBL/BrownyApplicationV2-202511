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

  CouponOrderRequest({
    required this.customerId,
    required this.couponPackageId,
    required this.quantity,
    required this.paymentMethod,
  });

  factory CouponOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$CouponOrderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CouponOrderRequestToJson(this);
}
