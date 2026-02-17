import 'package:browny_applications_new/core/const/app_constants.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/widgets/app_text.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:browny_applications_new/res/icons/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WalletHistoryItemWidget extends StatelessWidget {
  const WalletHistoryItemWidget({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.isIncome, // true = เงินเข้า, false = เงินออก
  });

  final String title;
  final String date;
  final String amount;
  final bool isIncome; // true = เงินเข้า, false = เงินออก

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppDims.size_12.h,
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
          // Icon (ลูกศรขึ้น/ลง)
          Container(
            width: 44.w,
            height: 44.h,
            padding: EdgeInsets.all(AppDims.size_8.w),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: isIncome
                ? Assets.svg.icDownload.svg(
                    width: 24.w,
                    height: 24.h,
                  )
                : Assets.svg.icUpload.svg(
                    width: 24.w,
                    height: 24.h,
                  ),
          ),
          SizedBox(width: 12.w),

          // ข้อมูลรายการ (ชื่อ)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  style: context.textTheme.labelMedium!.copyWith(
                    color: AppColors.textBlack,
                  ),
                ),
                // ​Widget หลอกให้กินพื้นที่เท่ากัน
                AppText(
                  '',
                  style: context.textTheme.labelMedium!.copyWith(
                    color: AppColors.textBlack,
                  ),
                ),
              ],
            ),
          ),

          // ข้อมูลรายการ (จำนวนเงิน + วันที่)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // จำนวนเงิน
              AppText(
                formatCurrency(
                  string: amount,
                  leadingSign: isIncome ? '+฿' : '-฿',
                ),
                style: context.textTheme.headlineSmall!.copyWith(
                  fontSize: 12.sp,
                  color: isIncome ? AppColors.cocoaBrown : AppColors.textBlack,
                ),
              ),
              SizedBox(height: 4.h),
              // วันที่
              AppText(
                date,
                style: context.textTheme.labelSmall!.copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
