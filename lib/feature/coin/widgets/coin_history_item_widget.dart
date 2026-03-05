import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/widgets/app_text.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:browny_applications_new/res/icons/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoinHistoryItemWidget extends StatelessWidget {
  const CoinHistoryItemWidget({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.isExpired, // true = ใช้หรือไม่ได้, false = หมดอายุ
    required this.isPlus, // true = เป็นค่าบวกแสดงสีเขียว, เป็นค่าลบ แสดงสีแดง
  });

  final String title;
  final String date;
  final String amount;
  final bool isExpired; // true = ใช้หรือไม่ได้, false = หมดอายุ
  final bool isPlus; // true = เป็นค่าบวกแสดงสีเขียว, เป็นค่าลบ แสดงสีแดง

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppDims.size_12.h,
        bottom: AppDims.size_12.h,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Icon Coin
          Container(
            foregroundDecoration: isExpired
                ? BoxDecoration(
                    color: Colors.grey,
                    backgroundBlendMode: BlendMode.saturation,
                  )
                : null,
            child: Assets.png.brownyCoin2.image(
              width: 44.w,
            ),
          ),
          // isExpired
          //     ? Assets.png.brownyCoinInactive.image(
          //         width: 44.w,
          //       )
          //     : Assets.png.brownyCoin.image(
          //         width: 44.w,
          //       ),
          AppDims.horizonPadding_8,

          // ข้อมูลรายการ (ชื่อ)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    AppText(
                      title,
                      style: context.textTheme.labelMedium!.copyWith(
                        color: AppColors.textBlack,
                      ),
                    ),
                    // จำนวนเงิน
                    AppText(
                      amount,
                      style: context.textTheme.headlineSmall!.copyWith(
                        fontSize: 12.sp,
                        color: isExpired
                            ? AppColors.gray600
                            : (isPlus ? AppColors.primary : AppColors.error),
                      ),
                    ),
                  ],
                ),
                AppDims.vericalPadding_8,
                // วันที่
                AppText(
                  date,
                  style: context.textTheme.labelSmall!.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
