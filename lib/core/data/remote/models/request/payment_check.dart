import 'package:json_annotation/json_annotation.dart';

part 'payment_check.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// dart run build_runner watch (auto gen)
// **************************************************************************

@JsonSerializable()
class PaymentCheck {
  PaymentCheck({
    required this.paymentRef,
  });

  @JsonKey(name: 'payment_ref')
  final String paymentRef;

  factory PaymentCheck.fromJson(Map<String, dynamic> json) =>
      _$PaymentCheckFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentCheckToJson(this);
}
