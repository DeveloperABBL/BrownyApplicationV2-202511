import 'dart:convert';

import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/data/remote/models/response/festive_history_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/festive_index_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/lucky_draw_response.dart';
import 'package:browny_applications_new/core/data/repo/app_repository.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';
import 'package:browny_applications_new/feature/authentication/error/authen_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

mixin LuckyDataSourceMixin {
  /// API fetch รายการ Festive Event (Lucky Scan campaigns)
  Future<RepoResult<FestiveIndexResponse>> fetchFestiveIndex();

  /// API fetch ประวัติการร่วมกิจกรรม Lucky Scan ของลูกค้า
  Future<RepoResult<FestiveHistoryResponse>> fetchFestiveHistory({
    required String customerId,
  });

  /// API สแกน QR Lucky Draw
  Future<RepoResult<LuckyDrawResponse>> postLuckyDraw({
    required String customerId,
    required String qrCode,
  });
}

class LuckyRepo extends AppRepository with LuckyDataSourceMixin {
  @override
  Future<RepoResult<FestiveIndexResponse>> fetchFestiveIndex() async {
    try {
      final response = await requireRemote.fetchFestiveIndex();
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<FestiveHistoryResponse>> fetchFestiveHistory({
    required String customerId,
  }) async {
    try {
      // if (kDebugMode) {
      //   return RepoResult.success(
      //     data: FestiveHistoryResponse(
      //       data: List.generate(4, (i) {
      //         return FestiveHistoryData(
      //           type: (i % 2 == 0) ? 'won' : 'lose',
      //           title: ContentLocalizeData(
      //             th: 'ลุ้นรับของรางวัลปีใหม่ครั้งที่ $i',
      //             en: 'New Year Lucky Draw $i',
      //             zh: '新年幸运抽 $i',
      //           ),
      //           eventId: i,
      //           festiveCode: 'FESTCODE$i',
      //           id: i,
      //           reward: FestiveHistoryReward(
      //             id: i,
      //             name: 'ซักอบ-ฟรีตลอดชาติ',
      //           ),
      //           createdAt: DateTime.now(),
      //         );
      //       }),
      //     ),
      //   );
      // }
      final response = await requireRemote.fetchFestiveHistory({
        'customer_id': customerId,
      });
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data);
    } on DioException catch (dioEx) {
      if (dioEx.response?.isUnprocessable == true) {
        return RepoResult.empty();
      }
      return RepoResult.error(error: dioEx);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<LuckyDrawResponse>> postLuckyDraw({
    required String customerId,
    required String qrCode,
  }) async {
    try {
      //       if (kDebugMode) {
      //         // won
      //         return RepoResult.success(
      //           data: LuckyDrawResponse.fromJson(
      //             jsonDecode('''
      // {
      //     "type": "won",
      //     "step": "5",
      //     "reward": {
      //         "id": 13,
      //         "type": "discount",
      //         "name": "222"
      //     },
      //     "translations": {
      //         "th": {
      //             "banner": "https:\/\/dev.abgroup.co.th\/storage\/festive\/images\/xcZEpjmd1EJc9eNuxM9hoc6UIlqOgwwDq5OkgwuX.png",
      //             "title": "ยินดีด้วยคุณได้รับคูปอง",
      //             "message": "<ul><li>เป็นของขวัญพิเศษ และโปรโมชั่นเฉพาะสมาชิกในเดือนเกิด<\/li><li>เพื่อความถูกต้องของสิทธิประโยชน์ วันเกิดจะไม่สามารถแก้ไขได้เอง หากต้องการเปลี่ยน โปรดติดต่อแอดมินพร้อมแนบรูปบัตรประชาชน<\/li><li>หากใช้สิทธิ์ครบวันเกิดไปแล้ว จะไม่สามารถแก้ไขวันเกิดได้<\/li><\/ul>"
      //         },
      //         "en": {
      //             "banner": "https:\/\/dev.abgroup.co.th\/storage\/festive\/images\/HG8cnAOkzcHr7r8XolaCfGBfVp2fEo5unl4ujaIM.png",
      //             "title": "Congratulations! You've received a coupon",
      //             "message": "<ul><li>This coupon is a special birthday privilege and exclusive for members during their birthday month<\/li><li>Please ensure your personal information and date of birth are correct. If changes are required, please contact staff and present your ID card<\/li><li>Once the birthday privilege has been redeemed, the date of birth cannot be modified<\/li><\/ul>"
      //         },
      //         "zh": {
      //             "banner": "https:\/\/dev.abgroup.co.th\/storage\/festive\/images\/NafnXKNDcUjjW8CGMJughbr9ri1ITVO3r2AXPIRG.png",
      //             "title": "恭喜您获得优惠券",
      //             "message": "<ul><li>此优惠券为生日专属特权，仅限会员在生日当月使用<\/li><li>请确保您的个人信息及出生日期正确。如需修改，请联系工作人员并出示身份证件<\/li><li>一旦生日特权已被使用，将无法更改出生日期<\/li><\/ul><p>&nbsp;<\/p><p><strong>Banner:<\/strong><\/p>"
      //         }
      //     }
      // }
      // '''),
      //           ),
      //         );
      //         // lose
      //         //   return RepoResult.success(
      //         //     data: LuckyDrawResponse.fromJson(
      //         //       jsonDecode('''
      //         //       {
      //         //     "type": "lose",
      //         //     "step": "4",
      //         //     "reward": null,
      //         //     "translations": {
      //         //         "th": {
      //         //             "banner": "https:\/\/dev.abgroup.co.th\/storage\/festive\/images\/1mmb3bd6au8ZjfBj879wJe4udhD6MpWlTn9yQNSP.png",
      //         //             "title": "ยังไม่ได้รับรางวัลในรอบนี้",
      //         //             "message": "<p>ขอขอบคุณที่ร่วมกิจกรรม Lucky Scan<br>สามารถกลับมาลุ้นคูปองและรางวัลพิเศษได้ในครั้งถัดไป<\/p>"
      //         //         },
      //         //         "en": {
      //         //             "banner": "https:\/\/dev.abgroup.co.th\/storage\/festive\/images\/1mmb3bd6au8ZjfBj879wJe4udhD6MpWlTn9yQNSP.png",
      //         //             "title": "No reward received this time",
      //         //             "message": "<p>Thank you for participating in the Lucky Scan activity.<br>You can try again for a chance to win special rewards next time.<\/p>"
      //         //         },
      //         //         "zh": {
      //         //             "banner": "https:\/\/dev.abgroup.co.th\/storage\/festive\/images\/wD49HksonUC0M1nvA3Xqu4A9dzF0o53sHjvvp9eO.png",
      //         //             "title": "本次未获得奖励",
      //         //             "message": "<p>感谢您参与 Lucky Scan 活动。<br>欢迎下次再来，有机会赢取特别奖励。<\/p>"
      //         //         }
      //         //     }
      //         // }
      //         //       '''),
      //         //     ),
      //         //   );
      //       }
      final response = await requireRemote.postLuckyDraw({
        'customer_id': customerId,
        'qr_code': qrCode,
      });
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data);
    } on DioException catch (dioEx) {
      // เกิด 500, 404 จะออกไปแสดง error message ว่า QR ไม่ถูกต้อง
      if (dioEx.response?.inInternalError == true ||
          dioEx.response?.isNotFound == true) {
        return RepoResult.error(error: Unprocessable());
      }
      try {
        // error อื่นๆ จะลองเข้า model ก่อน ถ้าเข้าได้จะ handle จาก
        // LuckyDrawResponse.type
        return RepoResult.success(
          data: LuckyDrawResponse.fromJson(dioEx.response?.data),
        );
      } catch (e) {
        // error อื่นๆ จาก server
        return RepoResult.error(error: Exception(e.toString()));
      }
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
