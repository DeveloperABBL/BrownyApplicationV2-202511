import 'package:browny_applications_new/core/data/remote/models/response/machine_order_receipt_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/payment_status_check_response.dart';
import 'package:browny_applications_new/feature/transactions/models/coupon_receipt_model.dart';

/// สถานะของ Payment Transaction รวมทั้ง payment status และ receipt
///
/// ใช้สำหรับจัดการ state ที่เกี่ยวข้องกับการชำระเงินและใบเสร็จในที่เดียว
/// แทนที่จะแยก paymentStatus และ receipt เป็น 2 notifier
class PaymentTransactionState {
  final PaymentStatusCheckResponse? paymentStatus;
  final CouponReceiptModel? receipt;
  final TransactionStep step;
  final Exception? error;

  PaymentTransactionState({
    this.paymentStatus,
    this.receipt,
    this.step = TransactionStep.idle,
    this.error,
  });

  /// สถานะเริ่มต้น
  factory PaymentTransactionState.idle() => PaymentTransactionState(
    step: TransactionStep.idle,
  );

  /// กำลังตรวจสอบสถานะการชำระเงิน
  factory PaymentTransactionState.checkingPayment() => PaymentTransactionState(
    step: TransactionStep.checkingPayment,
  );

  /// ชำระเงินสำเร็จ
  factory PaymentTransactionState.paymentSuccess(
    PaymentStatusCheckResponse paymentStatus,
  ) => PaymentTransactionState(
    paymentStatus: paymentStatus,
    step: TransactionStep.paymentSuccess,
  );

  /// กำลังโหลดใบเสร็จ
  factory PaymentTransactionState.loadingReceipt(
    PaymentStatusCheckResponse paymentStatus,
  ) => PaymentTransactionState(
    paymentStatus: paymentStatus,
    step: TransactionStep.loadingReceipt,
  );

  /// โหลดใบเสร็จสำเร็จ
  factory PaymentTransactionState.receiptLoaded(
    PaymentStatusCheckResponse paymentStatus,
    CouponReceiptModel receipt,
  ) => PaymentTransactionState(
    paymentStatus: paymentStatus,
    receipt: receipt,
    step: TransactionStep.receiptLoaded,
  );

  /// เกิดข้อผิดพลาด
  factory PaymentTransactionState.error(
    Exception error, {
    PaymentStatusCheckResponse? paymentStatus,
    CouponReceiptModel? receipt,
  }) => PaymentTransactionState(
    paymentStatus: paymentStatus,
    receipt: receipt,
    step: TransactionStep.error,
    error: error,
  );

  // ========== Helper Getters ==========

  /// ตรวจสอบว่าสามารถดึงใบเสร็จได้หรือไม่
  bool get canFetchReceipt =>
      paymentStatus?.isPaid == true && paymentStatus?.orderId != null;

  /// ดึง orderId จาก payment status
  dynamic get orderId => paymentStatus?.orderId;

  /// ตรวจสอบว่าชำระเงินสำเร็จหรือไม่
  bool get isPaymentSuccess => paymentStatus?.isPaid == true;

  /// ตรวจสอบว่ามีใบเสร็จหรือไม่
  bool get hasReceipt => receipt != null;

  /// ตรวจสอบว่าอยู่ในสถานะ loading หรือไม่
  bool get isLoading =>
      step == TransactionStep.checkingPayment ||
      step == TransactionStep.loadingReceipt;

  /// ตรวจสอบว่าเกิดข้อผิดพลาดหรือไม่
  bool get hasError => step == TransactionStep.error;

  /// ตรวจสอบว่า transaction เสร็จสมบูรณ์ (มีใบเสร็จแล้ว)
  bool get isComplete => step == TransactionStep.receiptLoaded;

  /// Copy with pattern สำหรับอัพเดท state
  PaymentTransactionState copyWith({
    PaymentStatusCheckResponse? paymentStatus,
    CouponReceiptModel? receipt,
    TransactionStep? step,
    Exception? error,
  }) {
    return PaymentTransactionState(
      paymentStatus: paymentStatus ?? this.paymentStatus,
      receipt: receipt ?? this.receipt,
      step: step ?? this.step,
      error: error ?? this.error,
    );
  }
}

/// สถานะของ Payment Transaction รวมทั้ง payment status และ receipt
///
/// ใช้สำหรับจัดการ state ที่เกี่ยวข้องกับการชำระเงินและใบเสร็จในที่เดียว
/// แทนที่จะแยก paymentStatus และ receipt เป็น 2 notifier
class MachinePaymentTransactionState {
  final PaymentStatusCheckResponse? paymentStatus;
  final MachineOrderReceiptResponse? receipt;
  final TransactionStep step;
  final Exception? error;

