import 'package:browny_applications_new/core/data/remote/models/response/coin_claim_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
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
    required this.locale,
    required this.streaksDisplay,
  });

  final List<StreakModelItem> streaksDisplay;

  factory CoinDataModel.fromCoinClaimData(
    String locale,
    CoinClaimData data,
  ) {
    StreakModelItem itemBuild(StreakItem item) {
      bool isToday = false;
      String dayDisplay = '-';
      // ถ้า streakDay คือ 0 หมายความว่า ยังไม่เคยรับ Coin มาก่อน
      if ((data.streakDay ?? 0) == 0) {
        DateTime dateFromDay = DateTime.now();
        // ถ้า day == 1 จะ assign ให้เป็นวันนี้ทันที
        if ((item.day ?? 0) == 1) {
          isToday = true;
          dateFromDay = DateTime.now();
        } else {
          dateFromDay = dateFromDay.add(Duration(days: (item.day! - 1)));
        }

        dayDisplay = dateFromDay
            .formatDateLocale(locale, pattern: 'dd MMM')
            .replaceAll('.', '');
      } else {
        try {
          // ถ้าตก else แสดงว่ามีการ claimed ไปแล้ว จะ getFirst มาเพื่อหาวันปัจจุบัน
          final firstDayClaimed =
              DateFormat(
                'yyyy-MM-dd',
                locale,
              ).parse(
                data.streaks!.first.claimedAt.orEmpty.ifEmpty(
                  data.lastClaimedDate.orEmpty,
                ),
              );

          // นับจำนวนวันที่ผ่านไปตั้งแต่วันแรกที่ claimed
          final today = DateTime.now();
          final daysPassed = today.difference(firstDayClaimed).inDays;

          // เช็คว่า daysPassed เกิน maxDay หรือไม่ (streak ขาดไปแล้ว)
          if (daysPassed >= (data.maxDay ?? 7)) {
            // Reset streak: day 1 = today
            isToday = item.day == 1;
            dayDisplay = DateTime.now()
                .add(Duration(days: (item.day ?? 1) - 1))
                .formatDateLocale(locale, pattern: 'dd MMM')
                .replaceAll('.', '');
          } else {
            // วันปัจจุบันใน streak คือ daysPassed + 1 (เพราะ day 1 = วันแรกที่รับ)
            final currentStreakDay = daysPassed + 1;
            isToday = item.day == currentStreakDay;

            // คำนวณวันที่แสดงสำหรับแต่ละ day (day 1 = firstDayClaimed, day 2 = +1 วัน, etc.)
            dayDisplay = firstDayClaimed
                .add(Duration(days: (item.day ?? 1) - 1))
                .formatDateLocale(locale, pattern: 'dd MMM')
                .replaceAll('.', '');
          }
        } catch (e) {
          print(e);
        }
      }

      return StreakModelItem(
        isToday: isToday,
        amount: (item.amount ?? 0.0).toString(),
        highlight: item.highlight ?? false,
        claimedAtDisplay: item.claimedAt.orEmpty,
        day: item.day.toString(),
        dayDisplay: dayDisplay,
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
      streaksDisplay: data.streaks?.map((e) => itemBuild(e)).toList() ?? [],
      // url banner ยังไม่แน่ใจจุดที่ใช้แสดง
      banners: data.banners,
    );
  }

  final String locale;

  String get bannerDisplay => super.banners?.getByLocaleCode(locale) ?? '';
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
