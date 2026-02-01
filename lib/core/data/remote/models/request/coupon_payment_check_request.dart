import 'package:json_annotation/json_annotation.dart';

part 'coupon_payment_check_request.g.dart';

@JsonSerializable()
class CouponPaymentCheckRequest {
  @JsonKey(name: 'payment_ref')
  final String paymentRef;

  CouponPaymentCheckRequest({
    required this.paymentRef,
  });

  factory CouponPaymentCheckRequest.fromJson(Map<String, dynamic> json) =>
      _$CouponPaymentCheckRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CouponPaymentCheckRequestToJson(this);
}
