import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/widgets/app_text.dart';
import 'package:browny_applications_new/core/widgets/coupon_e_voucher_card_widget.dart';
import 'package:browny_applications_new/feature/transactions/repository/coupon_voucher_repo.dart';
import 'package:browny_applications_new/feature/transactions/viewmodel/transactions_viewmodel.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:browny_applications_new/res/icons/assets.gen.dart';
import 'package:browny_applications_new/res/strings/app_strings.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CouponVoucherPage extends StatelessWidget {
  const CouponVoucherPage({super.key});

  static final pagePath = '/coupon_voucher';
  static final pageName = 'CouponVoucherPage';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionsViewmodel(
        context: context,
        couponRepo: CouponVoucherRepo(),
      ),
      child: const _CouponVoucherWidget(),
    );
  }
}

class _CouponVoucherWidget extends StatefulWidget {
  const _CouponVoucherWidget();

  @override
  State<_CouponVoucherWidget> createState() => _CouponVoucherWidgetState();
}

class _CouponVoucherWidgetState extends State<_CouponVoucherWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final TransactionsViewmodel _viewmodel;

  @override
  void initState() {
    super.initState();
    _viewmodel = context.read();
    _viewmodel.attachContext(context);
    _tabController = TabController(initialIndex: 1, length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bareBackground,
      persistentFooterDecoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5), // Shadow color
            spreadRadius: 1, // How much the shadow should spread
            blurRadius: 10, // How soft the shadow should be
            offset: Offset(0, -5), // Negative dy value moves the shadow upwards
          ),
        ],
      ),
      persistentFooterButtons: [
        Container(
          padding: EdgeInsets.only(
            left: AppDims.size_24.w,
            right: AppDims.size_24.w,
            top: AppDims.size_8.h,
          ),
          child: ElevatedButton(
            onPressed: () {},
            child: AppText('ดำเนินการต่อโดยไม่ใช้คูปอง'),
          ),
        ),
      ],
      body: NestedScrollView(
        physics: const ClampingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // AppBar with background
            SliverAppBar(
              flexibleSpace: FlexibleSpaceBar(
                background: Assets.png.bgAppBar.image(
                  fit: BoxFit.cover,
                ),
              ),
              title: AppText(
                'คูปองและรหัสคูปอง',
                style: context.textTheme.titleLarge!.copyWith(
                  color: AppColors.textWhite,
                ),
              ),
              pinned: true,
              floating: false,
            ),

            // ช่องกรอก, Scan Section
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.all(AppDims.size_16),
                padding: EdgeInsets.all(AppDims.size_16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    // Title
                    Row(
                      children: [
                        Assets.svg.icCouponEditRoundedGreen.svg(),
                        AppDims.horizonPadding_8,
                        AppText(
                          'รหัสและการสแกน',
                          style: context.textTheme.labelLarge!.copyWith(
                            fontSize: AppDims.size_16.sp,
                          ),
                        ),
                      ],
                    ),
                    AppDims.vericalPadding_8,

                    // ช่องกรอก
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDims.size_16,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              border: BoxBorder.fromLTRB(
                                bottom: BorderSide(
                                  color: AppColors.border,
                                  width: 1.w,
                                ),
                                left: BorderSide(
                                  color: AppColors.border,
                                  width: 1.w,
                                ),
                                top: BorderSide(
                                  color: AppColors.border,
                                  width: 1.w,
                                ),
                              ),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8.r),
                                topLeft: Radius.circular(8.r),
                              ),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'ใส่รหัสคูปองของคุณได้ที่นี่',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDims.size_8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gray400,
                              border: BoxBorder.all(
                                color: AppColors.border,
                                width: 1.w,
                              ),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(8.r),
                                topRight: Radius.circular(8.r),
                              ),
                            ),
                            child: AppTextFormField(
                              enabled: false,
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                  ),
                                  child: Assets.svg.icMagnify.svg(
                                    colorFilter: ColorFilter.mode(
                                      AppColors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                prefixIconConstraints: BoxConstraints(
                                  minWidth: 12,
                                  minHeight: 12,
                                ),
                                hintStyle: context.textTheme.labelLarge!
                                    .copyWith(
                                      color: AppColors.textWhite,
                                    ),
                                hintText: 'ใช้คูปอง',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppDims.vericalPadding_8,

                    // ปุ่มเปิดกล้อง Scan
                    ElevatedButton.icon(
                      onPressed: () {},
                      label: AppText(context.wording.scanCoupon),
                      iconAlignment: IconAlignment.end,
                      icon: Assets.svg.icScan3.svg(width: 16.w, height: 16.h),
                      style: context.appTheme.elevatedButtonTheme.style!
                          .copyWith(
                            backgroundColor: WidgetStatePropertyAll(
                              AppColors.ci3,
                            ),
                            foregroundColor: WidgetStatePropertyAll(
                              AppColors.ci,
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // TabBar
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  dividerColor: AppColors.transparent,
                  indicatorPadding: EdgeInsets.symmetric(horizontal: 8.w),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: context.textTheme.titleMedium!.copyWith(
                    color: AppColors.primary,
                  ),
                  unselectedLabelStyle: context.textTheme.titleMedium!.copyWith(
                    color: AppColors.gray500,
                  ),
                  tabs: [
                    Tab(child: AppText(context.wording.sakob)),
                    Tab(child: AppText(context.wording.eVouchers)),
                    Tab(child: AppText('Browny Shop')),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Container(
          color: AppColors.background,
          child: TabBarView(
            controller: _tabController,
            children: [
              // ซักอบ
              _buildTabContent(
                context: context,
                icon: Assets.svg.icCouponWashRoundedGreen.svg(),
                title: 'ซักอบ',
              ),

              // E-Voucher
              _CustomerEVoucherWidget(
                viewModel: _viewmodel,
              ),
              // _buildTabContent(
              //   context: context,
              //   icon: Assets.svg.icCouponCheckRoundedGreen.svg(),
              //   title: 'E-Voucher ของฉัน',
              // ),

              // Browny Shop
              _buildTabContent(
                context: context,
                icon: Assets.svg.icCouponCheckRoundedGreen.svg(),
                title: 'Browny Shop',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent({
    required BuildContext context,
    required Widget icon,
    required String title,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDims.size_16.w,
        vertical: AppDims.size_14.h,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppDims.size_14.w,
        vertical: AppDims.size_8.h,
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: null,
              icon: Assets.svg.icCouponWashRoundedGreen.svg(),
              label: AppText(
                'ซักอบ',
                style: context.textTheme.labelLarge,
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
            AppDims.vericalPadding_16,

            ...List.generate(6, (index) => '').map(
              (e) => CouponEVoucherCardWidget(
                icon: Assets.png.brownyCreatePin.image(),
                title: 'Title',
                description: 'Description',
                detailUsing: 'Detail using',
                expired: 'Expired',
              ),
            ),

            ElevatedButton.icon(
              onPressed: null,
              icon: Assets.svg.icCouponWashRoundedGreen.svg(),
              label: AppText(
                'ซักอบ',
                style: context.textTheme.labelLarge,
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
            AppDims.vericalPadding_16,
            ...List.generate(3, (index) => '').map(
              (e) => Container(
                // Disable
                // foregroundDecoration: BoxDecoration(
                //   color: Colors.grey,
                //   backgroundBlendMode: BlendMode.saturation,
                // ),
                height: 85.h,
                margin: EdgeInsets.only(bottom: AppDims.size_12),
                decoration: BoxDecoration(
                  border: BoxBorder.all(
                    width: 1,
                    color: AppColors.primary,
                  ),
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 100,
                      height: 85.h,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: BoxBorder.fromLTRB(
                          right: BorderSide(
                            width: 1,
                            color: AppColors.primary,
                          ),
                        ),
                        color: AppColors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8.r),
                          topLeft: Radius.circular(8.r),
                        ),
                      ),
                      // child: Icon(Icons.discount_rounded),
                      child: Assets.png.brownyCreatePin.image(),
                    ),

                    Container(
                      padding: EdgeInsets.all(AppDims.size_8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Title',
                            style: context.textTheme.titleSmall,
                          ),
                          AppText(
                            'Description',
                            style: context.textTheme.labelSmall!.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          Spacer(),

                          RichText(
                            text: TextSpan(
                              text: 'Expried',
                              style: context.textTheme.bodySmall?.copyWith(
                                fontSize: AppDims.size_10.sp,
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                TextSpan(text: ' '),
                                TextSpan(
                                  text: 'เงื่อนไข',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontSize: AppDims.size_10.sp,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ElevatedButton.icon(
              onPressed: null,
              icon: Assets.svg.icCouponWashRoundedGreen.svg(),
              label: AppText(
                'ซักอบ',
                style: context.textTheme.labelLarge,
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
            AppDims.vericalPadding_16,
            ...List.generate(2, (index) => '').map(
              (e) => Container(
                // Disable
                // foregroundDecoration: BoxDecoration(
                //   color: Colors.grey,
                //   backgroundBlendMode: BlendMode.saturation,
                // ),
                height: 85.h,
                margin: EdgeInsets.only(bottom: AppDims.size_12),
                decoration: BoxDecoration(
                  border: BoxBorder.all(
                    width: 1,
                    color: AppColors.primary,
                  ),
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 100,
                      height: 85.h,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: BoxBorder.fromLTRB(
                          right: BorderSide(
                            width: 1,
                            color: AppColors.primary,
                          ),
                        ),
                        color: AppColors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8.r),
                          topLeft: Radius.circular(8.r),
                        ),
                      ),
                      // child: Icon(Icons.discount_rounded),
                      child: Assets.png.brownyCreatePin.image(),
                    ),

                    Container(
                      padding: EdgeInsets.all(AppDims.size_8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Title',
                            style: context.textTheme.titleSmall,
                          ),
                          AppText(
                            'Description',
                            style: context.textTheme.labelSmall!.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          Spacer(),

                          RichText(
                            text: TextSpan(
                              text: 'Expried',
                              style: context.textTheme.bodySmall?.copyWith(
                                fontSize: AppDims.size_10.sp,
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                TextSpan(text: ' '),
                                TextSpan(
                                  text: 'เงื่อนไข',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontSize: AppDims.size_10.sp,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerWashDryCouponWidget extends StatelessWidget {
  const _CustomerWashDryCouponWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _CustomerEVoucherWidget extends StatefulWidget {
  const _CustomerEVoucherWidget({
    required TransactionsViewmodel viewModel,
  }) : _viewModel = viewModel;

  final TransactionsViewmodel _viewModel;

  @override
  State<_CustomerEVoucherWidget> createState() =>
      _CustomerEVoucherWidgetState();
}

class _CustomerEVoucherWidgetState extends State<_CustomerEVoucherWidget> {
  bool _myEVoucherExpanded = false;
  bool _eVoucherExpanded = false;

  @override
  void initState() {
    super.initState();
    // Initialize location permission and fetch coupon packages
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget._viewModel.initializeLocationAndFetchCoupons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDims.size_16.w,
        vertical: AppDims.size_14.h,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppDims.size_14.w,
        vertical: AppDims.size_8.h,
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title EVoucher ที่ Customer มีอยู่
            ElevatedButton.icon(
              onPressed: null,
              icon: Assets.svg.icCouponCheckRoundedGreen.svg(),
              label: AppText(
                'E-Voucher ของฉัน',
                style: context.textTheme.labelLarge!.copyWith(
                  fontSize: AppDims.size_16.sp,
                ),
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
            AppDims.vericalPadding_16,

            // List E-Voucher ที่ Customer มีอยู่
            ValueListenableBuilder(
              valueListenable: widget._viewModel.evoucherNotifier,
              builder: (context, evoucherResult, child) {
                if (evoucherResult.isLoading) {
                  Future.microtask(widget._viewModel.fetchCustomerEVoucher);
                  return CircularProgressIndicator();
                }

                if (evoucherResult.isEmpty || evoucherResult.hasError) {
                  // ไม่พบข้อมูลอะไร
                  return _buidlNotFoundData(context);
                }

                final evoucherList = evoucherResult.data.orEmpty;
                final lengthList = evoucherList.length;

                final needButtonExpanding =
                    evoucherList.isNotEmpty && lengthList > 2;

                return Column(
                  children: [
                    ...evoucherList
                        .take(_myEVoucherExpanded ? lengthList : 2)
                        .map(
                          (e) => CouponEVoucherCardWidget(
                            icon: Image.network(
                              e.imageUrlDisplay(context),
                              errorBuilder: (_, _, _) => _onImageError(),
                            ),
                            title: e.nameDisplay(context),
                            description: e.descriptionDisplay(context),
                            detailUsing: e.detailUsingDisplay(context),
                            expired: e.expireDateDisplay(context),
                          ),
                        ),

                    if (needButtonExpanding)
                      _buildButtonExpandable(
                        () {
                          setState(() {
                            _myEVoucherExpanded = !_myEVoucherExpanded;
                          });
                        },
                        _myEVoucherExpanded,
                      ),
                  ],
                );
              },
            ),
            AppDims.vericalPadding_14,

            // สำหรับทดลองเวลาไม่มี Data
            // ...List.generate(
            //   _myEVoucherExpanded ? 10 : 2,
            //   (index) => CouponEVoucherCardWidget(
            //     key: ValueKey(index),
            //     title: index.toString(),
            //     description: 'description',
            //     detailUsing: 'detailUsing',
            //     expired: 'expired',
            //   ),
            // ),
            // _buildButtonExpandable(
            //   () {
            //     setState(() {
            //       _myEVoucherExpanded = !_myEVoucherExpanded;
            //     });
            //   },
            //   _myEVoucherExpanded,
            // ),
            ElevatedButton.icon(
              onPressed: null, //() => _viewModel.goPurchasePage(context),
              icon: Assets.svg.icCouponCheckRoundedGreen.svg(),
              label: AppText(
                'เลือกซื้อแพ็คเกจ E-Voucher',
                style: context.textTheme.labelLarge!.copyWith(
                  fontSize: AppDims.size_16.sp,
                ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AppText(
                    'แสดงแพ็คเกจ E-Voucher สาขาใกล้ฉัน ระยะ 25 กม.',
                    style: context.textTheme.titleSmall!.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ),
                SizedBox(
                  width: AppDims.size_30.w, // Desired width
                  height: AppDims.size_25.h, // Desired height
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: ValueListenableBuilder<bool>(
                      valueListenable:
                          widget._viewModel.showNearbyStoresNotifier,
                      builder: (context, showNearby, child) {
                        return Switch(
                          value: showNearby,
                          onChanged: (bool value) async {
                            await widget._viewModel.onNearbyStoresSwitchChanged(
                              value,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            AppDims.vericalPadding_16,

            // List E-Voucher ที่จะให้เลือกซื้อ
            ValueListenableBuilder(
              valueListenable: widget._viewModel.evoucherForSellNotifier,
              builder: (context, allStoreResult, child) {
                if (allStoreResult.isLoading) {
                  return CircularProgressIndicator();
                }

                if (allStoreResult.isEmpty || allStoreResult.hasError) {
                  // ไม่พบข้อมูลอะไร
                  return _buidlNotFoundData(context);
                }

                final evoucherForSellList =
                    allStoreResult.data?.getActivePackages() ?? [];

                final lengthList = evoucherForSellList.length;

                final needButtonExpanding =
                    evoucherForSellList.isNotEmpty && lengthList > 2;

                return Column(
                  children: [
                    ...allStoreResult.data!
                        .getActivePackages()
                        .take(_eVoucherExpanded ? lengthList : 2)
                        .map(
                          (e) => GestureDetector(
                            onTap: () =>
                                widget._viewModel.goPurchasePage(context, e),
                            child: CouponEVoucherCardWidget(
                              icon: Image.network(
                                e.couponImageDisplay(context),
                                errorBuilder: (_, _, _) => _onImageError(),
                              ),
                              title: e.couponNameDisplay(context),
                              description: e.storeNameDisplay(context),
                              detailUsing: e.usageLabelDisplay(context),
                              expired: e.usageDurationTextDisplay(context),
                              showCheckBox: false,
                              onChanged: (value) {},
                            ),
                          ),
                        ),
                    if (needButtonExpanding)
                      _buildButtonExpandable(
                        () {
                          setState(() {
                            _eVoucherExpanded = !_eVoucherExpanded;
                          });
                        },
                        _eVoucherExpanded,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonExpandable(
    VoidCallback onPressed,
    bool expanded,
  ) {
    return TextButton(
      style: context.appTheme.textButtonTheme.style!.copyWith(
        textStyle: WidgetStatePropertyAll(context.textTheme.labelLarge),
        foregroundColor: WidgetStatePropertyAll(AppColors.gray500),
      ),
      onPressed: onPressed,
      child: Column(
        children: [
          AppText(
            expanded ? 'ปิดการแสดงเพิ่มเติม' : 'แสดงเพิ่มเติม',
          ),
          expanded ? Assets.svg.icArrowUp.svg() : Assets.svg.icArrowDown.svg(),
        ],
      ),
    );
  }

  Widget _onImageError() {
    return Container(
      color: AppColors.ci2,
    );
  }

  Widget _buidlNotFoundData(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Assets.png.brownyError1.image(
            width: 145.w,
            height: 100.h,
          ),
        ),
        AppDims.vericalPadding_16,

        AppText(
          'ไม่พบคูปอง E-Voucher',
          style: context.textTheme.labelLarge!.copyWith(
            fontSize: AppDims.size_16.sp,
          ),
        ),
      ],
    );
  }
}

// Custom SliverPersistentHeaderDelegate for sticky TabBar
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return false;
  }
}
