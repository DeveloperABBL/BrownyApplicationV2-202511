import 'package:json_annotation/json_annotation.dart';

part 'get_pin_response.g.dart';

/// Response model สำหรับ API Get PIN
@JsonSerializable()
class GetPinResponse {
  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'ciphertext')
  final String? ciphertext;

  @JsonKey(name: 'cipher')
  final String? cipher;

  GetPinResponse({
    required this.success,
    this.ciphertext,
    this.cipher,
  });

  factory GetPinResponse.fromJson(Map<String, dynamic> json) =>
      _$GetPinResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetPinResponseToJson(this);
}
