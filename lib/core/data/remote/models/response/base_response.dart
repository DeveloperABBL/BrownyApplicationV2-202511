import 'package:json_annotation/json_annotation.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************
abstract class BaseModelResponse {
  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'error_type')
  final String? errorType;

  BaseModelResponse({
    required this.message,
    required this.errorType,
    bool? success,
  }) : success = success ?? false;

  bool get isResponseSuccess => success;

  Map<String, dynamic> baseToJson(Map<String, dynamic> target) => target
    ..remove('sucess')
    ..remove('message')
    ..remove('error_type');
}
