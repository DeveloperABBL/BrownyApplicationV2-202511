import 'dart:convert';

import 'package:browny_applications_new/core/data/remote/models/response/order_history_response.dart';
import 'package:browny_applications_new/core/data/repo/app_repository.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

mixin HistoryTransactionDataSource {
  /// API fetch ประวัติการสั่งซื้อของลูกค้า
  Future<RepoResult<OrderHistoryResponse>> fetchOrderHistory({
    required String customerId,
    required int page,
    String? startDate,
    String? endDate,
  });
}

class HistoryTransactionRepo extends AppRepository
    with HistoryTransactionDataSource {
  @override
  Future<RepoResult<OrderHistoryResponse>> fetchOrderHistory({
    required String customerId,
    required int page,
    String? startDate,
    String? endDate,
  }) async {
    try {
      // if (kDebugMode) {
      //   return RepoResult.success(
      //     data: OrderHistoryResponse.fromJson(
      //       jsonDecode('''
      // {
      //   "data": [
      //     {
      //       "type": "machine_order",
      //       "order_id": "019de281-d7a8-71aa-98fd-f9549671ad84",
      //       "receipt_no": "BNP20260501-144733411282",
      //       "receipt_at": "2026-05-01 14:47:33",
      //       "store": {
      //         "id": 127,
      //         "name": {
      //           "th": "สามแยกวาปี อ.เมือง จ.ร้อยเอ็ด",
      //           "en": "สามแยกวาปี อ.เมือง จ.ร้อยเอ็ด",
      //           "zh": "สามแยกวาปี อ.เมือง จ.ร้อยเอ็ด"
      //         }
      //       },
      //       "machine_no": 1,
      //       "image": "https://dev.abgroup.co.th/storage/galleries/s3nbAR7QLSPpZ9aSTWSyGV9nXQZy6JhsPgVvaJKL.png",
      //       "machine_type": {
      //         "th": "เครื่องอบ 4 - 16.00 กก.",
      //         "en": "Dryer 4 - 16.00 kg",
      //         "zh": "烘干机 4 - 16.00 公斤"
      //       },
      //       "luck_no": "59",
      //       "program": {
      //         "code": "P1",
      //         "name": {
      //           "th": "น้ำเย็น",
      //           "en": "Cold Water",
      //           "zh": "冷水"
      //         }
      //       },
      //       "payment_method": {
      //         "key": "tp_wallet",
      //         "name": {
      //           "th": "TP Wallet",
      //           "en": "TP Wallet",
      //           "zh": "TP 钱包"
      //         },
      //         "image": "https://gateway2026.abgroup.co.th/assets/images/customerNotificationIconPaymnet/tp_wallet.png"
      //       },
      //       "amount": "40.00"
      //     },
      //     {
      //       "type": "coupon_package_order",
      //       "order_id": "5159",
      //       "receipt_no": "BNP20260416-164423401610",
      //       "receipt_at": "2026-04-16 16:44:23",
      //       "package_name": {
      //         "th": "Browny Summer Smile | Bubble Pack อบ 16 kg. 2 ใบ พิเศษ 90 บาท ปกติ 100 บาท",
      //         "en": "Browny Summer Smile | Bubble Pack 2 Dryer Coupons (16 kg) for only 90 THB (Regular Price: 100 THB)",
      //         "zh": "Browny Summer Smile | Bubble Pack 2 Dryer Coupons (16 kg) for only 90 THB (Regular Price: 100 THB)"
      //       },
      //       "payment_method": {
      //         "key": "tp_wallet",
      //         "name": {
      //           "th": "TP Wallet",
      //           "en": "TP Wallet",
      //           "zh": "TP 钱包"
      //         },
      //         "image": "https://gateway2026.abgroup.co.th/assets/images/customerNotificationIconPaymnet/tp_wallet.png"
      //       }
      //     },
      //     {
      //       "type": "coupon_package_order",
      //       "order_id": "5158",
      //       "receipt_no": "BNP20260416-164100094348",
      //       "receipt_at": "2026-04-16 16:41:00",
      //       "package_name": {
      //         "th": "Browny Summer Smile | Bubble Pack อบ 16 kg. 2 ใบ พิเศษ 90 บาท ปกติ 100 บาท",
      //         "en": "Browny Summer Smile | Bubble Pack 2 Dryer Coupons (16 kg) for only 90 THB (Regular Price: 100 THB)",
      //         "zh": "Browny Summer Smile | Bubble Pack 2 Dryer Coupons (16 kg) for only 90 THB (Regular Price: 100 THB)"
      //       },
      //       "payment_method": {
      //         "key": "tp_wallet",
      //         "name": {
      //           "th": "TP Wallet",
      //           "en": "TP Wallet",
      //           "zh": "TP 钱包"
      //         },
      //         "image": "https://gateway2026.abgroup.co.th/assets/images/customerNotificationIconPaymnet/tp_wallet.png"
      //       }
      //     }
      //   ],
      //   "meta": {
      //     "current_page": 1,
      //     "per_page": 20,
      //     "total": 3,
      //     "last_page": 1
      //   }
      // }
      // '''),
      //     ),
      //   );
      // }
      final response = await requireRemote.fetchOrderHistory(
        kDebugMode ? '2c0e1857-e4fa-4df4-8811-ea8c010beea4' : customerId,
        page,
        startDate,
        endDate,
      );

      if (!response.isSuccessful) {
        return RepoResult.empty();
      }

      return RepoResult.success(data: response.data);
    } on DioException catch (dioEx) {
      if (dioEx.response?.isNotFound == true) {
        return RepoResult.empty();
      }
      return RepoResult.error(error: dioEx);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
