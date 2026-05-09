import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'referral_status_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************

@JsonSerializable()
class ReferralStatusResponse {
  ReferralStatusResponse({
    this.enabled,
    this.terms,
  });

  @JsonKey(name: 'enabled')
  final bool? enabled;

  @JsonKey(name: 'terms')
  final ContentLocalizeData? terms;

  /// ดึง terms ตาม locale
  String getTermsDisplay(String locale) {
    return terms?.getByLocaleCode(locale) ?? '';
  }

  /// เช็คว่าระบบแนะนำเพื่อนเปิดใช้งานอยู่หรือไม่
  bool get isEnabled => enabled == true;

  factory ReferralStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$ReferralStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralStatusResponseToJson(this);
}
