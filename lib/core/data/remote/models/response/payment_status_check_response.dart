import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_status_check_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************
@JsonSerializable()
class PaymentStatusCheckResponse {
  @JsonKey(name: 'status')
  /// สถานะการชำระเงิน
  /// - "paid": ชำระเงินสำเร็จแล้ว
  /// - "pending": รอการชำระเงิน
  /// - "failed": ชำระเงินล้มเหลว (ถ้ามี)
  @JsonKey(name: 'status')
  final String status;

  /// URL สำหรับ redirect ไปหน้า receipt (มีเมื่อสถานะเป็น paid)
  @JsonKey(name: 'redirect')
  final String? redirect;

  /// order_id สำหรับหา receipt
  @JsonKey(name: 'order_id')
  final dynamic orderId;

  /// สถานะการชำระเงินจาก payment provider — "paid", "pending", ...
  /// (เพิ่มสำหรับ Browny Shop, endpoint อื่นอาจไม่ส่งค่านี้)
  @JsonKey(name: 'payment_status')
  final String? paymentStatus;

  /// เลขใบเสร็จ (มีเมื่อ paid)
  @JsonKey(name: 'receipt_no')
  final String? receiptNo;

  /// ข้อความจาก server เช่น "ยังไม่ชำระเงิน" (เคสยังไม่จ่าย)
  @JsonKey(name: 'message')
  final String? message;

  PaymentStatusCheckResponse({
    required this.status,
    this.redirect,
    this.orderId,
    this.paymentStatus,
    this.receiptNo,
    this.message,
  });

  factory PaymentStatusCheckResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentStatusCheckResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentStatusCheckResponseToJson(this);

  /// ตรวจสอบว่าชำระเงินสำเร็จแล้วหรือไม่
  bool get isPaid =>
      status.toLowerCase() == 'paid' ||
      paymentStatus.orEmpty.toLowerCase() == 'paid';

  /// ตรวจสอบว่ายังรอการชำระเงินอยู่หรือไม่
  bool get isPending =>
      status.toLowerCase() == 'pending' ||
      paymentStatus.orEmpty.toLowerCase() == 'pending';

  /// ตรวจสอบว่าไม่พบรายการหรือไม่
  bool get isNotFound => status.toLowerCase() == 'not_found';
}
