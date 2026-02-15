import 'package:json_annotation/json_annotation.dart';

part 'verify_pin_response.g.dart';

/// Response model สำหรับ API Verify PIN
///
/// HTTP Code 200: PIN ถูกต้อง
/// HTTP Code 422: ข้อมูลไม่ถูกต้อง (validation error)
/// HTTP Code 401: PIN ไม่ถูกต้อง
@JsonSerializable()
class VerifyPinResponse {
  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'message')
  final String? message;

  /// Token สำหรับใช้งานต่อ (มีเฉพาะเมื่อ success = true)
  @JsonKey(name: 'token')
  final String? token;

  /// เวลาหมดอายุของ token ในหน่วยวินาที (มีเฉพาะเมื่อ success = true)
  @JsonKey(name: 'expire')
  final String? expire;

  /// Error type สำหรับกรณี PIN ไม่ถูกต้อง (HTTP 401)
  @JsonKey(name: 'error_type')
  final String? errorType;

  /// Validation errors สำหรับกรณีข้อมูลไม่ถูกต้อง (HTTP 422)
  @JsonKey(name: 'errors')
  final Map<String, dynamic>? errors;

  VerifyPinResponse({
    required this.success,
    this.message,
    this.token,
    this.expire,
    this.errorType,
    this.errors,
  });

  factory VerifyPinResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyPinResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyPinResponseToJson(this);
}
