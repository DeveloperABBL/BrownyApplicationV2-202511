import 'package:json_annotation/json_annotation.dart';

part 'coupon_payment_check_response.g.dart';

@JsonSerializable()
class CouponPaymentCheckResponse {
  /// สถานะการชำระเงิน
  /// - "paid": ชำระเงินสำเร็จแล้ว
  /// - "pending": รอการชำระเงิน
  /// - "failed": ชำระเงินล้มเหลว (ถ้ามี)
  @JsonKey(name: 'status')
  final String status;

  /// URL สำหรับ redirect ไปหน้า receipt (มีเมื่อสถานะเป็น paid)
  @JsonKey(name: 'redirect')
  final String? redirect;

  CouponPaymentCheckResponse({
    required this.status,
    this.redirect,
  });

  factory CouponPaymentCheckResponse.fromJson(Map<String, dynamic> json) =>
      _$CouponPaymentCheckResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CouponPaymentCheckResponseToJson(this);

  /// ตรวจสอบว่าชำระเงินสำเร็จแล้วหรือไม่
  bool get isPaid => status.toLowerCase() == 'paid';

  /// ตรวจสอบว่ารอการชำระเงินหรือไม่
  bool get isPending => status.toLowerCase() == 'pending';

  /// ตรวจสอบว่าชำระเงินล้มเหลวหรือไม่
  bool get isFailed => status.toLowerCase() == 'failed';

  /// ตรวจสอบว่ามี redirect URL หรือไม่
  bool get hasRedirectUrl => redirect != null && redirect!.isNotEmpty;
}
