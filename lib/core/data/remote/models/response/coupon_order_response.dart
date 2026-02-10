import 'package:json_annotation/json_annotation.dart';

part 'coupon_order_response.g.dart';

// **************************************************************************
// เมื่อสร้าง class ของ JsonSerializable ใหม่ ให้ run command ใน terminal
// dart run build_runner build --delete-conflicting-outputs
// **************************************************************************
@JsonSerializable()
class CouponOrderResponse {
  @JsonKey(name: 'success')
  final bool? success;

  @JsonKey(name: 'message')
  final String? message;

  /// ข้อมูลคำสั่งซื้อ (มีเมื่อ success = true และมีการสร้างคำสั่งซื้อ)
  @JsonKey(name: 'data')
  final CouponOrderData? data;

  /// ยอดเงินคงเหลือใน Wallet
  /// - มีเมื่อชำระผ่าน wallet สำเร็จ
  /// - หรือเมื่อ wallet ไม่พอ (success = false)
  @JsonKey(name: 'wallet_balance')
  final double? walletBalance;

  /// URL สำหรับ redirect ไปชำระเงิน (สำหรับกรณี pending payment)
  @JsonKey(name: 'redirect_url')
  final String? redirectUrl;

  /// สถานะการชำระเงิน
  /// - true: ชำระเงินสำเร็จแล้ว (กรณี wallet payment)
  /// - false: รอการชำระเงิน (pending)
  @JsonKey(name: 'paid')
  final bool? paid;

  /// ราคาที่ต้องชำระ (มีเมื่อ wallet ไม่พอ)
  @JsonKey(name: 'price_required')
  final double? priceRequired;

  CouponOrderResponse({
    this.success,
    this.message,
    this.data,
    this.walletBalance,
    this.redirectUrl,
    this.paid,
    this.priceRequired,
  });

  factory CouponOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$CouponOrderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CouponOrderResponseToJson(this);

  /// ตรวจสอบว่าชำระเงินสำเร็จแล้วหรือไม่
  bool get isPaid => (success ?? true) && (paid ?? false);

  /// ตรวจสอบว่ารอการชำระเงินหรือไม่
  bool get isPending => (success ?? true) && !(paid ?? false);

  /// ตรวจสอบว่า wallet ไม่พอหรือไม่
  bool get isInsufficientWallet =>
      !(success ?? true) && priceRequired != null && walletBalance != null;

  /// คำนวณจำนวนเงินที่ขาด (กรณี wallet ไม่พอ)
  double get amountShortage {
    if (!isInsufficientWallet) return 0.0;
    return (priceRequired ?? 0.0) - (walletBalance ?? 0.0);
  }
}

@JsonSerializable()
class CouponOrderData {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'order_no')
  final String? orderNo;

  @JsonKey(name: 'customer_id')
  final String? customerId;

  @JsonKey(name: 'coupon_package_id')
  final int? couponPackageId;

  @JsonKey(name: 'quantity')
  final int? quantity;

  @JsonKey(name: 'price')
  final String? price;

  @JsonKey(name: 'total_price')
  final dynamic totalPrice;

  @JsonKey(name: 'payment_method')
  final String? paymentMethod;

  @JsonKey(name: 'payment_status')
  final String? paymentStatus;

  @JsonKey(name: 'payment_ref')
  final String? paymentRef;

  @JsonKey(name: 'gateway_transaction_id')
  final String? gatewayTransactionId;

  @JsonKey(name: 'response_payload')
  final dynamic responsePayload;

  @JsonKey(name: 'responded_at')
  final String? respondedAt;

  @JsonKey(name: 'receipt_no')
  final String? receiptNo;

  @JsonKey(name: 'receipt_at')
  final String? receiptAt;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  CouponOrderData({
    this.id,
    this.orderNo,
    this.customerId,
    this.couponPackageId,
    this.quantity,
    this.price,
    this.totalPrice,
    this.paymentMethod,
    this.paymentStatus,
    this.paymentRef,
    this.gatewayTransactionId,
    this.responsePayload,
    this.respondedAt,
    this.receiptNo,
    this.receiptAt,
    this.createdAt,
    this.updatedAt,
  });

  factory CouponOrderData.fromJson(Map<String, dynamic> json) =>
      _$CouponOrderDataFromJson(json);

  Map<String, dynamic> toJson() => _$CouponOrderDataToJson(this);

  /// แปลง price เป็น double
  double get priceValue => double.tryParse(price ?? '0') ?? 0.0;

  /// แปลง total price เป็น double (รองรับทั้ง string และ number)
  double get totalPriceValue {
    if (totalPrice == null) return 0.0;
    if (totalPrice is num) return (totalPrice as num).toDouble();
    if (totalPrice is String) {
      return double.tryParse(totalPrice as String) ?? 0.0;
    }
    return 0.0;
  }

  /// แปลง created_at เป็น DateTime
  DateTime? get createdDate {
    if (createdAt == null || createdAt!.isEmpty) return null;
    try {
      return DateTime.parse(createdAt!);
    } catch (e) {
      return null;
    }
  }

  /// แปลง updated_at เป็น DateTime
  DateTime? get updatedDate {
    if (updatedAt == null || updatedAt!.isEmpty) return null;
    try {
      return DateTime.parse(updatedAt!);
    } catch (e) {
      return null;
    }
  }

  /// แปลง responded_at เป็น DateTime
  DateTime? get respondedDate {
    if (respondedAt == null || respondedAt!.isEmpty) return null;
    try {
      return DateTime.parse(respondedAt!);
    } catch (e) {
      return null;
    }
  }

  /// แปลง receipt_at เป็น DateTime
  DateTime? get receiptDate {
    if (receiptAt == null || receiptAt!.isEmpty) return null;
    try {
      return DateTime.parse(receiptAt!);
    } catch (e) {
      return null;
    }
  }

  /// ตรวจสอบสถานะการชำระเงิน
  bool get isPaid => paymentStatus?.toLowerCase() == 'paid';

  bool get isPending => paymentStatus?.toLowerCase() == 'pending';

  bool get isFailed => paymentStatus?.toLowerCase() == 'failed';
}
