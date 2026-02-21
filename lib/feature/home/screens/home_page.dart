import 'dart:async';
import 'dart:ui';

import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/utils/notification_helper.dart';
import 'package:browny_applications_new/core/widgets/invit_bottom_sheet_dialog.dart';
import 'package:browny_applications_new/core/widgets/popup_dialog.dart';
import 'package:browny_applications_new/feature/coin/screens/coin_page.dart';
import 'package:browny_applications_new/feature/contacts/models/contact_model.dart';
import 'package:browny_applications_new/feature/contacts/screens/contact_page.dart';
import 'package:browny_applications_new/feature/home/models/banner_model.dart';
import 'package:browny_applications_new/feature/map/screens/map_page.dart';
import 'package:browny_applications_new/feature/profile/screen/my_profile_and_preferences_page.dart';
import 'package:browny_applications_new/feature/transactions/screens/coupon_voucher_page.dart';
import 'package:browny_applications_new/feature/wallet/screen/wallet_page.dart';
import 'package:browny_applications_new/feature/authentication/viewmodel/authentication_viewmodel.dart';
import 'package:browny_applications_new/feature/home/repository/home_repo.dart';
import 'package:browny_applications_new/feature/home/viewmodel/home_page_viewmodel.dart';
import 'package:browny_applications_new/feature/authentication/screen/authentication_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

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

