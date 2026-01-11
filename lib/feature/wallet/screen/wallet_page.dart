import 'package:browny_applications_new/core/const/app_constants.dart';
import 'package:browny_applications_new/core/res/icons/assets.gen.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/widgets/app_container_radius.dart';
import 'package:browny_applications_new/core/widgets/app_overlays.dart';
import 'package:browny_applications_new/core/widgets/app_text.dart';
import 'package:browny_applications_new/feature/wallet/models/wallet_model.dart';
import 'package:browny_applications_new/feature/wallet/screen/show_qr_promptpay_page.dart';
import 'package:browny_applications_new/feature/wallet/viewmodel/wallet_viewmodel.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:browny_applications_new/res/strings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  static final pagePath = '/wallet';
  static final pageName = 'walletPage';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WalletViewModel(context: context),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        onVerticalDragEnd: (drag) =>
            FocusManager.instance.primaryFocus?.unfocus(),
        child: WalletWidget(),
      ),
    );
  }
}

class WalletWidget extends StatefulWidget {
  const WalletWidget({super.key});

  @override
  State<WalletWidget> createState() => _WalletWidgetState();
}

class _WalletWidgetState extends State<WalletWidget> {
  late WalletViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read();
    _viewModel.attachContext(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.fetchCredit();
    });
  }

  /// สร้าง Chip สำหรับเลือกจำนวนเงิน
  Widget _buildAmountChip({
    required int amount,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        _viewModel.selectAmount(amount);
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

  /// สร้าง IconButton.filled พร้อม style และ color filter สำหรับ SVG
  Widget _buildWalletIconButton({
    required SvgGenImage svgIcon,
    required VoidCallback onPressed,
  }) {
    return IconButton.filled(
      padding: EdgeInsets.all(10.w),
      onPressed: onPressed,
      icon: Builder(
        builder: (context) {
          return svgIcon.svg(
            colorFilter: ColorFilter.mode(
              AppColors.textBlack,
              BlendMode.srcIn,
            ),
          );
        },
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (state) {
            if (state.contains(WidgetState.pressed)) {
              return AppColors.paleOrange;
            }
            return AppColors.background;
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (state) {
            if (state.contains(WidgetState.pressed)) {
              return AppColors.cocoaBrown;
            }
            return AppColors.textBlack;
          },
        ),
        side: WidgetStateProperty.resolveWith(
          (state) {
            if (state.contains(WidgetState.pressed)) {
              return BorderSide(color: AppColors.paleOrange);
            }
            return BorderSide(color: AppColors.border);
          },
        ),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.walletBackground,
      // ปุ่มยืนยันการเติมเงิน
      bottomSheet: _buildSummitButton(context),
      // AppBa ปุ่มย้อนกลับและติดต่อขอช่วยเหลือ
      appBar: _buildAppBar(context),
      body: ValueListenableBuilder(
        valueListenable: _viewModel.walletNotifier,
        builder: (context, result, _) {
          if (result.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.walletBackground,
              ),
            );
          }

          return Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              // Background ที่เป็น Object
              _buildBackgroundObject(),

              // onBackground Container สีขาว
              _buildContentAndAmountBadge(context, result),

              // Card แสดงยอดเงิน และ ปุุ่ม เติมเงิน, แสกนจ่าย, ประวัติ
              _buildCard(context, result),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, UiResult<WalletModel> result) {
    return SizedBox(
      height: double.infinity,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDims.size_24.w,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppDims.vericalPadding_32,
              // Card Balance
              SizedBox(
                width: 305.w,
                height: 187.h,
                child: Card(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Container(
                      margin: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          AppText(
                            context.wording.balanceRemaining,
                            style: context.textTheme.bodySmall!.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          AppDims.vericalPadding_4,

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: null,
                                icon: Assets.svg.icObscureOn.svg(
                                  colorFilter: ColorFilter.mode(
                                    AppColors.transparent,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              ValueListenableBuilder(
                                valueListenable: _viewModel.isObscure,
                                builder: (context, isObscure, _) => AppText(
                                  isObscure
                                      ? '฿****'
                                      : '฿${result.requireData.creditBalance}',
                                  style: context.textTheme.headlineLarge!
                                      .copyWith(
                                        fontSize: AppDims.size_36.sp,
                                        color: AppColors.textBlack,
                                      ),
                                ),
                              ),
                              ValueListenableBuilder(
                                valueListenable: _viewModel.isObscure,
                                builder: (context, isObscure, _) => IconButton(
                                  onPressed: () => _viewModel.onObscureChange(),
                                  padding: EdgeInsets.zero,
                                  style: ButtonStyle(
                                    overlayColor: WidgetStatePropertyAll(
                                      AppColors.paleOrange,
                                    ),
                                  ),
                                  icon:
                                      (isObscure
                                              ? Assets.svg.icObscureOff
                                              : Assets.svg.icObscureOn)
                                          .svg(
                                            width: 20.w,
                                            height: 20.h,
                                          ),
                                ),
                              ),
                            ],
                          ),
                          AppDims.vericalPadding_16,

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  _buildWalletIconButton(
                                    // deposit
                                    svgIcon: Assets.svg.icDownload,
                                    onPressed: () {},
                                  ),
                                  AppText(
                                    context.wording.topup,
                                    style: context.textTheme.bodySmall!
                                        .copyWith(
                                          fontSize: AppDims.size_10.sp,
                                          color: AppColors.textBlack,
                                        ),
                                  ),
                                ],
                              ),

                              Column(
                                children: [
                                  _buildWalletIconButton(
                                    // scan
                                    svgIcon: Assets.svg.icScan,
                                    onPressed: () {},
                                  ),
                                  AppText(
                                    context.wording.scan,
                                    style: context.textTheme.bodySmall!
                                        .copyWith(
                                          fontSize: AppDims.size_10.sp,
                                          color: AppColors.textBlack,
                                        ),
                                  ),
                                ],
                              ),

                              Column(
                                children: [
                                  _buildWalletIconButton(
                                    // history
                                    svgIcon: Assets.svg.icHistory,
                                    onPressed: () {},
                                  ),
                                  AppText(
                                    context.wording.history,
                                    style: context.textTheme.bodySmall!
                                        .copyWith(
                                          fontSize: AppDims.size_10.sp,
                                          color: AppColors.textBlack,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Align _buildContentAndAmountBadge(
    BuildContext context,
    UiResult<WalletModel> result,
  ) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AppContainerRadius(
        height: 534.h,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDims.size_24.w,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppDims.vericalPadding_34,
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
                    controller: _viewModel.amountController,
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
                    validator: _viewModel.amountValidator,
                    onChanged: _viewModel.onTextAmountChange,
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

  Widget _buildBackgroundObject() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Assets.png.walletObjBg.image(
        fit: BoxFit.contain,
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.walletBackground,
      title: AppText(
        'TP+ Wallet',
        style: context.textTheme.titleLarge!.copyWith(color: AppColors.white),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Assets.svg.icHeadset.svg(),
        ),
      ],
    );
  }

  Widget _buildSummitButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppDims.size_24.w,
        right: AppDims.size_24.w,
        bottom: AppDims.size_24.w,
        top: AppDims.size_8.w,
      ),
      child: ElevatedButton(
        onPressed: () async {
          AppOverlays.showLoading(
            context,
            timeout: Duration(seconds: 10),
          );
          final result = await _viewModel.onSummitClick();
          AppOverlays.hideLoading();

          if (result.hashData && mounted) {
            // Navigate to QR page with ViewModel
            _viewModel.clearValue();
            context.pushNamed(
              ShowQRPromptpayPage.pageName,
              extra: _viewModel,
            );
          } else if (result.hasError && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: AppText(
                  'เกิดข้อผิดพลาดในการสร้าง QR Code',
                  style: context.textTheme.labelLarge!.copyWith(
                    color: AppColors.white,
                  ),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        style: context.appTheme.elevatedButtonTheme.style!.copyWith(
          backgroundColor: WidgetStatePropertyAll(
            AppColors.walletBackground,
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return AppColors.walletBackgroundHover.withValues(
                  alpha: 0.1,
                );
              }
              if (states.contains(WidgetState.pressed)) {
                return AppColors.walletBackgroundClicked.withValues(
                  alpha: 0.7,
                );
              }
              return null;
            },
          ),
        ),
        child: AppText(context.wording.topup),
      ),
    );
  }
}
