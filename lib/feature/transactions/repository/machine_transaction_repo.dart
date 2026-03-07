import 'package:browny_applications_new/core/data/repo/app_repository.dart';
import 'package:browny_applications_new/core/data/remote/models/request/machine_order_request.dart';
import 'package:browny_applications_new/core/data/remote/models/request/machine_order_review_request.dart';
import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/machine_detail_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/machine_order_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/machine_programs_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/machine_status_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';
import 'package:browny_applications_new/feature/authentication/error/authen_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

mixin MachineTransactionDataSourceMixin {
  /// API fetch รายละเอียดเครื่อง (machine detail)
  Future<RepoResult<MachineDetailResponse>> fetchMachineDetail(
    String machineId,
  );

  /// API fetch โปรแกรมของเครื่อง (machine programs)
  Future<RepoResult<MachineProgramsResponse>> fetchMachinePrograms(
    String machineId,
    String customerId,
  );

  /// API สร้างคำสั่งซื้อเครื่องซัก/อบ (machine order)
  Future<RepoResult<MachineOrderResponse>> createMachineOrder(
    MachineOrderRequest request,
  );

  /// API ส่งคะแนนรีวิวคำสั่งซื้อเครื่องซัก/อบ
  Future<RepoResult<BaseResponse>> submitMachineOrderReview(
    String orderId,
    MachineOrderReviewRequest request,
  );

  /// API ตรวจสอบสถานะเครื่องจาก QR code
  Future<RepoResult<MachineStatusResponse>> checkMachineStatus(
    String qrCode,
  );
}

class MachineRepo extends AppRepository with MachineTransactionDataSourceMixin {
  @override
  Future<RepoResult<MachineDetailResponse>> fetchMachineDetail(
    String machineId,
  ) async {
    try {
      // if (kDebugMode) {
      //   return RepoResult.success(
      //     data: MachineDetailResponse.fromJson(
      //       jsonDecode('''
      // {
      //     "id": 13,
      //     "store_name": {
      //         "th": "ตลาดคูล - บางกรวย",
      //         "en": "Cool Market - Bang Kruai",
      //         "zh": "-"
      //     },
      //     "status": "Busy",
      //     "finish_datatime": "23:00",
      //     "remaining_time": "00:30:00",
      //     "machine_no": "1",
      //     "machine_image": "https://dev.abgroup.co.th/storage/galleries/s3nbAR7QLSPpZ9aSTWSyGV9nXQZy6JhsPgVvaJKL.png",
      //     "name": {
      //       "th": "เครื่องซัก 1 / Test",
      //       "en": "Washer 1 / Test",
      //       "zh": "洗衣机 1 / Test"
      //     },
      //     "order_id": "BBL11234",
      //     "receipt_no": "1234",
      //     "startTime": "2026-03-06 22:30:00",
      //     "addTime": [],
      //     "program_image": "https://dev.abgroup.co.th/storage/galleries/fFr4U1j8jv8NYy1adbWjJvsuT9BaX9AOWAnoOASF.png",
      //     "program_name": {
      //     "th": "น้ำเย็น",
      //     "en": "Cold Water",
      //     "zh": "冷水"
      //     },
      //     "machine_type": {
      //         "th": "เครื่องอบ",
      //         "en": "Washer",
      //         "zh": "烘干机"
      //     }
      // }
      // '''),
      //     ),
      //   );
      // }
      final response = await requireRemote.fetchMachineDetail(machineId);
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<MachineProgramsResponse>> fetchMachinePrograms(
    String machineId,
    String customerId,
  ) async {
    try {
      final response = await requireRemote.fetchMachinePrograms(
        machineId,
        customerId,
      );
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<MachineOrderResponse>> createMachineOrder(
    MachineOrderRequest request,
  ) async {
    // ========== Mock Data for Debug Mode (priceFinal = 0.0) ==========
    if (kDebugMode) {
      // Mock response สำหรับทดสอบกรณีลด 100% (priceFinal = 0.0)
      final mockTimestamp = DateTime.now().millisecondsSinceEpoch;
      final mockResponse = MachineOrderResponse(
        message: 'Mock: Free order created successfully (100% discount)',
        data: MachineOrderData(
          id: 'mock-order-$mockTimestamp',
          customerId: request.customerId,
          customerPhone: request.customerPhone,
          storeMachineId: request.storeMachineId,
          programCode: request.programCode,
          programName: 'Mock Program',
          addTimeValue: request.addTimeValue,
          couponCustomerId: request.couponCustomerId,
          discountId: request.discountId,
          priceOriginal: '100.0',
          priceFinal: '0.0', // ← สำคัญที่สุด: ราคาสุดท้าย = 0
          discountAmount: '100.0',
          couponDiscount: '0',
          systemDiscount: '100.0',
          paymentMethod: request.paymentMethod,
          paymentStatus: 'paid', // ถือว่าจ่ายเงินแล้ว (เพราะไม่ต้องจ่าย)
          paymentRef: '20260307134508',
          machineStatus: 'pending',
          deviceLogId: 'mock-device-log-$mockTimestamp',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          responsePayload: null,
        ),
        redirectUrl: null,
        qrAndWechat: null,
      );

      debugPrint('🧪 [DEBUG] Mock Order Created: priceFinal = 0.0');
      return RepoResult.success(data: mockResponse);
    }
    // ========== End Mock Data ==========

    try {
      final response = await requireRemote.createMachineOrder(request);
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data);
    } on DioException catch (dioEx) {
      if (dioEx.response!.isDuplicated) {
        final serverMessage = MachineOrderResponse.fromJson(
          dioEx.response?.data,
        );
        return RepoResult.error(
          error: Unprocessable(serverMessage.message),
        );
      }
      return RepoResult.error(error: dioEx);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<BaseResponse>> submitMachineOrderReview(
    String orderId,
    MachineOrderReviewRequest request,
  ) async {
    try {
      final response = await requireRemote.submitMachineOrderReview(
        orderId,
        request,
      );
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<MachineStatusResponse>> checkMachineStatus(
    String qrCode,
  ) async {
    try {
      final response = await requireRemote.checkMachineStatus({
        'qr': qrCode,
      });
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
