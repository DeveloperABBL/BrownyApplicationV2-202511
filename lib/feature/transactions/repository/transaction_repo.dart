import 'dart:async';
import 'dart:convert';

import 'package:browny_applications_new/core/data/remote/models/request/coupon_order_request.dart';
import 'package:browny_applications_new/core/data/remote/models/request/payment_check.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coupon_order_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coupon_receipt_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/machine_order_receipt_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/payment_status_check_response.dart';
import 'package:browny_applications_new/core/data/repo/app_repository.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Mixin สำหรับจัดการข้อมูลธุรกรรมคูปอง/e-voucher
///
/// ประกอบด้วย:
/// - การสร้างคำสั่งซื้อคูปอง
/// - การตรวจสอบสถานะการชำระเงิน
/// - การดึงข้อมูลใบเสร็จ
mixin TransactionDataSourceMixin {
  /// สร้างคำสั่งซื้อคูปอง/e-voucher
  ///
  /// [request] ข้อมูลคำสั่งซื้อ ประกอบด้วย:
  /// - customerId: รหัสลูกค้า
  /// - couponPackageId: รหัสแพ็คเกจคูปอง
  /// - quantity: จำนวน
  /// - paymentMethod: ช่องทางการชำระเงิน (qr, tp_wallet, shopee_pay, etc.)
  ///
  /// Returns:
  /// - RepoResult.success: สำเร็จ พร้อม CouponOrderResponse (payment_ref, redirect_url)
  /// - RepoResult.error: เกิด error
  /// - RepoResult.empty: API ไม่สำเร็จ
  Future<RepoResult<CouponOrderResponse>> createCouponOrder(
    CouponOrderRequest request,
  );

  /// ตรวจสอบสถานะการชำระเงินคูปอง/e-voucher
  ///
  /// [paymentCheck] ข้อมูล payment_ref สำหรับตรวจสอบสถานะ
  ///
  /// Returns:
  /// - RepoResult.success: สำเร็จ พร้อม PaymentStatusCheckResponse
  ///   - status: "paid" (ชำระสำเร็จ), "pending" (รอชำระ), "not_found" (ไม่พบ)
  ///   - orderId: รหัสคำสั่งซื้อ (ใช้สำหรับดึงใบเสร็จ)
  /// - RepoResult.error: เกิด error
  /// - RepoResult.empty: API ไม่สำเร็จ
  FutureOr<RepoResult<PaymentStatusCheckResponse>> checkPaymentStatus(
    PaymentCheck paymentCheck,
  );

  /// ดึงข้อมูลใบเสร็จคูปอง/e-voucher
  ///
  /// [orderId] รหัสคำสั่งซื้อที่ได้จาก checkPaymentStatus
  ///
  /// Returns:
  /// - RepoResult.success: สำเร็จ พร้อม CouponReceiptResponse
  ///   - receiptAt: วันที่/เวลา
  ///   - totalPrice, netPrice, savePrice: ราคา
  ///   - receiptNo: เลขที่ใบเสร็จ
  ///   - paymentMethod, paymentIcon: ช่องทางการชำระเงิน
  ///   - packageName: ชื่อแพ็คเกจ (localized)
  ///   - luckyNo, luckyImage: เลขโชคดี
  ///   - qrImage: QR Code
  /// - RepoResult.error: เกิด error
  /// - RepoResult.empty: API ไม่สำเร็จ
  Future<RepoResult<CouponReceiptResponse>> fetchCouponReceipt(
    String orderId,
  );

  /// ดึงข้อมูลใบเสร็จ machine order
  ///
  /// [orderId] รหัสคำสั่งซื้อ machine order
  ///
  /// Returns:
  /// - RepoResult.success: สำเร็จ พร้อม MachineOrderReceiptResponse
  /// - RepoResult.error: เกิด error
  /// - RepoResult.empty: API ไม่สำเร็จ
  Future<RepoResult<MachineOrderReceiptResponse>> fetchMachineOrderReceipt(
    String orderId,
  );

  /// ตรวจสอบสถานะการชำระเงินเครื่องซัก/อบ
  ///
  /// [paymentCheck] ข้อมูล payment_ref สำหรับตรวจสอบสถานะ
  ///
  /// Returns:
  /// - RepoResult.success: สำเร็จ พร้อม PaymentStatusCheckResponse
  ///   - status: "paid" (ชำระสำเร็จ), "pending" (รอชำระ), "not_found" (ไม่พบ)
  /// - RepoResult.error: เกิด error
  /// - RepoResult.empty: API ไม่สำเร็จ
  FutureOr<RepoResult<PaymentStatusCheckResponse>>
  checkMachineOrderPaymentStatus(
    PaymentCheck paymentCheck,
  );
}

