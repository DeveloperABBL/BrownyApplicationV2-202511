import 'package:browny_applications_new/core/const/app_constants.dart';
import 'package:browny_applications_new/core/providers/customer_provider.dart';
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

          _mySliverBox(
            child: Text(''),
          ),

          SliverFillRemaining(),
          // SliverToBoxAdapter(
          //   child: Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: Container(
          //       height: 90,
          //       color: Colors.blue,
          //     ),
          //   ),
          // ),
          // SliverToBoxAdapter(
          //   child: Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: Container(
          //       height: 134,
          //       color: Colors.blue,
          //     ),
          //   ),
          // ),
          // SliverToBoxAdapter(
          //   child: Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: Container(
          //       height: 205,
          //       color: Colors.blue,
          //     ),
          //   ),
          // ),
          // SliverToBoxAdapter(
          //   child: Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: Container(
          //       height: 140,
          //       color: Colors.blue,
          //     ),
          //   ),
          // ),

          // SliverToBoxAdapter(
          //   child: Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: SizedBox(
          //       height: 100.h,
          //     ),
          //   ),
          // ),
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
        background: Image.network(
          'https://dev.abgroup.co.th/storage/uploads/app_images/store_1757391567.jpg',
          fit: BoxFit.cover,
        ),
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
              child: Assets.svg.icNotification.svg(
                // เปลี่ยนสี svg
                colorFilter: ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TP+ Wallet Container
          Container(
            height: 84.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                width: 1.5,
                color: AppColors.primary,
              ),
            ),
            child: Row(
              children: [
                AppDims.horizonPadding_12,
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
                AppDims.horizonPadding_8,
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
                        AppDims.horizonPadding_8,

                        // สร้าง button TP+ Wallet
                        Consumer<CustomerProvider>(
                          builder: (context, provider, _) {
                            final icon = provider.current.isGuest
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
                                      AuthenProcess: AuthenProcess.login,
                                    },
                                  )
                                : () {
                                    context.pushNamed(WalletPage.pageName);
                                  };

                            final label = provider.current.isGuest
                                ? context.wording.login
                                : context.wording.topup;

                            return ElevatedButton.icon(
                              icon: icon,
                              // icon: Icon(Icons.login),
                              iconAlignment: IconAlignment.end,
                              onPressed: onPressed,
                              style: context.appTheme.elevatedButtonTheme.style!
                                  .copyWith(
                                    shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppDims.size_4,
                                        ),
                                      ),
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    padding: WidgetStatePropertyAll(
                                      EdgeInsets.symmetric(
                                        horizontal: AppDims.size_4,
                                      ),
                                    ),
                                    minimumSize: WidgetStatePropertyAll(
                                      Size(70.w, 22.h),
                                    ), // Set this
                                    textStyle: WidgetStatePropertyAll(
                                      context.textTheme.bodySmall!.copyWith(
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                              label: AppText(
                                label,
                                style: context.textTheme.titleSmall!.copyWith(
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
                        style: context.textTheme.headlineSmall!.copyWith(
                          fontSize: AppDims.size_16.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                AppDims.horizonPadding_12,
              ],
            ),
          ),
          AppDims.horizonPadding_9,

          // Coin Container
          Container(
            height: 84.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                width: 1.5,
                color: AppColors.primary,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDims.size_12.w),
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
                      '${formatCurrency(string: value)} ${context.wording.coin}',
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
