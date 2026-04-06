import 'package:json_annotation/json_annotation.dart';

part 'payment_method_response.g.dart';

@JsonSerializable(explicitToJson: true)
class PaymentMethodResponse {
  @JsonKey(name: 'payments')
  final List<PaymentMethodData>? payments;

  PaymentMethodResponse({
    this.payments,
  });

  factory PaymentMethodResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentMethodResponseToJson(this);
}

@JsonSerializable()
class PaymentMethodData {
  @JsonKey(name: 'code')
  final String? code;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'image')
  final String? image;

  PaymentMethodData({
    this.code,
    this.name,
    this.image,
  });

  factory PaymentMethodData.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodDataFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentMethodDataToJson(this);
}
