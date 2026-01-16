import 'package:browny_applications_new/core/const/app_constants.dart';
import 'package:browny_applications_new/core/providers/customer_provider.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/widgets/app_overlays.dart';
import 'package:browny_applications_new/core/widgets/app_text.dart';
import 'package:browny_applications_new/feature/coin/models/coin_data_model.dart';
import 'package:browny_applications_new/feature/coin/repository/coin_claim_repo.dart';
import 'package:browny_applications_new/feature/coin/viewmodel/coin_viewmodel.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:browny_applications_new/res/icons/assets.gen.dart';
import 'package:browny_applications_new/res/strings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CoinPage extends StatelessWidget {
  const CoinPage({super.key});

  static final pagePath = '/coin_page';
  static final pageName = 'CoinPage';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CoinViewmModel(
        context: context,
        repo: CoinClaimRepo(),
      ),
      child: _CoinContent(),
    );
  }
}

class _CoinContent extends StatefulWidget {
  const _CoinContent();

  @override
  State<_CoinContent> createState() => __CoinContentState();
}

class __CoinContentState extends State<_CoinContent> {
  late final CoinViewmModel _viewmModel;

  @override
  void initState() {
    super.initState();
    _viewmModel = context.read();
    _viewmModel.attachContext(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // โหลดข้อมูล CoinClaim
      await _viewmModel.fetchCoinCliamData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                // gradient: AppColors.primaryGradient,
                image: DecorationImage(
                  image: Assets.png.bgCoinClaim.provider(),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppDims.size_24.r),
                  bottomRight: Radius.circular(AppDims.size_24.r),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // AppBar
                  _buildAppBar(context),

                  Container(
                    padding: EdgeInsets.only(
                      left: AppDims.size_16,
                      right: AppDims.size_16,
                      bottom: AppDims.size_16,
                    ),
                    child: Column(
                      // Main container - จัดเรียงแนวตั้ง
                      children: [
                        // แถวบน
                        Row(
                          // จัดเรียง 2 กล่องแนวนอน
                          crossAxisAlignment:
                              CrossAxisAlignment.end, // จัดชิดด้านล่าง
                          children: [
                            // กล่องซ้ายบน (เล็ก) - 50% ความกว้าง
                            _buildCoinBalance(),

                            // SizedBox(width: 16.w), // ช่องว่างระหว่างกล่อง
                            // กล่องขวาบน (ใหญ่) - 50% ความกว้าง
                            Assets.png.brownyCoinClaimTitle.image(
                              width: 190.w,
                            ),
                          ],
                        ),

                        // กล่องล่าง (กว้างเต็มพื้นที่)
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(16.r),
                            ),
                          ),
                          child: ValueListenableBuilder(
                            valueListenable: _viewmModel.coinClaimDataNotifier,
                            builder: (context, result, child) {
                              if (result.isLoading) {
                                return CircularProgressIndicator();
                              }
                              if (!result.isSuccess) {
                                return Column(
                                  children: [
                                    Assets.png.brownyError2.image(),
                                    AppDims.vericalPadding_12,

                                    AppText(context.wording.errorUi),
                                  ],
                                );
                              }

                              // ข้อมูลสำหรับ Display ทั้งหมด
                              final coinData = result.data!;
                              return Column(
                                children: [
                                  // text title
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // แสดง day ที่เป็นวันปัจจุบัน
                                      _buildTextToDay(),
                                      // ปุ่ม ประวัติ
                                      _buildHistory(context),
                                    ],
                                  ),
                                  AppDims.vericalPadding_16,

                                  // Claim Coin
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(
                                      coinData.maxDay!,
                                      (index) {
                                        // สร้าง item สำหรับ Claim Coin
                                        return _buildItemCoinClaim(
                                          coinData.streaksDisplay[index],
                                          context,
                                        );
                                      },
                                    ),
                                  ),
                                  AppDims.vericalPadding_4,

                                  // แถวเงื่อนไข
                                  Row(
                                    children: [
                                      Spacer(),
                                      TextButton.icon(
                                        onPressed: () {},
                                        style: context
                                            .appTheme
                                            .textButtonTheme
                                            .style!
                                            .copyWith(
                                              minimumSize:
                                                  WidgetStatePropertyAll(
                                                    Size(
                                                      AppDims.size_50.w,
                                                      AppDims.size_18.h,
                                                    ),
                                                  ),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              padding: WidgetStatePropertyAll(
                                                EdgeInsets.only(
                                                  top: AppDims.size_2.h,
                                                ),
                                              ),
                                            ),
                                        icon: Icon(
                                          Icons.info_outline_rounded,
                                          color: AppColors.gray500,
                                        ),
                                        label: AppText(
                                          'เงื่อนไข',
                                          style: context.textTheme.labelMedium!
                                              .copyWith(
                                                color: AppColors.gray500,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppDims.vericalPadding_16,

                                  // Button Get Coin
                                  GestureDetector(
                                    onTap: coinData.claimableToday!
                                        ? _onCoinClaiming
                                        : null,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 57,
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: coinData.claimableToday!
                                            ? AppColors.claimCoinButtonGradient
                                            : null,
                                        color: coinData.claimableToday!
                                            ? null
                                            : AppColors.green400,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8.r),
                                        ),
                                        // ถ้าสามารถ claim. ได้
                                        boxShadow: coinData.claimableToday!
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.ci4,
                                                  blurRadius: 6.r,
                                                ),
                                              ]
                                            // claim ไม่ได้ ไม่ต้องมี shadow
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AppText(
                                            coinData.claimableToday!
                                                ? 'รับคอนย์'
                                                : 'รับพรุ่งนี้',
                                            style: context
                                                .textTheme
                                                .headlineSmall!
                                                .copyWith(
                                                  fontSize: AppDims.size_14.sp,
                                                  color: AppColors.white,
                                                ),
                                          ),
                                          AppDims.horizonPadding_8,

                                          Assets.svg.icPaw.svg(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Expanded(child: Text('')),
          ],
        ),
      ),
    );
  }

  void _onCoinClaiming() async {
    AppOverlays.showLoading(context);
    final result = await _viewmModel.coinClaiming();

    AppOverlays.hideLoading();
    if (mounted) {
      if (result.hasError) {
        AppOverlays.showBrownyDialog(
          context,
          title: context.wording.errorOccurred,
          message: context.wording.errorUi,
        );
        return;
      }

      AppOverlays.showBrownyDialog(
        context,
        imageAsset: Assets.png.brownyCoinClaimed.path,
        title: 'รับ Browny Coin สำเร็จ',
        message: 'เก็บต่อทุกวัน สิทธิประโยชน์ดีๆ รออยู่เพียบ!',
      );
    }
  }

  TextButton _buildHistory(BuildContext context) {
    return TextButton.icon(
      onPressed: () {},
      style: context.appTheme.textButtonTheme.style!.copyWith(
        minimumSize: WidgetStatePropertyAll(
          Size(
            AppDims.size_50.w,
            AppDims.size_18.h,
          ),
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: WidgetStatePropertyAll(
          EdgeInsets.only(
            top: AppDims.size_2.h,
          ),
        ),
      ),
      icon: Assets.svg.icHistory2.svg(
        colorFilter: ColorFilter.mode(
          AppColors.primary,
          BlendMode.srcIn,
        ),
      ),
      label: AppText(
        context.wording.history,
        style: context.textTheme.titleSmall!.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  ValueListenableBuilder<UiResult<String>> _buildTextToDay() {
    return ValueListenableBuilder(
      valueListenable: _viewmModel.toDayDataNotifier,
      builder: (context, value, child) {
        return TextButton.icon(
          onPressed: null,
          style: context.appTheme.textButtonTheme.style!.copyWith(
            minimumSize: WidgetStatePropertyAll(
              Size(
                AppDims.size_50.w,
                AppDims.size_18.h,
              ),
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: WidgetStatePropertyAll(
              EdgeInsets.only(
                top: AppDims.size_2.h,
              ),
            ),
          ),
          icon: Assets.svg.icCalendarToday.svg(
            colorFilter: ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
          label: AppText(
            'วันที่ ${value.data}',
            style: context.textTheme.titleSmall!.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoinBalance() {
    return Expanded(
      // ✅ ขยาย 50% ของพื้นที่
      // flex: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        child: Consumer<CustomerProvider>(
          builder: (context, value, child) {
            return Row(
              children: [
                Assets.png.brownyCoin.image(
                  width: AppDims.size_30.w,
                  height: AppDims.size_30.h,
                ),
                AppDims.horizonPadding_8,

                Container(
                  padding: EdgeInsets.only(
                    top: 8,
                    bottom: 8,
                    right: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.containerCoinGradient,
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.r),
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      // text: '= 0.25',
                      text: formatCurrency(
                        string: value.current.brownyCoin,
                        leadingSign: '= ',
                      ),
                      style:
                          GoogleFonts.prompt(
                            textStyle: context.textTheme.headlineMedium,
                          ).copyWith(
                            color: AppColors.white,
                          ),
                      children: [
                        TextSpan(text: ' '),
                        TextSpan(
                          text: context.wording.coin,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: AppColors.white,
                            fontSize: AppDims.size_10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.transparent,
      title: AppText(
        'Browny Coin',
        style: context.textTheme.titleLarge!.copyWith(
          fontSize: AppDims.size_18.sp,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildItemCoinClaim(StreakModelItem item, BuildContext context) {
    bool isClaimed = item.claimedAtDisplay.isNotEmpty;
    bool isHighlight = item.highlight;

    SvgGenImage brownyItemState;

    if (!isClaimed && !isHighlight) {
      // ยังไม่ claim และไม่เป็น highlight
      brownyItemState = Assets.svg.icBrownySmile2;
    } else if (isHighlight) {
      // เป็น highlight (มี icon เดียว)
      brownyItemState = Assets.svg.icBrownyLove;
    } else {
      // มีการ claim แล้ว
      brownyItemState = Assets.svg.icBrownySmile;
    }

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none, // ✅ ให้วงกลมยื่นออกนอกขอบได้
          children: [
            Container(
              width: 40.w,
              height: 70.h,
              padding: EdgeInsets.only(
                left: 3,
                right: 3,
                bottom: 2,
              ),
              decoration: BoxDecoration(
                color: isClaimed ? AppColors.primary : AppColors.ci5,
                borderRadius: BorderRadius.all(
                  Radius.circular(6.r),
                ),
                boxShadow: item.isToday
                    ? [
                        BoxShadow(
                          color: AppColors.yellow,
                          blurRadius: 5.r,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(6.r),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppDims.vericalPadding_8,
                    Container(
                      margin: EdgeInsets.only(right: 3),
                      width: double.infinity,
                      color: isHighlight ? AppColors.borderError : null,
                      child: Align(
                        alignment: Alignment.center,
                        child: AppText(
                          formatCurrency(
                            string: item.amount,
                            leadingSign: '+',
                          ),
                          style: context.textTheme.headlineSmall!.copyWith(
                            fontSize: AppDims.size_10.sp,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: brownyItemState.svg(
                        fit: BoxFit.cover,
                        width: 38.w,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -13, // ✅ ติดลบ = ยื่นออกขอบบน
              right: -13, // ✅ ติดลบ = ยื่นออกขอบขวา
              child: Assets.png.coinCoinClaim.image(
                width: 25.w,
                height: 25.h,
              ),
            ),
          ],
        ),
        AppDims.vericalPadding_4,

        AppText(
          item.isToday ? 'วันนี้' : item.dayDisplay,
          style: context.textTheme.titleSmall!.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