class TransactionRepo extends AppRepository with TransactionDataSourceMixin {
  @override
  Future<RepoResult<CouponOrderResponse>> createCouponOrder(
    CouponOrderRequest request,
  ) async {
    try {
      final response = await requireRemote.createCouponOrder(request);

      if (response.isSuccessful) {
        final data = response.data;
        return RepoResult.success(data: data);
      }

      return RepoResult.empty(
        error: Exception(
          'HTTP ${response.response.statusCode}: ${response.response.statusMessage}',
        ),
      );
    } on DioException catch (dio) {
      // Handle Dio exceptions (network errors, timeouts, etc.)
      return RepoResult.error(
        error: Exception(
          dio.response?.data?['message'] ??
              dio.message ??
              'Network error occurred',
        ),
      );
    } catch (e) {
      return RepoResult.error(error: Exception(e.toString()));
    }
  }

  @override
  FutureOr<RepoResult<PaymentStatusCheckResponse>> checkPaymentStatus(
    PaymentCheck paymentCheck,
  ) async {
    try {
      final response = await requireRemote.checkPaymentStatusByRef(
        paymentCheck,
      );

      if (response.isSuccessful) {
        final data = response.data;
        return RepoResult.success(data: data);
      }

      return RepoResult.empty(
        error: Exception(
          'HTTP ${response.response.statusCode}: ${response.response.statusMessage}',
        ),
      );
    } on DioException catch (dio) {
      // Handle Dio exceptions (network errors, timeouts, etc.)
      return RepoResult.error(
        error: Exception(
          dio.response?.data?['message'] ??
              dio.message ??
              'Network error occurred',
        ),
      );
    } catch (e) {
      return RepoResult.error(error: Exception(e.toString()));
    }
  }

  @override
  Future<RepoResult<CouponReceiptResponse>> fetchCouponReceipt(
    String orderId,
  ) async {
    try {
      final response = await requireRemote.fetchCouponReceipt(orderId);

      if (response.isSuccessful) {
        final data = response.data;
        return RepoResult.success(data: data);
      }

      return RepoResult.empty(
        error: Exception(
          'HTTP ${response.response.statusCode}: ${response.response.statusMessage}',
        ),
      );
    } on DioException catch (dio) {
      // Handle Dio exceptions (network errors, timeouts, etc.)
      return RepoResult.error(
        error: Exception(
          dio.response?.data?['message'] ??
              dio.message ??
              'Network error occurred',
        ),
      );
    } catch (e) {
      return RepoResult.error(error: Exception(e.toString()));
    }
  }