  MachinePaymentTransactionState({
    this.paymentStatus,
    this.receipt,
    this.step = TransactionStep.idle,
    this.error,
  });

  /// สถานะเริ่มต้น
  factory MachinePaymentTransactionState.idle() =>
      MachinePaymentTransactionState(
        step: TransactionStep.idle,
      );

  /// กำลังตรวจสอบสถานะการชำระเงิน
  factory MachinePaymentTransactionState.checkingPayment() =>
      MachinePaymentTransactionState(
        step: TransactionStep.checkingPayment,
      );

  /// ชำระเงินสำเร็จ
  factory MachinePaymentTransactionState.paymentSuccess(
    PaymentStatusCheckResponse paymentStatus,
  ) => MachinePaymentTransactionState(
    paymentStatus: paymentStatus,
    step: TransactionStep.paymentSuccess,
  );

  /// กำลังโหลดใบเสร็จ
  factory MachinePaymentTransactionState.loadingReceipt(
    PaymentStatusCheckResponse paymentStatus,
  ) => MachinePaymentTransactionState(
    paymentStatus: paymentStatus,
    step: TransactionStep.loadingReceipt,
  );

  /// โหลดใบเสร็จสำเร็จ
  factory MachinePaymentTransactionState.receiptLoaded(
    PaymentStatusCheckResponse paymentStatus,
    MachineOrderReceiptResponse receipt,
  ) => MachinePaymentTransactionState(
    paymentStatus: paymentStatus,
    receipt: receipt,
    step: TransactionStep.receiptLoaded,
  );

  /// เกิดข้อผิดพลาด
  factory MachinePaymentTransactionState.error(
    Exception error, {
    PaymentStatusCheckResponse? paymentStatus,
    MachineOrderReceiptResponse? receipt,
  }) => MachinePaymentTransactionState(
    paymentStatus: paymentStatus,
    receipt: receipt,
    step: TransactionStep.error,
    error: error,
  );

  // ========== Helper Getters ==========

  /// ตรวจสอบว่าสามารถดึงใบเสร็จได้หรือไม่
  bool get canFetchReceipt =>
      paymentStatus?.isPaid == true && paymentStatus?.orderId != null;

  /// ดึง orderId จาก payment status
  dynamic get orderId => paymentStatus?.orderId;

  /// ตรวจสอบว่าชำระเงินสำเร็จหรือไม่
  bool get isPaymentSuccess => paymentStatus?.isPaid == true;

  /// ตรวจสอบว่ามีใบเสร็จหรือไม่
  bool get hasReceipt => receipt != null;

  /// ตรวจสอบว่าอยู่ในสถานะ loading หรือไม่
  bool get isLoading =>
      step == TransactionStep.checkingPayment ||
      step == TransactionStep.loadingReceipt;

  /// ตรวจสอบว่าเกิดข้อผิดพลาดหรือไม่
  bool get hasError => step == TransactionStep.error;

  /// ตรวจสอบว่า transaction เสร็จสมบูรณ์ (มีใบเสร็จแล้ว)
  bool get isComplete => step == TransactionStep.receiptLoaded;

  /// Copy with pattern สำหรับอัพเดท state
  MachinePaymentTransactionState copyWith({
    PaymentStatusCheckResponse? paymentStatus,
    MachineOrderReceiptResponse? receipt,
    TransactionStep? step,
    Exception? error,
  }) {
    return MachinePaymentTransactionState(
      paymentStatus: paymentStatus ?? this.paymentStatus,
      receipt: receipt ?? this.receipt,
      step: step ?? this.step,
      error: error ?? this.error,
    );
  }
}

/// ขั้นตอนของ Payment Transaction
enum TransactionStep {
  /// สถานะเริ่มต้น ยังไม่ได้เริ่มทำอะไร
  idle,

  /// กำลังตรวจสอบสถานะการชำระเงิน
  checkingPayment,

  /// ชำระเงินสำเร็จแล้ว (แต่ยังไม่ได้ดึงใบเสร็จ)
  paymentSuccess,

  /// กำลังโหลดข้อมูลใบเสร็จ
  loadingReceipt,

  /// โหลดใบเสร็จสำเร็จ (transaction เสร็จสมบูรณ์)
  receiptLoaded,

  /// เกิดข้อผิดพลาด
  error,
}
