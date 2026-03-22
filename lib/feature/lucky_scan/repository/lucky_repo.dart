import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/data/remote/models/response/festive_history_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/festive_index_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/lucky_draw_response.dart';
import 'package:browny_applications_new/core/data/repo/app_repository.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';
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
      if (kDebugMode) {
        return RepoResult.success(
          data: FestiveHistoryResponse(
            data: List.generate(4, (i) {
              return FestiveHistoryData(
                type: (i % 2 == 0) ? 'won' : 'lose',
                title: ContentLocalizeData(
                  th: 'ลุ้นรับของรางวัลปีใหม่ครั้งที่ $i',
                  en: 'New Year Lucky Draw $i',
                  zh: '新年幸运抽 $i',
                ),
                eventId: i,
                festiveCode: 'FESTCODE$i',
                id: i,
                reward: FestiveHistoryReward(
                  id: i,
                  name: 'ซักอบ-ฟรีตลอดชาติ',
                ),
                createdAt: DateTime.now(),
              );
            }),
          ),
        );
      }
      final response = await requireRemote.fetchFestiveHistory({
        'customer_id': customerId,
      });
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data);
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
      final response = await requireRemote.postLuckyDraw({
        'customer_id': customerId,
        'qr_code': qrCode,
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
