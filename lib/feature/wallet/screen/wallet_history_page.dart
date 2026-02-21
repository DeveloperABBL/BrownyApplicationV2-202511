import 'package:browny_applications_new/core/data/remote/models/response/wallet_history_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/launch_helper.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/widgets/app_container_radius.dart';
import 'package:browny_applications_new/core/widgets/app_text.dart';
import 'package:browny_applications_new/feature/wallet/models/wallet_model.dart';
import 'package:browny_applications_new/feature/wallet/screen/wallet_history_detail_page.dart';
import 'package:browny_applications_new/feature/wallet/viewmodel/wallet_viewmodel.dart';
import 'package:browny_applications_new/feature/wallet/widgets/wallet_history_item_widget.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:browny_applications_new/res/strings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class WalletHistoryPage extends StatelessWidget {
  const WalletHistoryPage({
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
              FutureBuilder(
                future: viewModel.fetchTermsLink(),
                builder: (context, asyncSnapshot) {
                  return TextButton(
                    onPressed: !asyncSnapshot.hasData
                        ? null
                        : () async {
                            final link = asyncSnapshot.data?.data?.problemLink;
                            await LaunchHelper.openUrlInBrowser(link.orEmpty);
                          },
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
                  );
                },
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
                    onTap: () {
                      final data = viewModel.walletHistoryNotifier.value.data;
                      if (data != null) {
                        showDialog(
                          useSafeArea: false,
                          context: context,
                          builder: (context) => Dialog.fullscreen(
                            child: WalletHistoryDetailPage(
                              historyGroups: data.groupByMonth(),
                            ),
                          ),
                        );
                      }
                    },
                    child: AppText(
                      // ดูทั้งหมด
                      context.wording.seeAll,
                      style: context.textTheme.labelLarge!.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ),
                ],
              ),

              AppDims.vericalPadding_16,

              // ListView with Expanded
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: viewModel.walletHistoryNotifier,
                  builder: (context, result, child) {
                    if (result.isLoading) {
                      Future.microtask(viewModel.fetchWalletHistory);
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.walletBackground,
                        ),
                      );
                    }
                    if (result.isEmpty ||
                        result.data == null ||
                        result.data!.history.orEmpty.isEmpty) {
                      return Center(
                        child: AppText(
                          context.wording.noTransactionHistory,
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }

                    final histories = result.data!.history!;
                    return ListView.builder(
                      itemCount: histories.take(6).length,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(bottom: AppDims.size_48.h),
                      itemBuilder: (context, index) {
                        final history = histories[index];
                        return _buildSingleItem(
                          context,
                          title: history.getDescriptionDisplay(
                            context.languageCode,
                          ),
                          date:
                              history.dateTime?.formatDateDDMMMMyyyyHHmmMinText(
                                context.languageCode,
                                pattern: 'dd MMM yyyy - HH:mm:ss',
                              ) ??
                              '',
                          amount: history.getAmountDisplay,
                          isIncome: !history.isPurchase && !history.isRefund,
                        );
                      },
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
    return WalletHistoryItemWidget(
      title: title,
      date: date,
      amount: amount,
      isIncome: isIncome,
    );
  }
}
