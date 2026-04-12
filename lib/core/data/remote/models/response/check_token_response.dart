import 'package:json_annotation/json_annotation.dart';

part 'check_token_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class CheckTokenResponse {
  CheckTokenResponse({
    this.message,
    this.client,
  });

  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'client')
  final CheckTokenClientData? client;

  /// เช็คว่า Token ยังใช้งานได้หรือไม่
  bool get isValid => client != null;

  factory CheckTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckTokenResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CheckTokenResponseToJson(this);
}

@JsonSerializable()
class CheckTokenClientData {
  CheckTokenClientData({
    this.version,
    this.status,
  });

  @JsonKey(name: 'version')
  final String? version;

  @JsonKey(name: 'status')
  final String? status;

  /// เช็คว่า client status เป็น active หรือไม่
  bool get isActive => status?.toLowerCase() == 'active';

  factory CheckTokenClientData.fromJson(Map<String, dynamic> json) =>
      _$CheckTokenClientDataFromJson(json);
  Map<String, dynamic> toJson() => _$CheckTokenClientDataToJson(this);
}
