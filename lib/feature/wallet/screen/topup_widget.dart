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
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TopupWidget extends StatelessWidget {
  const TopupWidget({
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
      child: _TopupContent(
        viewModel: viewModel,
        result: result,
      ),
    );
  }
}

class _TopupContent extends StatelessWidget {
  const _TopupContent({
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

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextFormField(
                    controller: viewModel.amountController,
                    title: AppText(
                      context.wording.specifyAmount,
                      style: context.textTheme.titleMedium!.copyWith(
                        color: AppColors.textBlack,
                      ),
                    ),
                    style: context.inputTextStyle.copyWith(
                      color: AppColors.textBlack,
                    ),
                    cursorColor: AppColors.walletBackground,
                    decoration: InputDecoration(
                      hintText: formatCurrency(value: 0.0),
                      hintStyle: context.inputTextStyle.copyWith(
                        color: AppColors.gray500,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: const BorderSide(
                          color: AppColors.cocoaBrown,
                          width: 1.5,
                        ),
                      ),
                      prefixIcon: SizedBox.shrink(),
                      errorStyle: GoogleFonts.prompt(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: viewModel.amountValidator,
                    onChanged: viewModel.onTextAmountChange,
                  ),

                  AppDims.vericalPadding_16,
                  AppText(
                    context.wording.minimumTopUp,
                    style: context.textTheme.bodySmall!.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                  AppDims.vericalPadding_8,
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 8.w,
                      children: result.data!.amountBadge
                          .mapIndex(
                            (index, amount) => _buildAmountChip(
                              context,
                              amount: amount,
                              isSelected: result.data!.selectedAmount == index,
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  AppDims.vericalPadding_8,
                  AppText(
                    context.wording.payWith,
                    style: context.textTheme.labelLarge!.copyWith(
                      color: AppColors.textBlack,
                    ),
                  ),
                  AppDims.vericalPadding_4,

                  // Container Promptpay
                  Container(
                    padding: EdgeInsets.all(AppDims.size_14.w),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.cocoaBrown,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Assets.svg.icPromptpay.svg(),
                        AppDims.vericalPadding_4,
                        AppText(
                          context.wording.promptPayQRCode,
                          style: context.textTheme.labelMedium!.copyWith(
                            color: AppColors.textBlack,
                          ),
                        ),
                        AppDims.vericalPadding_16,
                        Assets.png.promptpayBadge.image(
                          width: 104.w,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// สร้าง Chip สำหรับเลือกจำนวนเงิน
  Widget _buildAmountChip(
    BuildContext context, {
    required int amount,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        viewModel.selectAmount(amount);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDims.size_13.w,
          vertical: AppDims.size_8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.paleOrange : AppColors.background,
          border: Border.all(
            color: isSelected ? AppColors.cocoaBrown : AppColors.border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: AppText(
          formatCurrency(value: amount, decimal: false),
          style: context.textTheme.labelLarge!.copyWith(
            color: isSelected ? AppColors.cocoaBrown : AppColors.textBlack,
          ),
        ),
      ),
    );
  }
}
