import 'dart:ui';

import 'package:browny_applications_new/core/core_index.dart';

class LuckyMockupPage extends StatefulWidget {
  const LuckyMockupPage({super.key});

  static final pagePath = '/LuckyMockupPage';
  static final pageName = 'LuckyMockupPage';

  /// util function route to pageName
  static Future<T?> goToPage<T>(BuildContext context) async {
    return await context.pushNamed(LuckyMockupPage.pageName);
  }

  @override
  State<LuckyMockupPage> createState() => _LuckyMockupPageState();
}

class _LuckyMockupPageState extends State<LuckyMockupPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.transparent,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDims.size_14.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ปุ่มกลับ
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.background,
                    padding: EdgeInsets.only(
                      left: AppDims.size_4.w,
                      top: AppDims.size_2.h,
                      right: AppDims.size_6.w,
                      bottom: AppDims.size_2.h,
                    ),
                    iconSize: AppDims.size_8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(32.r),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => context.pop(),
                  child: Row(
                    spacing: AppDims.size_4.w,
                    children: [
                      Assets.svg.icArrowBackward.svg(
                        color: AppColors.primary,
                      ),
                      AppText(
                        context.wording.back,
                        style: context.textTheme.labelLarge!.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                // ประวัติ
                ClipRect(
                  clipBehavior: Clip.antiAlias,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      padding: EdgeInsets.only(
                        left: AppDims.size_6.w,
                        top: AppDims.size_2.h,
                        right: AppDims.size_6.w,
                        bottom: AppDims.size_2.h,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(32.r),
                        color: Colors.grey.shade200.withValues(
                          alpha: 0.10,
                        ),
                      ),
                      child: Row(
                        spacing: AppDims.size_4.w,
                        children: [
                          Assets.luckyScan.icClock.svg(
                            color: AppColors.background,
                          ),
                          AppText(
                            context.wording.history,
                            style: context.textTheme.labelLarge!.copyWith(
                              color: AppColors.background,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(bottom: 125.h),
                  color: AppColors.primary,
                  child: Assets.luckyScan.bgFestMock.image(
                    // child: Image.network(
                    //   bannerUrl,
                    fit: BoxFit.fitWidth,
                    width: double.infinity,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.background,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Assets.png.brownyError2.image(width: 120.w),
                          AppDims.vericalPadding_8,
                          AppText(context.wording.errorUi),
                        ],
                      ),
                    ),
                  ),
                ),
                // White zone — sized by content, aligned to bottom of image
                Container(
                  width: double.infinity,
                  // height: 300,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppDims.size_16.r),
                      topRight: Radius.circular(AppDims.size_16.r),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TabBar
                      TabBar(
                        controller: _tabController,
                        dividerColor: AppColors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelStyle: context.textTheme.titleMedium!.copyWith(
                          color: AppColors.primary,
                        ),
                        unselectedLabelStyle: context.textTheme.titleMedium!
                            .copyWith(color: AppColors.gray500),
                        tabs: [
                          Tab(
                            child: AppText(
                              context.wording.conditionsAndDetails,
                            ),
                          ),
                          Tab(
                            child: AppText(
                              context.wording.otherCampaigns,
                            ),
                          ),
                        ],
                      ),
                      // Tab content
                      if (_tabController.index == 0)
                        _buildConditionsTab(context)
                      else
                        _buildCampaignsTab(context),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionsTab(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDims.size_16.w,
        AppDims.size_16.h,
        AppDims.size_16.w,
        32.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Numbered condition list
          AppText('''
'เฉพาะสาขาที่ร่วมรายการ',
'สาขา อนุสาวรีย์ชัยสมรภูมิ ราชวิถี ช.7',
'รับฟรี! ส่วนลดราคาซักน้ำเย็นทุกเครื่อง เหลือเพียงเครื่องละ 20 บาท',
'จำกัด 1 สิทธิ์ / สมาชิก',
            '''),
          SizedBox(height: AppDims.size_16.h),
          // Scan QR button
          ElevatedButton.icon(
            onPressed: () {
              _showLucyScanResult(context, '');
            },
            iconAlignment: IconAlignment.end,
            icon: Assets.svg.icScan2.svg(
              colorFilter: ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
            label: AppText(context.wording.scanQrActivity),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignsTab(BuildContext context) {
    return SizedBox(height: 80.h);
  }

  Future<void> _showLucyScanResult(BuildContext context, String type) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: AppDims.size_32.w),
          child: FractionallySizedBox(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => dialogContext.pop(),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Assets.svg.icUnchecked.svg(
                            width: 20.w,
                            height: 20.h,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AppContainerRadius(
                        decoration: BoxDecoration(
                          // gradient: AppColors.popupFestiveWonGradient,
                          // gradient: AppColors.popupFestiveLoseGradient,
                          gradient: AppColors.popupFestiveFailedGradient,
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: SafeArea(
                          child: Column(
                            children: [
                              // AppDims.vericalPadding_16,
                              SizedBox(
                                height: 200.h,
                              ),

                              // AppDims.vericalPadding_16,
                              Padding(
                                padding: EdgeInsets.all(AppDims.size_16),
                                child: Column(
                                  children: [
                                    AppText(
                                      '1',
                                      textAlign: TextAlign.center,
                                      style: context.textTheme.headlineLarge!
                                          .copyWith(
                                            fontSize: AppDims.size_24.sp,
                                            color: AppColors.primary,
                                          ),
                                    ),
                                    AppDims.vericalPadding_10,

                                    AppText(
                                      '2',
                                      textAlign: TextAlign.start,
                                      style: context.textTheme.labelMedium!
                                          .copyWith(
                                            color: AppColors.gray600,
                                          ),
                                    ),
                                    AppDims.vericalPadding_16,

                                    ElevatedButton(
                                      onPressed: () {
                                        dialogContext.pop();
                                      },
                                      child: AppText(
                                        context.wording.acknowledge,
                                      ),
                                    ),
                                    AppDims.vericalPadding_4,
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

                Positioned(
                  top: -45.w,
                  child: Assets.png.brownyPromotion.image(width: 250.w),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
