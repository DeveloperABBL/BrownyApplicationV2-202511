import 'package:json_annotation/json_annotation.dart';
import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';

part 'customer_qr_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// dart run build_runner watch (auto gen)
// **************************************************************************

@JsonSerializable()
class CustomerQRResponse extends BaseModelResponse {
  CustomerQRResponse({
    super.success,
    super.errorType,
    super.message,
    this.url,
    this.ads,
  });

  @JsonKey(name: 'url')
  final String? url;

  @JsonKey(name: 'ads')
  final String? ads;

  factory CustomerQRResponse.fromJson(Map<String, dynamic> json) =>
      _$CustomerQRResponseFromJson(json);
  Map<String, dynamic> toJson() => baseToJson(_$CustomerQRResponseToJson(this));
}
