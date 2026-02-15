import 'package:json_annotation/json_annotation.dart';

part 'pin_request.g.dart';

/// Request model สำหรับ Set PIN และ Verify PIN
@JsonSerializable()
class PinRequest {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'pin')
  final String pin;

  PinRequest({
    required this.id,
    required this.pin,
  });

  factory PinRequest.fromJson(Map<String, dynamic> json) =>
      _$PinRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PinRequestToJson(this);
}