  @override
  Future<RepoResult<MachineOrderReceiptResponse>> fetchMachineOrderReceipt(
    String orderId,
  ) async {
    try {
      //       if (kDebugMode) {
      //         return RepoResult.success(
      //           data: MachineOrderReceiptResponse.fromJson(
      //             jsonDecode('''
      // {
      //     "lucky_number": null,
      //     "total": "60.00",
      //     "receipt_no": "BNP20260224-225349211346",
      //     "branch": {
      //         "th": "ตลาดคูล - บางกรวย",
      //         "en": "Cool Market - Bang Kruai",
      //         "zh": null
      //     },
      //     "machine_type": {
      //         "th": "เครื่องซัก",
      //         "en": "Washer",
      //         "zh": "洗衣机"
      //     },
      //     "machine_no": 1,
      //     "payment_icon": "https://dev.abgroup.co.th/assets/images/customerNotificationIconPaymnet/tp_wallet.png",
      //     "payment_channel": "tp_wallet",
      //     "payment_display": {
      //         "th": "TP Wallet",
      //         "en": "TP Wallet",
      //         "zh": "TP 钱包"
      //     },
      //     "paid_at": "2026-02-24 / 22:53",
      //     "summary": {
      //         "program": {
      //             "wording": {
      //                 "th": "น้ำร้อน",
      //                 "en": "Hot Water",
      //                 "zh": "热水"
      //             },
      //             "amount": "70.00"
      //         },
      //         "discount": {
      //             "wording": {
      //                 "th": "Test",
      //                 "en": "TEst",
      //                 "zh": "Test"
      //             },
      //             "amount": "-10.00"
      //         },
      //         "coupon_discount": {
      //             "wording": {
      //                 "th": "",
      //                 "en": "",
      //                 "zh": ""
      //             },
      //             "amount": ""
      //         },
      //         "coupon_evoucher": {
      //             "wording": {
      //                 "th": "",
      //                 "en": "",
      //                 "zh": ""
      //             },
      //             "amount": ""
      //         }
      //     },
      //     "call_center": "099-635-1211",
      //     "line_link": "https://line.me/R/ti/p/%40browny",
      //     "google_map_link": "https://line.me/R/ti/p/%40browny",
      //     "lucky_no": "96",
      //     "lucky_image": "https://dev.abgroup.co.th/images/lucky_no/96.png",
      //     "review_score": null,
      //     "qr_image": "https://dev.abgroup.co.th/storage/qrcodes/21.png"
      // }
      // '''),
      //           ),
      //         );
      //       }
      final response = await requireRemote.fetchMachineOrderReceipt(orderId);

      if (response.isSuccessful) {
        final data = response.data;
        return RepoResult.success(data: data);
      }

      return RepoResult.empty(
        error: Exception(
          'HTTP ${response.response.statusCode}: ${response.response.statusMessage}',
        ),
      );
    } on DioException catch (dio) {
      return RepoResult.error(
        error: Exception(
          dio.response?.data?['message'] ??
              dio.message ??
              'Network error occurred',
        ),
      );
    } catch (e) {
      return RepoResult.error(error: Exception(e.toString()));
    }
  }

  @override
  FutureOr<RepoResult<PaymentStatusCheckResponse>>
  checkMachineOrderPaymentStatus(
    PaymentCheck paymentCheck,
  ) async {
    try {
      //       if (kDebugMode) {
      //         return RepoResult.success(
      //           data: PaymentStatusCheckResponse.fromJson(
      //             jsonDecode('''
      // {
      //     "status": "paid",
      //     "order_id": "019cc70a-eef8-7285-8dc9-5bf006b6ca48",
      //     "redirect": "https://dev.abgroup.co.th/receipt/019cc70a-eef8-7285-8dc9-5bf006b6ca48"
      // }
      // '''),
      //           ),
      //         );
      //       }
      final response = await requireRemote.checkMachineOrderPaymentStatus(
        paymentCheck,
      );

      if (response.isSuccessful) {
        final data = response.data;
        return RepoResult.success(data: data);
      }

      return RepoResult.empty(
        error: Exception(
          'HTTP ${response.response.statusCode}: ${response.response.statusMessage}',
        ),
      );
    } on DioException catch (dio) {
      // Handle Dio exceptions (network errors, timeouts, etc.)
      return RepoResult.error(
        error: Exception(
          dio.response?.data?['message'] ??
              dio.message ??
              'Network error occurred',
        ),
      );
    } catch (e) {
      return RepoResult.error(error: Exception(e.toString()));
    }
  }
}
