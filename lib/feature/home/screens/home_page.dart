import 'dart:ui';

import 'package:browny_applications_new/core/const/app_constants.dart';
import 'package:browny_applications_new/core/providers/customer_provider.dart';
import 'package:browny_applications_new/feature/coin/screens/coin_page.dart';
import 'package:browny_applications_new/feature/coupon_voucher/screens/coupon_voucher_page.dart';
import 'package:browny_applications_new/feature/invit_friend/screen/invit_friend_page.dart';
import 'package:browny_applications_new/feature/wallet/screen/wallet_page.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:browny_applications_new/res/icons/assets.gen.dart';
import 'package:browny_applications_new/res/strings/app_strings.dart';
import 'package:browny_applications_new/res/styles/app_text_style.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/widgets/app_container_radius.dart';
import 'package:browny_applications_new/core/widgets/app_text.dart';
import 'package:browny_applications_new/core/widgets/browny_bottom_nav.dart';
import 'package:browny_applications_new/feature/authentication/viewmodel/authentication_viewmodel.dart';
import 'package:browny_applications_new/feature/home/repository/home_repo.dart';
import 'package:browny_applications_new/feature/home/viewmodel/home_page_viewmodel.dart';
import 'package:browny_applications_new/feature/authentication/screen/authentication_page.dart';
import 'package:browny_applications_new/feature/profile/screen/profile_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final pagePath = '/home_page';
  static final pageName = 'HomePage';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomePageViewmodel(
        context: context,
        repo: HomeRepo(),
      ),
      child: HomePageWidget(),
    );
  }
}

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({
    super.key,
  });

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  HomePageViewmodel get _viewmodel => context.read<HomePageViewmodel>();

  @override
  void initState() {
    super.initState();
    _viewmodel.attachContext(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewmodel.fetchBanners();

      if (mounted) {
        await _showInvitBottomSheet();
      }
    });
  }

  Future<dynamic> _showInvitBottomSheet() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: AppColors.transparent,
      useRootNavigator: true,
      builder: (dialogContext) {
        return FractionallySizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => dialogContext.pop(),
                  icon: CircleAvatar(
                    backgroundColor: AppColors.background.withValues(
                      alpha: 0.5,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: AppContainerRadius(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        AppDims.vericalPadding_16,
                        Assets.png.cardInvitFriend.image(fit: BoxFit.fill),

                        // AppDims.vericalPadding_16,
                        Padding(
                          padding: EdgeInsets.all(AppDims.size_16),
                          child: Column(
                            children: [
                              AppText(
                                'เชิญเพื่อนมาใช้ Browny\nสะสมแต้มแลกคูปอง!',
                                style: context.textTheme.titleLarge!.copyWith(
                                  fontSize: AppDims.size_24,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              AppDims.vericalPadding_10,

                              AppText(
                                'เพียงแค่ส่งลิงก์ให้เพื่อน หรือให้เพื่อนกรอกเบอร์โทรศัพท์ของคุณ! ก็สะสมแต้ม และนำไปแลกคูปองได้อีกเพียบ',
                                style: context.textTheme.bodyMedium!.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              AppDims.vericalPadding_16,

                              ElevatedButton(
                                onPressed: () {
                                  dialogContext.pop();
                                  context.pushNamed(InvitFriendPage.pageName);
                                },
                                child: AppText(
                                  'เชิญเพื่อนเลย',
                                ),
                              ),
                              AppDims.vericalPadding_8,
                              ElevatedButton(
                                onPressed: () => dialogContext.pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.ci3,
                                  foregroundColor: AppColors.primary,
                                ),
                                child: AppText(
                                  'รับทราบ',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: CustomScrollView(
        slivers: [
          // build AppBar
          _buildMyAppBar(),

          // ส่วนของ TP Wallet, Browny Coin
          _mySliverBox(
            child: _buildMyWalletAndCoinZone(),
          ),

          // เก็บ Coupon
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    child: ElevatedButton.icon(
                      onPressed: null,
                      icon: Assets.svg.icCouponRoundGreen.svg(),
                      label: Column(
                        children: [
                          AppText(
                            'เก็บคูปอง',
                            style: context.textTheme.labelLarge,
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.transparent,
                        foregroundColor: AppColors.primary,
                        alignment: AlignmentDirectional.centerStart,
                        padding: EdgeInsets.zero,
                        disabledBackgroundColor: AppColors.transparent,
                        overlayColor: AppColors.transparent,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.pushNamed(CouponVoucherPage.pageName);
                      // _showInvitBottomSheet();
                    },
                    // banner เก็บคูปอง
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: 0.1,
                          child: Assets.png.cardCouponEvoucher.image(
                            color: AppColors.black,
                          ),
                        ),
                        ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 0.1, sigmaY: 0.1),
                            child: Assets.png.cardCouponEvoucher.image(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverFillRemaining(),
        ],
      ),
      bottomNavigationBar: BrownyBottomNav(
        currentIndex: 0,
        onTap: (index) {
          print(index.toString());
        },
        onCenterTap: () {
          print('onCenterTap');
        },
      ),
    );
  }

  Widget _buildMyAppBar() {
    return SliverAppBar(
      pinned: false,
      floating: true,
      surfaceTintColor: AppColors.transparent,
      stretch: true,
      expandedHeight: 200.h,
      elevation: 0.0,
      flexibleSpace: FlexibleSpaceBar(
        // FlexibleSpaceBar: ส่วนที่ยืด-หดได้ของ AppBar=
        background: ValueListenableBuilder(
          valueListenable: _viewmodel.bannerNotifier,
          builder: (context, result, child) {
            if (!result.isSuccess) {
              return Container(
                color: AppColors.white,
              );
            }

            return CarouselSlider.builder(
              itemCount: result.requireData.length,
              itemBuilder: (context, index, realIndex) {
                return Image.network(
                  result.requireData[index].imageDisplay(context),
                  fit: BoxFit.cover,
                );
              },
              options: CarouselOptions(
                initialPage: 0,
                // enlargeCenterPage: true,
                enableInfiniteScroll: result.requireData.length > 1,
                viewportFraction: 1,
                aspectRatio: 1,
                // onPageChanged: (index, reason) {
                //   _viewModel.updateIndex = index;
                // },
              ),
            );
          },
        ),
        // background: Image.network(
        //   'https://dev.abgroup.co.th/storage/uploads/app_images/store_1757391567.jpg',
        //   fit: BoxFit.cover,
        // ),
        stretchModes: [
          StretchMode.zoomBackground,
        ],
        title: AppContainerRadius(
          height: AppDims.size_16.h,
        ),
        titlePadding: EdgeInsets.all(0.0),
      ),
      actionsPadding: EdgeInsets.symmetric(
        horizontal: AppDims.size_16.w,
      ),
      actions: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.background,
              child: IconButton(
                onPressed: () async {
                  await _showInvitBottomSheet();
                },
                icon: Assets.svg.icNotification.svg(
                  // เปลี่ยนสี svg
                  colorFilter: ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            AppDims.horizonPadding_10,
            Consumer<CustomerProvider>(
              builder: (context, customer, _) {
                return CircleAvatar(
                  backgroundColor: AppColors.background,
                  child: IconButton(
                    onPressed: () {
                      if (_viewmodel.isProfileGuest()) {
                        context.pushNamed(
                          AuthenticationPage.pageName,
                          extra: {
                            AuthenProcess: AuthenProcess.login,
                          },
                        );
                      } else {
                        context.pushNamed(ProfilePage.pageName);
                      }
                    },
                    icon: customer.current.image.orEmpty.isEmpty
                        // ถ้าไม่มีรูป Profile ใช้รูป Default
                        ? Assets.svg.icPerson.svg(
                            // เปลี่ยนสี svg
                            colorFilter: ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          )
                        // มีรูป Profile ให้ไปโหลดมา
                        : Image.network(
                            customer.current.image!,
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMyWalletAndCoinZone() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Consumer<CustomerProvider>(
        builder: (context, provider, _) {
          bool isGuest = provider.current.isGuest;
          EdgeInsets? margin = isGuest
              ? null
              : EdgeInsets.only(top: AppDims.size_21.h);

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppDims.horizonPadding_9,

              // TP+ Wallet Container
              Column(
                children: [
                  if (!isGuest) AppDims.vericalPadding_20,
                  Container(
                    // height: 84.h,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDims.size_12.w,
                      vertical: AppDims.size_16.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        width: 1.5,
                        color: AppColors.primary,
                      ),
                    ),
                    child: Row(
                      children: [
                        // AppDims.horizonPadding_12,
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              child: Assets.svg.icTpWallet.svg(),
                            ),
                            // Widget หลอกเพื่อให้ได้ระดับของ Widget ซ้ายขวาเท่ากัน
                            Text(
                              '',
                              style: AppTextNumberStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        AppDims.horizonPadding_12,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                AppText(
                                  'TP+ Wallet',
                                  style: context.textTheme.titleSmall!.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                AppDims.horizonPadding_16,

                                // สร้าง button TP+ Wallet
                                Builder(
                                  builder: (context) {
                                    final icon = isGuest
                                        ? Assets.svg.icLogin.svg(
                                            width: AppDims.size_12.w,
                                            height: AppDims.size_12.h,
                                          )
                                        : Assets.svg.icPlus.svg(
                                            width: AppDims.size_12.w,
                                            height: AppDims.size_12.h,
                                          );

                                    final onPressed = provider.current.isGuest
                                        ? () => context.pushNamed(
                                            AuthenticationPage.pageName,
                                            extra: {
                                              AuthenProcess:
                                                  AuthenProcess.login,
                                            },
                                          )
                                        : () {
                                            context.pushNamed(
                                              WalletPage.pageName,
                                            );
                                          };

                                    final label = provider.current.isGuest
                                        ? context.wording.login
                                        : context.wording.topup;

                                    return ElevatedButton.icon(
                                      icon: icon,
                                      // icon: Icon(Icons.login),
                                      iconAlignment: IconAlignment.end,
                                      onPressed: onPressed,
                                      style: context
                                          .appTheme
                                          .elevatedButtonTheme
                                          .style!
                                          .copyWith(
                                            shape: WidgetStatePropertyAll(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppDims.size_4,
                                                    ),
                                              ),
                                            ),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                            padding: WidgetStatePropertyAll(
                                              EdgeInsets.symmetric(
                                                horizontal: AppDims.size_4,
                                              ),
                                            ),
                                            minimumSize: WidgetStatePropertyAll(
                                              Size(70.w, 22.h),
                                            ), // Set this
                                            textStyle: WidgetStatePropertyAll(
                                              context.textTheme.bodySmall!
                                                  .copyWith(
                                                    color: AppColors.white,
                                                  ),
                                            ),
                                          ),
                                      label: AppText(
                                        label,
                                        style: context.textTheme.titleSmall!
                                            .copyWith(
                                              color: AppColors.white,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            Selector<CustomerProvider, String>(
                              selector: (context, provider) =>
                                  provider.current.creditBalance ?? '0.00',
                              builder: (context, value, child) => AppText(
                                formatCurrency(string: value, leadingSign: '฿'),
                                style: context.textTheme.headlineSmall!
                                    .copyWith(
                                      fontSize: AppDims.size_16.sp,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        // AppDims.horizonPadding_12,
                      ],
                    ),
                  ),
                ],
              ),
              AppDims.horizonPadding_9,

              // Coin Container
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Text เก็บได้ทุกวัน
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 8,
                        top: 2,
                        right: 8,
                        bottom: 20,
                      ),
                      margin: EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        // ถ้าเป็น Guest ไม่แสดง
                        color: isGuest ? null : AppColors.error,
                      ),
                      // ถ้าเป็น Guest ไม่แสดง
                      child: isGuest
                          ? null
                          : AppText(
                              'เก็บได้ทุกวัน',
                              style: context.textTheme.labelSmall!.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                    ),
                  ),
                  // Icon browny
                  Positioned(
                    left: -28.w,
                    right: 0,
                    top: -1.w,
                    child: isGuest
                        ? SizedBox()
                        : Assets.svg.icBrownySpeaker.svg(width: 35.w),
                  ),
                  // Card แสดง Coin
                  InkWell(
                    borderRadius: BorderRadius.circular(8.r),
                    overlayColor: WidgetStateProperty.resolveWith<Color?>((
                      states,
                    ) {
                      if (states.contains(WidgetState.hovered)) {
                        return AppColors.ctaPrimaryClicked.withValues(
                          alpha: 0.1,
                        );
                      }
                      if (states.contains(WidgetState.pressed)) {
                        return AppColors.ctaPrimaryClicked.withValues(
                          alpha: 0.2,
                        );
                      }
                      return null;
                    }),
                    onTap: () {
                      context.pushNamed(CoinPage.pageName);
                    },
                    child: Container(
                      margin: margin,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDims.size_12.w,
                        vertical: AppDims.size_16.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          width: 1.5,
                          color: AppColors.primary,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Coin
                              Image.asset(
                                Assets.png.brownyCoin.path,
                                width: AppDims.size_20.w,
                                height: AppDims.size_20.h,
                              ),
                              AppDims.horizonPadding_8,
                              AppText(
                                'Browny Coin',
                                style: context.textTheme.titleSmall!.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                          Selector<CustomerProvider, String>(
                            selector: (context, provider) =>
                                provider.current.brownyCoin ?? '0.00',
                            builder: (context, value, child) => AppText(
                              formatCurrency(
                                string: value,
                                trailingSign: ' ${context.wording.coin}',
                              ),
                              style: context.textTheme.titleSmall!.copyWith(
                                fontSize: AppDims.size_16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              AppDims.horizonPadding_9,

              // Coupon
              Column(
                children: [
                  if (!isGuest) AppDims.vericalPadding_20,
                  InkWell(
                    borderRadius: BorderRadius.circular(8.r),
                    overlayColor: WidgetStateProperty.resolveWith<Color?>((
                      states,
                    ) {
                      if (states.contains(WidgetState.hovered)) {
                        return AppColors.ctaPrimaryClicked.withValues(
                          alpha: 0.1,
                        );
                      }
                      if (states.contains(WidgetState.pressed)) {
                        return AppColors.ctaPrimaryClicked.withValues(
                          alpha: 0.2,
                        );
                      }
                      return null;
                    }),
                    onTap: () {
                      context.pushNamed(CouponVoucherPage.pageName);
                    },
                    child: Container(
                      // height: 84.h,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDims.size_12.w,
                        vertical: AppDims.size_16.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          width: 1.5,
                          color: AppColors.primary,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Coin
                              Assets.svg.icTicketFilled.svg(
                                width: AppDims.size_20.w,
                                height: AppDims.size_20.h,
                              ),
                              AppDims.horizonPadding_8,
                              AppText(
                                context.wording.rewards,
                                style: context.textTheme.titleSmall!.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                          Selector<CustomerProvider, String>(
                            selector: (context, provider) => '0',
                            builder: (context, value, child) => AppText(
                              formatCurrency(
                                string: value,
                                decimal: false,
                                trailingSign: ' ใบ',
                              ),
                              style: context.textTheme.titleSmall!.copyWith(
                                fontSize: AppDims.size_16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  SliverToBoxAdapter _mySliverBox({required Widget child}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDims.size_16.w),
        child: child,
      ),
    );
  }
}