class _HomePageWidgetState extends State<HomePageWidget>
    with WidgetsBindingObserver {
  HomePageViewmodel get _viewmodel => context.read<HomePageViewmodel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _viewmodel.attachContext(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewmodel.fetchBannersHighlight();

      if (mounted) {
        final showInvitFriendToday = await _viewmodel
            .fetchPopupInivitFriendForToday();
        if (mounted && showInvitFriendToday.data!) {
          await InvitBottomSheetDialog.showInvitBottomSheet(
            context,
            _viewmodel,
          );
          _viewmodel.dismissInvitFriendForToday();
        }

        if (!mounted) return;
        await _fetchPopups(context);
      }
    });
  }

  Future<void> _fetchPopups(BuildContext context) async {
    final popupResult = await _viewmodel.fetchPopups();

    if (popupResult.isSuccess && popupResult.data.orEmpty.isNotEmpty) {
      if (!context.mounted) return;
      await PopupDialog.show(
        context: context,
        popups: popupResult.data ?? [],
        locale: context.languageCode,
        onDismiss: (dismissPopupForToday) {
          if (dismissPopupForToday) {
            _viewmodel.dismissPopupsForToday(popupResult.data ?? []);
          }
        },
        onPopupImagePressed: (popup) {
          // TODO: Handle popup action based on programAction and autoClickTarget
          debugPrint('Popup pressed: ${popup.name}');
          debugPrint('Program action: ${popup.programAction}');
          debugPrint('Auto click target: ${popup.autoClickTarget}');
        },
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App is visible and responding to user input (e.g., app comes to foreground)
        debugPrint('AppLifecycleState.resumed');
        // if (mounted) {
        //   unawaited(_fetchPopups(context));
        // }
        break;
      case AppLifecycleState.inactive:
        // App is in an inactive state (e.g., user opens app switcher or receives a call)
        debugPrint('AppLifecycleState.inactive');
        break;
      case AppLifecycleState.hidden:
        // All views of the app are hidden (e.g., app is minimized)
        debugPrint('AppLifecycleState.hidden');
        break;
      case AppLifecycleState.paused:
        // App is not visible and not responding to user input
        debugPrint('AppLifecycleState.paused');
        break;
      case AppLifecycleState.detached:
        // The Flutter engine is running but detached from any host views (e.g., app termination)
        debugPrint('AppLifecycleState.detached');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      edgeOffset: 10.h,
      backgroundColor: AppColors.background,
      onRefresh: () async {
        await _viewmodel.refresh();
      },
      child: Scaffold(
        // extendBody: true,
        body: CustomScrollView(
          slivers: [
            // build AppBar
            _buildMyAppBar(),

            // ส่วนของ TP Wallet, Browny Coin
            SliverToBoxAdapter(
              child: _buildMyWalletAndCoinZone(),
            ),

            // _mySliverBox(
            //   child: _buildMyWalletAndCoinZone(),
            // ),

            // icon shortcut
            SliverToBoxAdapter(
              child: _buildRishIcons(context),
            ),

            // เก็บ Coupon
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppDims.size_16.w,
                  right: AppDims.size_16.w,
                  top: AppDims.size_16.h,
                ),
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
                              // เก็บคูปอง
                              context.wording.collectCoupon,
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
                        if (_viewmodel.isProfileGuest()) {
                          context.pushNamed(
                            AuthenticationPage.pageName,
                            extra: {
                              AuthenProcess: AuthenProcess.login,
                            },
                          );
                        } else {
                          context.pushNamed(CouponVoucherPage.pageName);
                        }

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
                              filter: ImageFilter.blur(
                                sigmaX: 0.1,
                                sigmaY: 0.1,
                              ),
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

            // สถานะบริการ
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppDims.size_16.w,
                  right: AppDims.size_16.w,
                  top: AppDims.size_8.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: ElevatedButton.icon(
                        onPressed: null,
                        icon: Assets.svg.icRefreshRoundGreen.svg(),
                        label: Column(
                          children: [
                            AppText(
                              // สถานะการใช้งาน
                              context.wording.usageStatus,
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
                    Align(
                      alignment: Alignment.center,
                      child: AppToggleWidget(),
                    ),
                    AppDims.vericalPadding_8,

                    Align(
                      alignment: Alignment.center,
                      child: Assets.png.brownyWashy.image(
                        width: AppDims.size_90.w,
                      ),
                    ),
                    AppDims.vericalPadding_8,

                    Align(
                      alignment: Alignment.center,
                      // #รักใครให้ซักผ้า
                      child: AppText(context.wording.loveAnyoneDoLaundry),
                    ),
                  ],
                ),
              ),
            ),

            // สถานะบริการ
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppDims.size_16.w,
                  right: AppDims.size_16.w,
                  top: AppDims.size_8.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: ElevatedButton.icon(
                        onPressed: null,
                        icon: Assets.svg.icPawRoundedGreen.svg(),
                        label: Column(
                          children: [
                            AppText(
                              // บริการ
                              context.wording.services,
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
                    SizedBox(
                      height: AppDims.size_106.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) =>
                            Assets.services.values[index].image(
                              width: AppDims.size_109.w,
                              height: AppDims.size_106.h,
                            ),
                        separatorBuilder: (context, index) =>
                            AppDims.horizonPadding_8,
                        itemCount: Assets.services.values.take(2).length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AppDims.vericalPadding_46,
            ),
          ],
        ),
        bottomNavigationBar: BrownyBottomNav(
          currentIndex: 0,
          onTap: (context, index) {
            debugPrint(index.toString());
            if (index == 1) {
              context.pushNamed(CouponVoucherPage.pageName);
              return;
            }

            if (index == 2) {
              context.pushNamed(MapPage.pageName);
              return;
            }
          },
        ),
      ),
    );
  }

  Widget _buildRishIcons(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        margin: EdgeInsets.only(
          left: AppDims.size_16.w,
          right: AppDims.size_16.w,
          top: AppDims.size_16.h,
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              FutureBuilder<UiResult<BrownyLiveResponse>>(
                future: _viewmodel.fetchBrownyLive(),
                builder: (context, snapshot) {
                  final hasData =
                      snapshot.hasData && snapshot.requireData.isSuccess;
                  if (!hasData || snapshot.requireData.data!.enabled == false) {
                    return SizedBox();
                  }
                  return GestureDetector(
                    onTap: hasData
                        ? () {
                            LaunchHelper.openUrlInBrowser(
                              snapshot.requireData.data!.link!,
                            );
                          }
                        : null,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDims.size_8.w,
                        vertical: AppDims.size_8.h,
                      ),
                      child: Column(
                        children: [
                          Assets.iconShortcut.iscBrownyLive.image(
                            width: AppDims.size_64.w,
                            height: AppDims.size_32.h,
                          ),
                          AppText(
                            'Browny\nLive',
                            textAlign: TextAlign.center,
                            style: context.textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDims.size_8.w,
                  vertical: AppDims.size_8.h,
                ),
                child: Column(
                  children: [
                    Assets.iconShortcut.iscCoupon.image(
                      width: AppDims.size_64.w,
                      height: AppDims.size_32.h,
                    ),
                    AppText(
                      // คูปอง
                      context.wording.rewards,
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDims.size_8.w,
                  vertical: AppDims.size_8.h,
                ),
                child: GestureDetector(
                  onTap: () => onBrownyClubClick(highlight: null),
                  child: Column(
                    children: [
                      Assets.iconShortcut.iscBrownyClub.image(
                        width: AppDims.size_64.w,
                        height: AppDims.size_32.h,
                      ),
                      AppText(
                        'Browny\nClub',
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDims.size_8.w,
                  vertical: AppDims.size_8.h,
                ),
                child: Column(
                  children: [
                    Assets.iconShortcut.iscBrownyShop.image(
                      width: AppDims.size_64.w,
                      height: AppDims.size_32.h,
                    ),
                    AppText(
                      'Browny\nShop',
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDims.size_8.w,
                  vertical: AppDims.size_8.h,
                ),
                child: Column(
                  children: [
                    Assets.iconShortcut.iscLuckyScan.image(
                      width: AppDims.size_64.w,
                      height: AppDims.size_32.h,
                    ),
                    AppText(
                      'Lucky\nScan',
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDims.size_8.w,
                  vertical: AppDims.size_8.h,
                ),
                child: Column(
                  children: [
                    Assets.iconShortcut.iscTransactionHistory.image(
                      width: AppDims.size_64.w,
                      height: AppDims.size_32.h,
                    ),
                    AppText(
                      // ประวัติ\nการใช้งาน
                      context.wording.usageHistory,
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),

              GestureDetector(
                onTap: () => ContactPage.goToPage(
                  context,
                  ContactProvider.contacts,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDims.size_8.w,
                    vertical: AppDims.size_8.h,
                  ),
                  child: Column(
                    children: [
                      Assets.iconShortcut.iscContact.image(
                        width: AppDims.size_64.w,
                        height: AppDims.size_32.h,
                      ),
                      AppText(
                        // ติดต่อ\nสอบถาม
                        context.wording.contactInquiry,
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDims.size_8.w,
                  vertical: AppDims.size_8.h,
                ),
                child: Column(
                  children: [
                    Assets.iconShortcut.iscBrownyId.image(
                      width: AppDims.size_64.w,
                      height: AppDims.size_32.h,
                    ),
                    AppText(
                      'Browny ID',
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onBrownyClubClick({
    required BannerHighLightModel? highlight,
  }) {
    _viewmodel.onBannerHighLightSelected(context, highlight: highlight);
    // context.pushNamed(
    //   ArticlesPage.pageName,
    //   extra: _viewmodel,
    // );
  }

  Widget _buildMyAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: false,
      surfaceTintColor: AppColors.transparent,
      stretch: true,
      expandedHeight: 200.h,
      elevation: 0.0,
      flexibleSpace: FlexibleSpaceBar(
        // FlexibleSpaceBar: ส่วนที่ยืด-หดได้ของ AppBar=
        background: ValueListenableBuilder(
          valueListenable: _viewmodel.bannerHighlightNotifier,
          builder: (context, result, child) {
            if (!result.isSuccess) {
              return Container(
                color: AppColors.white,
              );
            }

            return CarouselSlider.builder(
              itemCount: result.requireData.length,
              itemBuilder: (context, index, realIndex) {
                final imageUrl = result.requireData[index].imageDisplay(
                  context,
                );
                return GestureDetector(
                  onTap: () {
                    if (result.requireData[index].type == 'article') {
                      onBrownyClubClick(highlight: result.requireData[index]);
                    }
                  },
                  child: CachedNetworkImage(
                    width: MediaQuery.of(context).size.width,
                    // ใช้ ValueKey เพื่อให้ Flutter รู้ว่า widget เดิมยังคงเหมือนเดิม
                    // ไม่ต้อง rebuild ใหม่ตอน slide carousel
                    key: ValueKey(imageUrl),
                    cacheKey: imageUrl,
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    // ตั้งเป็น Duration.zero เพื่อปิด fade animation
                    // แสดงรูปจาก cache ได้ทันทีโดยไม่มี delay
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    // Cache รูปใน memory (RAM) โดยคูณด้วย devicePixelRatio
                    // เพื่อให้รูปคมชัดบนหน้าจอความละเอียดสูง
                    memCacheWidth:
                        (MediaQuery.of(context).size.width *
                                MediaQuery.of(context).devicePixelRatio)
                            .round(),
                    memCacheHeight:
                        (200.h * MediaQuery.of(context).devicePixelRatio)
                            .round(),
                    // Cache รูปใน disk (storage) เพื่อไม่ต้องโหลดซ้ำตอนเปิด app ใหม่
                    maxWidthDiskCache: (MediaQuery.of(context).size.width * 2)
                        .round(),
                    maxHeightDiskCache: (200.h * 2).round(),
                    // ใช้ placeholder แทน progressIndicatorBuilder
                    // เพื่อแสดง loading เฉพาะตอนโหลดครั้งแรก
                    // ไม่แสดงซ้ำเมื่อ slide กลับมาที่รูปเดิม
                    placeholder: (context, url) => Container(
                      color: AppColors.ci3,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.ci3,
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                initialPage: 0,
                enlargeCenterPage: true,
                enableInfiniteScroll: result.requireData.length > 1,
                // enableInfiniteScroll: false,
                autoPlay: true,
                viewportFraction: 1,
                aspectRatio: 1,
                // onPageChanged: (index, reason) {
                //   _viewmodel.onBannerSliding();
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
          StretchMode.blurBackground,
        ],
        expandedTitleScale: 8,
        title: AppContainerRadius(
          height: AppDims.size_2.h,
        ),
        // collapseMode: CollapseMode.none,
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
                  // await InvitBottomSheetDialog.showInvitBottomSheet(
                  //   context,
                  //   _viewmodel,
                  // );

                  NotificationHelper.showTestNotification(
                    title: 'In-App Test Notification',
                    body: 'body',
                  );
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
                      // if (_viewmodel.isProfileGuest()) {
                      //   context.pushNamed(
                      //     AuthenticationPage.pageName,
                      //     extra: {
                      //       AuthenProcess: AuthenProcess.login,
                      //     },
                      //   );
                      // } else {
                      // context.pushNamed(ProfilePage.pageName);
                      context.pushNamed(MyProfileAndPreferencesPage.pageName);
                      // }
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
                            errorBuilder: (context, error, stackTrace) =>
                                Assets.svg.icPerson.svg(
                                  // เปลี่ยนสี svg
                                  colorFilter: ColorFilter.mode(
                                    AppColors.primary,
                                    BlendMode.srcIn,
                                  ),
                                ),
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
              AppDims.horizonPadding_16,

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
                  // Text เก็บได้ทุกวัน และ Icon browny
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _buildDogAndBadgeGroup(isGuest),
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
                                // คูปอง
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
                            selector: (context, provider) =>
                                provider.current.totalCoupons?.toString() ??
                                '0',
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

              AppDims.horizonPadding_16,
            ],
          );
        },
      ),
    );
  }

  Widget _buildDogAndBadgeGroup(bool isGuest) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ก้อนที่ 1 (ของกลุ่มย่อย): ป้ายแดง
        Container(
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
                  // เก็บเพิ่มได้ทุกวัน
                  context.wording.collectMoreDaily,
                  style: context.textTheme.labelSmall!.copyWith(
                    color: AppColors.white,
                  ),
                ),
        ),

        // ก้อนที่ 2 (ของกลุ่มย่อย): รูปตุ๊กตาหมา
        // วางไว้ที่พิกัด 0,0 ของกลุ่มย่อยนี้ สุนัขจะทับป้ายแดงในองศาเดิมเสมอ
        Positioned(
          left: -27.w,
          top: -2,
          child: isGuest
              ? SizedBox()
              : Assets.svg.icBrownySpeaker.svg(width: 35.w),
        ),
      ],
    );
  }
}
