import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/widgets/app_text.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:browny_applications_new/res/icons/assets.gen.dart';
import 'package:browny_applications_new/res/styles/app_text_style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CouponVoucherPage extends StatelessWidget {
  const CouponVoucherPage({super.key});

  static final pagePath = '/coupn_voucher';
  static final pageName = 'CouponVoucherPage';

  @override
  Widget build(BuildContext context) {
    return const _CouponVocherWidget();
  }
}

class _CouponVocherWidget extends StatefulWidget {
  const _CouponVocherWidget();

  @override
  State<_CouponVocherWidget> createState() => __CouponVocherWidgetState();
}

class __CouponVocherWidgetState extends State<_CouponVocherWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     extendBody: true,
  //     backgroundColor: AppColors.bareBackground,
  //     bottomSheet: Padding(
  //       padding: EdgeInsets.only(
  //         left: AppDims.size_24,
  //         right: AppDims.size_24,
  //         bottom: AppDims.size_32,
  //       ),
  //       child: ElevatedButton(
  //         onPressed: () {},
  //         child: AppText(
  //           'เก็บคูปอง',
  //           style: context.textTheme.labelLarge!.copyWith(
  //             color: AppColors.textWhite,
  //           ),
  //         ),
  //       ),
  //     ),
  //     body: CustomScrollView(
  //       physics: const ClampingScrollPhysics(),
  //       slivers: [
  //         // AppBar with background
  //         SliverAppBar(
  //           flexibleSpace: Transform.flip(
  //             flipX: true,
  //             child: Assets.png.bgCoinClaim.image(
  //               fit: BoxFit.cover,
  //             ),
  //           ),
  //           title: AppText(
  //             'คูปองและรหัสคูปอง',
  //             style: context.textTheme.titleLarge!.copyWith(
  //               color: AppColors.textWhite,
  //             ),
  //           ),
  //           pinned: true,
  //           floating: false,
  //         ),

  //         // ช่องกรอก, Scan Section
  //         SliverToBoxAdapter(
  //           child: Container(
  //             margin: EdgeInsets.all(AppDims.size_16),
  //             padding: EdgeInsets.all(AppDims.size_16),
  //             decoration: BoxDecoration(
  //               color: AppColors.background,
  //               borderRadius: BorderRadius.circular(16.r),
  //             ),
  //             child: Column(
  //               children: [
  //                 // Title
  //                 Row(
  //                   children: [
  //                     Assets.svg.icCouponEditRoundedGreen.svg(),
  //                     AppDims.horizonPadding_8,
  //                     AppText(
  //                       'รหัสและการสแกน',
  //                       style: context.textTheme.labelLarge!.copyWith(
  //                         fontSize: AppDims.size_16.sp,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 AppDims.vericalPadding_8,

  //                 // ช่องกรอก
  //                 Row(
  //                   children: [
  //                     Expanded(
  //                       flex: 4,
  //                       child: Container(
  //                         padding: EdgeInsets.symmetric(
  //                           horizontal: AppDims.size_16,
  //                         ),
  //                         decoration: BoxDecoration(
  //                           color: AppColors.background,
  //                           border: BoxBorder.fromLTRB(
  //                             bottom: BorderSide(
  //                               color: AppColors.border,
  //                               width: 1.w,
  //                             ),
  //                             left: BorderSide(
  //                               color: AppColors.border,
  //                               width: 1.w,
  //                             ),
  //                             top: BorderSide(
  //                               color: AppColors.border,
  //                               width: 1.w,
  //                             ),
  //                           ),
  //                           borderRadius: BorderRadius.only(
  //                             bottomLeft: Radius.circular(8.r),
  //                             topLeft: Radius.circular(8.r),
  //                           ),
  //                         ),
  //                         child: TextField(
  //                           decoration: InputDecoration(
  //                             hintText: 'ใส่รหัสคูปองของคุณได้ที่นี่',
  //                             border: InputBorder.none,
  //                             enabledBorder: InputBorder.none,
  //                             focusedBorder: InputBorder.none,
  //                             contentPadding: EdgeInsets.zero,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     Expanded(
  //                       flex: 2,
  //                       child: Container(
  //                         padding: EdgeInsets.symmetric(
  //                           horizontal: AppDims.size_8,
  //                         ),
  //                         decoration: BoxDecoration(
  //                           color: AppColors.gray400,
  //                           border: BoxBorder.all(
  //                             color: AppColors.border,
  //                             width: 1.w,
  //                           ),
  //                           borderRadius: BorderRadius.only(
  //                             bottomRight: Radius.circular(8.r),
  //                             topRight: Radius.circular(8.r),
  //                           ),
  //                         ),
  //                         child: AppTextFormField(
  //                           enabled: false,
  //                           decoration: InputDecoration(
  //                             prefixIcon: Padding(
  //                               padding: EdgeInsets.symmetric(
  //                                 horizontal: 6.w,
  //                               ),
  //                               child: Assets.svg.icMagnify.svg(
  //                                 colorFilter: ColorFilter.mode(
  //                                   AppColors.white,
  //                                   BlendMode.srcIn,
  //                                 ),
  //                               ),
  //                             ),
  //                             prefixIconConstraints: BoxConstraints(
  //                               minWidth: 12,
  //                               minHeight: 12,
  //                             ),
  //                             hintStyle: context.textTheme.labelLarge!.copyWith(
  //                               color: AppColors.textWhite,
  //                             ),
  //                             hintText: 'ใช้คูปอง',
  //                             border: InputBorder.none,
  //                             enabledBorder: InputBorder.none,
  //                             disabledBorder: InputBorder.none,
  //                             focusedBorder: InputBorder.none,
  //                             contentPadding: EdgeInsets.zero,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 AppDims.vericalPadding_8,

  //                 // ปุ่มเปิดกล้อง Scan
  //                 ElevatedButton.icon(
  //                   onPressed: () {},
  //                   label: AppText('สแกนคูปอง'),
  //                   iconAlignment: IconAlignment.end,
  //                   icon: Assets.svg.icScan3.svg(width: 16.w, height: 16.h),
  //                   style: context.appTheme.elevatedButtonTheme.style!.copyWith(
  //                     backgroundColor: WidgetStatePropertyAll(
  //                       AppColors.ci3,
  //                     ),
  //                     foregroundColor: WidgetStatePropertyAll(
  //                       AppColors.ci,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),

  //         // TabBar
  //         SliverPersistentHeader(
  //           pinned: true,
  //           delegate: _StickyTabBarDelegate(
  //             TabBar(
  //               controller: _tabController,
  //               dividerColor: AppColors.transparent,
  //               indicatorPadding: EdgeInsets.symmetric(horizontal: 8.w),
  //               indicatorSize: TabBarIndicatorSize.tab,
  //               labelStyle: context.textTheme.titleMedium!.copyWith(
  //                 color: AppColors.primary,
  //               ),
  //               unselectedLabelStyle: context.textTheme.titleMedium!.copyWith(
  //                 color: AppColors.grey500,
  //               ),
  //               tabs: [
  //                 Tab(child: AppText('ซักอบ')),
  //                 Tab(child: AppText('E-Voucher')),
  //                 Tab(child: AppText('Browny Shop')),
  //               ],
  //             ),
  //           ),
  //         ),

  //         SliverFillRemaining(
  //           child: Container(
  //             color: AppColors.background,
  //             child: TabBarView(
  //               controller: _tabController,
  //               children: [
  //                 // ซักอบ
  //                 _buildTabContent(
  //                   context: context,
  //                   icon: Assets.svg.icCouponWashRoundedGreen.svg(),
  //                   title: 'ซักอบ',
  //                 ),

  //                 // E-Voucher
  //                 _buildTabContent(
  //                   context: context,
  //                   icon: Assets.svg.icCouponCheckRoundedGreen.svg(),
  //                   title: 'E-Voucher ของฉัน',
  //                 ),

  //                 // Browny Shop
  //                 _buildTabContent(
  //                   context: context,
  //                   icon: Assets.svg.icCouponCheckRoundedGreen.svg(),
  //                   title: 'Browny Shop',
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bareBackground,
      body: NestedScrollView(
        physics: const RangeMaintainingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // AppBar with background
            SliverAppBar(
              flexibleSpace: FlexibleSpaceBar(
                background: Transform.flip(
                  flipX: true,
                  child: Assets.png.bgCoinClaim.image(
                    fit: BoxFit.cover,
                  ),
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
                      label: AppText('สแกนคูปอง'),
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
                    color: AppColors.grey500,
                  ),
                  tabs: [
                    Tab(child: AppText('ซักอบ')),
                    Tab(child: AppText('E-Voucher')),
                    Tab(child: AppText('Browny Shop')),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Container(
          height: 500,
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
              _buildTabContent(
                context: context,
                icon: Assets.svg.icCouponCheckRoundedGreen.svg(),
                title: 'E-Voucher ของฉัน',
              ),

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
                          AppText(
                            'Detail using',
                            style: context.textTheme.bodySmall?.copyWith(
                              fontSize: AppDims.size_10.sp,
                              color: AppColors.textSecondary,
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

/// Model สำหรับ Dropdown Item ที่รองรับ Generic Type
class DropdownItem<T> {
  final T value;
  final String label;
  final bool selectable;
  final Widget? labelWidget;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  const DropdownItem({
    required this.value,
    required this.label,
    this.selectable = true,
    this.leadingIcon,
    this.labelWidget,
    this.trailingIcon,
  });
}

class CustomDropdown<T> extends StatefulWidget {
  final List<DropdownItem<T>> items;
  final String hint;
  final ValueChanged<T?>? onChanged;
  final T? selectedValue;
  final VoidCallback? onNoItemsFound;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.hint,
    this.onChanged,
    this.selectedValue,
    this.onNoItemsFound,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  bool _isOpen = false;
  T? _selectedValue;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  void dispose() {
    _removeOverlay();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<DropdownItem<T>> get _filteredItems {
    if (_searchQuery.isEmpty) {
      return widget.items;
    }
    return widget.items
        .where(
          (item) =>
              item.label.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  String get _selectedLabel {
    if (_selectedValue == null) return widget.hint;
    final item = widget.items.firstWhere(
      (item) => item.value == _selectedValue,
      orElse: () =>
          DropdownItem<T>(value: _selectedValue as T, label: widget.hint),
    );
    return item.label;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _createOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    // Trigger callback if no items found
    if (_filteredItems.isEmpty && _searchQuery.isNotEmpty) {
      widget.onNoItemsFound?.call();
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 8),
          child: Material(
            elevation: 4.0,
            borderRadius: _mainRadius,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                border: BoxBorder.all(
                  width: 1.5,
                  color: AppColors.gray400,
                ),
                borderRadius: _mainRadius,
              ),
              child: _filteredItems.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AppText(
                        'No items found',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = item.value == _selectedValue;
                        return InkWell(
                          onTap: item.selectable
                              ? () => _selectItem(item.value)
                              : null,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: AppDims.size_12,
                              horizontal: AppDims.size_12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.ci3
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            margin: EdgeInsets.all(8),

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (item.leadingIcon != null) ...[
                                  item.leadingIcon!,
                                  AppDims.horizonPadding_8,
                                ],
                                Expanded(
                                  child:
                                      item.labelWidget ??
                                      AppText(
                                        item.label,
                                        textAlign: TextAlign.start,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color: AppColors.grey600,
                                            ),
                                      ),
                                ),
                                if (item.trailingIcon != null) ...[
                                  AppDims.horizonPadding_8,
                                  item.trailingIcon!,
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _autoSelectFirstItem() {
    if (_filteredItems.isNotEmpty && _filteredItems.first.selectable) {
      _selectItem(_filteredItems.first.value);
    }
  }

  void _toggleDropdown() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _focusNode.requestFocus();
        _createOverlay();
      } else {
        _focusNode.unfocus();
        _removeOverlay();
        // เคลียร์ Text Filter เมื่อปิด dropdown
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  void _selectItem(T item) {
    setState(() {
      _selectedValue = item;
      _isOpen = false;
      _searchQuery = '';
      _searchController.clear();
    });
    _focusNode.unfocus();
    _removeOverlay();
    widget.onChanged?.call(item);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                textAlign: TextAlign.start,
                style: AppTextStyles.labelLarge,
                decoration: InputDecoration(
                  hintText: _selectedLabel,
                  hintStyle: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.grey600,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: _mainRadius,
                    borderSide: BorderSide(
                      width: 1.5.w,
                      color: AppColors.gray400,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: _mainRadius,
                    borderSide: BorderSide(
                      width: 1.5.w,
                      color: AppColors.gray400,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: _mainRadius,
                    borderSide: BorderSide(
                      width: 1.5,
                      color: AppColors.gray400,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.grey500,
                    ),
                    onPressed: _toggleDropdown,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    if (!_isOpen && value.isNotEmpty) {
                      _isOpen = true;
                      _createOverlay();
                    } else if (_isOpen) {
                      _removeOverlay();
                      _createOverlay();
                    }
                  });
                },
                onTap: () {
                  if (!_isOpen) {
                    setState(() {
                      _isOpen = true;
                      _createOverlay();
                    });
                  }
                },
                onSubmitted: (value) {
                  // Auto select item แรกเมื่อกด Done บน keyboard (ถ้ามี filtered items)
                  if (_searchQuery.isNotEmpty && _filteredItems.isNotEmpty) {
                    _autoSelectFirstItem();
                  } else {
                    // ถ้าไม่มี filtered items หรือไม่ได้กรอกอะไร ให้ปิด dropdown
                    _toggleDropdown();
                  }
                },
              ),
            ),
            AppDims.horizonPadding_4,
            // Container Icon
            Material(
              color: Colors.white,
              child: InkWell(
                onTap: () {},
                borderRadius: _mainRadius,
                child: Container(
                  width: 40.w,
                  decoration: BoxDecoration(
                    border: BoxBorder.all(
                      width: 1.5.w,
                      color: AppColors.gray400,
                    ),
                    borderRadius: _mainRadius,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0.w),
                    child: Assets.svg.icLocation.svg(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BorderRadius get _mainRadius => BorderRadius.circular(8.r);
}
