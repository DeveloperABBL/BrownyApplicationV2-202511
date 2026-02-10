import 'dart:async';

import 'package:browny_applications_new/core/data/remote/models/request/coupon_order_request.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coupon_order_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coupon_receipt_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/payment_status_check_response.dart';
import 'package:browny_applications_new/core/data/repo/app_repository.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';
import 'package:dio/dio.dart';

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
  /// [orderData] ข้อมูลคำสั่งซื้อที่มี payment_ref สำหรับตรวจสอบสถานะ
  ///
  /// Returns:
  /// - RepoResult.success: สำเร็จ พร้อม PaymentStatusCheckResponse
  ///   - status: "paid" (ชำระสำเร็จ), "pending" (รอชำระ), "not_found" (ไม่พบ)
  ///   - orderId: รหัสคำสั่งซื้อ (ใช้สำหรับดึงใบเสร็จ)
  /// - RepoResult.error: เกิด error
  /// - RepoResult.empty: API ไม่สำเร็จ
  FutureOr<RepoResult<PaymentStatusCheckResponse>> checkPaymentStatus(
    CouponOrderData orderData,
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
    CouponOrderData orderData,
  ) async {
    try {
      final response = await requireRemote.checkPaymentStatusByRef(orderData);

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
}
