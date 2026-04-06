import 'package:json_annotation/json_annotation.dart';
import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:browny_applications_new/core/utils/json_converters.dart';

part 'topup_request_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class TopupRequestResponse extends BaseResponse {
  TopupRequestResponse({
    super.success,
    super.errorType,
    super.message,
    this.paymentRef,
    this.qrCodeData,
    this.confirmedAt,
    this.amount,
  });

  @JsonKey(name: 'payment_ref')
  final String? paymentRef;

  @JsonKey(name: 'qrcode')
  final String? qrCodeData;

  @JsonKey(name: 'confirmed_at')
  @DateTimeConverter()
  final DateTime? confirmedAt;

  @JsonKey(name: 'amount')
  final String? amount;

  factory TopupRequestResponse.fromJson(Map<String, dynamic> json) =>
      _$TopupRequestResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      baseToJson(_$TopupRequestResponseToJson(this));
}
