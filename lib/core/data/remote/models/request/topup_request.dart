import 'package:json_annotation/json_annotation.dart';

part 'topup_request.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class TopupRequest {
  @JsonKey(name: 'customer_id')
  final String customerId;

  @JsonKey(name: 'amount')
  final int amount;

  @JsonKey(name: 'gateway')
  final String gateway;

  TopupRequest({
    required this.customerId,
    required this.amount,
    required this.gateway,
  });

  factory TopupRequest.fromJson(Map<String, dynamic> json) =>
      _$TopupRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TopupRequestToJson(this);
}
