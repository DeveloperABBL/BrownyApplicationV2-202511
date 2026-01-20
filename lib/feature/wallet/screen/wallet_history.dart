import 'package:browny_applications_new/core/const/app_constants.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/widgets/app_container_radius.dart';
import 'package:browny_applications_new/core/widgets/app_text.dart';
import 'package:browny_applications_new/feature/wallet/models/wallet_model.dart';
import 'package:browny_applications_new/feature/wallet/viewmodel/wallet_viewmodel.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:browny_applications_new/res/icons/assets.gen.dart';
import 'package:browny_applications_new/res/strings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class WalletHistory extends StatelessWidget {
  const WalletHistory({
    super.key,
    required this.viewModel,
    required this.result,
  });

  final WalletViewModel viewModel;
  final UiResult<WalletModel> result;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: _WallHistoryContent(
        viewModel: viewModel,
        result: result,
      ),
    );
  }
}

class _WallHistoryContent extends StatelessWidget {
  const _WallHistoryContent({
    required this.viewModel,
    required this.result,
  });

  final WalletViewModel viewModel;
  final UiResult<WalletModel> result;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AppContainerRadius(
        height: 534.h,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppDims.size_40.h,
            horizontal: AppDims.size_24.w,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text แจ้งปัญหา
              TextButton(
                onPressed: () {},
                style: context.appTheme.textButtonTheme.style!.copyWith(
                  overlayColor: WidgetStatePropertyAll(
                    AppColors.transparent,
                  ),
                ),
                child: AppText(
                  context.wording.reportIssueOrRefundMessage,
                  style: context.textTheme.titleSmall!.copyWith(
                    fontSize: AppDims.size_10.sp,
                    color: AppColors.cocoaBrown,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.cocoaBrown,
                  ),
                ),
              ),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    'ประวัติการทำรายการ',
                    style: context.textTheme.titleMedium!.copyWith(
                      color: AppColors.textBlack,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: AppText(
                      context.wording.seeAll,
                      style: context.textTheme.labelLarge!.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // ListView with Expanded
              Expanded(
                child: ListView.builder(
                  itemCount: 10,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: AppDims.size_48.h),
                  itemBuilder: (context, index) {
                    return _buildSingleItem(
                      context,
                      title: ((index % 2) == 0)
                          ? context.wording.topup
                          : 'โอนเงิน/ชำระเงิน',
                      date: DateTime.now().formatDateDDMMMMyyyyHHmmMinText(
                        Localizations.localeOf(context).languageCode,
                        pattern: 'dd MMM yyyy - HH:mm',
                      ),
                      amount: '100',
                      isIncome: (index % 2) == 0,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// สร้าง Single Item สำหรับแสดงประวัติรายการ
  Widget _buildSingleItem(
    BuildContext context, {
    required String title,
    required String date,
    required String amount,
    required bool isIncome, // true = เงินเข้า, false = เงินออก
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppDims.size_16.h,
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
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
