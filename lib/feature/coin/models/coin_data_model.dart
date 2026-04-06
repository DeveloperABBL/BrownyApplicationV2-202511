import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coin_claim_response.dart';
import 'package:intl/intl.dart';

// {
//     "status": true,
//     "code": 200,
//     "message": "ok",
//     "data": {
//         "customer_id": "019b683f-9ea2-7242-82e1-6b27d2cf721d",
//         "streak_day": 0, // คือ index ใน streaks
//         "last_claimed_date": null, // รับล่าสุด
//         "claimable_today": true, // วันนี้รับได้หรือไม่
//         "next_day": 1, // วันที่ถัดไป
//         "target_day": 1, //
//         "today_amount": 0.5,
//         "max_day": 7,
//         "streaks": [
//             {
//                 "day": 1,
//                 "amount": 0.5,
//                 "highlight": false
//             },
//             {
//                 "day": 2,
//                 "amount": 0.5,
//                 "highlight": false
//             },
//             {
//                 "day": 3,
//                 "amount": 0.5,
//                 "highlight": false
//             },
//             {
//                 "day": 4,
//                 "amount": 0.75,
//                 "highlight": true
//             },
//             {
//                 "day": 5,
//                 "amount": 0.5,
//                 "highlight": false
//             },
//             {
//                 "day": 6,
//                 "amount": 0.5,
//                 "highlight": false
//             },
//             {
//                 "day": 7,
//                 "amount": 0.75,
//                 "highlight": true
//             }
//         ],
//         "banners": {
//             "th": "storage/uploads/coin_banner/coin_banner_th_bcee999c-4054-4671-9e23-506ac63a18e0.png",
//             "en": null,
//             "zh": null
//         }
//     }
// }

// return response()->json([
//                 'status'  => true,
//                 'code'    => 200,
//                 'message' => 'ok',
//                 'data'    => [
//                     'customer_id'        => $user->id,
//                     'streak_day'         => (int) $user->streak_day,
//                     'last_claimed_date'  => optional($user->last_coin_claimed_at)?->toDateString(),
//                     'claimable_today'    => !$claimedToday,     // true = ยังเคลมได้วันนี้
//                     'next_day'           => (int) $nextDay,
//                     'target_day'         => (int) $targetDay,  // หลัง cap ด้วย maxDay
//                     'today_amount'       => (float) $todayAmount,
//                     'max_day'            => (int) $maxDay,
//                     // ตารางสเต็ปทั้งหมด (ไว้เรนเดอร์ UI)
//                     'streaks' => $streaks->map(fn($s) => [
//                         'day'       => (int) $s->day,
//                         'amount'    => (float) $s->amount,
//                         'highlight' => (bool) $s->highlight,
//                         'claimed_at' => $claimsByDay->get($s->day) ?? null,
//                     ])->values(),
//                     // banner per locale
//                     'banners' => $banners,
//                 ],
//             ], 200);
class CoinDataModel extends CoinClaimData {
  CoinDataModel({
    super.customerId,
    super.streakDay,
    super.lastClaimedDate,
    super.claimableToday,
    super.nextDay,
    super.targetDay,
    super.todayAmount,
    super.maxDay,
    super.streaks,
    super.banners,
    super.todayHighlight,
    super.todayCalendarDate,
    super.defaultDailyCoin,
    super.popupImages,
    super.popupDetails,
    super.coinSettings,
    required this.locale,
    required this.streaksDisplay,
  });

  final List<StreakModelItem> streaksDisplay;

  factory CoinDataModel.fromCoinClaimData(
    String locale,
    CoinClaimData data,
  ) {
    DateTime? parseDate(String? value) {
      if (value.orEmpty.isEmpty) return null;
      try {
        return DateFormat('yyyy-MM-dd', locale).parse(value!);
      } catch (_) {
        return null;
      }
    }

    StreakModelItem itemBuild(StreakItem item, int index) {
      final fallbackDate = DateTime.now().add(Duration(days: index));
      final streakDate = parseDate(item.calendarDate) ?? parseDate(item.day);
      final displayDate = (streakDate ?? fallbackDate)
          .formatDateLocale(locale, pattern: 'dd MMM')
          .replaceAll('.', '');

      // API ใหม่ส่ง today_calendar_date มาให้ จึงใช้ค่านี้เป็นหลัก
      final todayDateString = data.todayCalendarDate.orEmpty;
      final isTodayByApiDate =
          todayDateString.isNotEmpty &&
          (item.calendarDate == todayDateString || item.day == todayDateString);

      // fallback เดิมไว้รองรับ API เก่าที่ยังส่ง day เป็นลำดับวัน
      // ใช้เมื่อไม่มี today_calendar_date เท่านั้น — ถ้ามีแล้วต้องอิงวันที่จริงจาก API ไม่ให้ index 0 เป็นวันนี้ซ้ำ
      bool isTodayByLegacyRule = false;
      if (todayDateString.isEmpty &&
          !isTodayByApiDate &&
          (data.streakDay ?? 0) == 0) {
        isTodayByLegacyRule = index == 0;
      }

      return StreakModelItem(
        isToday: isTodayByApiDate || isTodayByLegacyRule,
        amount: (item.amount ?? 0.0).toString(),
        highlight: item.highlight ?? false,
        claimedAtDisplay: item.claimedAt.orEmpty,
        day: item.day.orEmpty.ifEmpty((index + 1).toString()),
        dayDisplay: displayDate,
      );
    }

    return CoinDataModel(
      // เก็บ Locale ภาษา ณ ปัจจุบัน
      locale: locale,
      // รหัส uuid user
      customerId: data.customerId,
      // index ใน streaks cliam coin ล่าสุด
      streakDay: data.streakDay,
      // datetime claim coin ล่าสุด
      lastClaimedDate: data.lastClaimedDate,
      // flag claim ณ วันนี้ได้หรือไม่
      claimableToday: data.claimableToday,
      // ยังไม่แน่ใจหน้าที่
      nextDay: data.nextDay,
      // ยังไม่แน่ใจหน้าที่
      targetDay: data.targetDay,
      // จำนวน coin ที่จะได้รับในวัน
      todayAmount: data.todayAmount,
      // จำนวนวัน coin ที่ claim ได้สูงสุด
      maxDay: data.maxDay,
      // raw list streaks
      streaks: data.streaks,
      // streak ที่ mapping ข้อมูลสำหรับ display แล้ว
      streaksDisplay:
          data.streaks?.asMap().entries.map((e) {
            return itemBuild(e.value, e.key);
          }).toList() ??
          [],
      // url banner ยังไม่แน่ใจจุดที่ใช้แสดง
      banners: data.banners,
      todayHighlight: data.todayHighlight,
      todayCalendarDate: data.todayCalendarDate,
      defaultDailyCoin: data.defaultDailyCoin,
      popupImages: data.popupImages,
      popupDetails: data.popupDetails,
      coinSettings: data.coinSettings,
    );
  }

  final String locale;

  String get bannerDisplay => super.banners?.getByLocaleCode(locale) ?? '';

  /// รายละเอียดเงื่อนไข popup (HTML) ตามภาษา จาก API `popup_details`
  String get popupDetailsDisplay =>
      super.popupDetails?.getByLocaleCode(locale) ?? '';
}

class StreakModelItem {
  StreakModelItem({
    required this.isToday,
    required this.day,
    required this.dayDisplay,
    required this.amount,
    required this.highlight,
    required this.claimedAtDisplay,
  });

  final bool isToday;
  final String day;
  final String dayDisplay;
  final String amount;
  final bool highlight;
  final String claimedAtDisplay;
}
