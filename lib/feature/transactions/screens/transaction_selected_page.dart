import 'package:browny_applications_new/core/const/app_constants.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coupon_detail_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/widgets/app_text.dart';
import 'package:browny_applications_new/core/widgets/coupon_e_voucher_card_widget.dart';
import 'package:browny_applications_new/feature/transactions/models/coupon_detail_model.dart';
import 'package:browny_applications_new/feature/transactions/viewmodel/transactions_viewmodel.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:browny_applications_new/res/icons/assets.gen.dart';
import 'package:browny_applications_new/res/strings/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransactionSelectedPage extends StatefulWidget {
  const TransactionSelectedPage({
    super.key,
    required this.viewmodel,
  });

  final TransactionsViewmodel viewmodel;

  static final pagePath = '/transaction_selected';
  static final pageName = 'transaction_selected';

  @override
  State<TransactionSelectedPage> createState() =>
      _TransactionSelectedPageState();
}

class _TransactionSelectedPageState extends State<TransactionSelectedPage> {
  TextStyle get _textPrimary => context.textTheme.labelLarge!.copyWith(
    color: AppColors.textPrimary,
  );

  TextStyle get _textPrice => context.textTheme.headlineSmall!.copyWith(
    fontSize: AppDims.size_16.sp,
    color: AppColors.textPrimary,
  );

  late final TransactionsViewmodel _viewmodel;

  @override
  void initState() {
    super.initState();
    _viewmodel = widget.viewmodel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterDecoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5), // Shadow color
            spreadRadius: 1, // How much the shadow should spread
            blurRadius: 10, // How soft the shadow should be
            offset: Offset(0, -2), // Negative dy value moves the shadow upwards
          ),
        ],
      ),
      persistentFooterButtons: [
        // ปุ่มยืนยันซื้อคูปอง
        Container(
          padding: EdgeInsets.only(
            left: AppDims.size_24.w,
            right: AppDims.size_24.w,
            top: AppDims.size_8.h,
          ),
          child: ElevatedButton(
            onPressed: () {},
            child: AppText(context.wording.makePayment),
          ),
        ),
      ],
      appBar: AppBar(
        title: AppText(
          'ทำการสั่งซื้อ',
          style: context.appBarTextThemeWhite,
        ),
        actions: [
          // แจ้งปัญหา
          IconButton(
            onPressed: () {},
            icon: Assets.svg.icHeadset.svg(),
          ),
        ],
        flexibleSpace: FlexibleSpaceBar(
          background: Assets.png.bgAppBar.image(
            fit: BoxFit.cover,
          ),
        ),
      ),
      backgroundColor: AppColors.bareBackground,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: AppDims.size_14.w,
            right: AppDims.size_14.w,
            top: AppDims.size_16.h,
          ),
          child: ValueListenableBuilder(
            valueListenable: _viewmodel.selectedPackageNotifier!,
            builder: (context, package, child) {
              return Column(
                children: [
                  // สาขา
                  _card(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Assets.svg.icLocationRoundedGreen.svg(),
                        AppDims.horizonPadding_8,

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              context.wording.stores,
                              style: _textPrimary,
                            ),
                            AppText(
                              package!.storeNameDisplay(context),
                              style: context.textTheme.labelLarge!.copyWith(
                                color: AppColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // คูปองและรหัสคูปองที่จะใช้ ปิดไปก่อน ยังใช้ไม่ได้
                  // Visibility(
                  //   visible: false,
                  //   child: _card(
                  //     child: Column(
                  //       children: [
                  //         AppDims.vericalPadding_14,

                  //         // Title
                  //         Row(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Assets.svg.icCouponRoundGreen.svg(),
                  //             AppDims.horizonPadding_8,

                  //             Expanded(
                  //               child: Row(
                  //                 mainAxisAlignment:
                  //                     MainAxisAlignment.spaceBetween,
                  //                 children: [
                  //                   SizedBox(
                  //                     child: AppText(
                  //                       'คูปองและรหัสคูปอง',
                  //                       style: _textPrimary,
                  //                     ),
                  //                   ),
                  //                   GestureDetector(
                  //                     onTap: () {},
                  //                     child: Assets.svg.icArrowForward.svg(),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //         AppDims.vericalPadding_8,

                  //         CouponEVoucherCardWidget(
                  //           title: 'title',
                  //           description: 'description',
                  //           detailUsing: 'detailUsing',
                  //           expired: 'expired',
                  //           borderColor: AppColors.checkboxSelectedBg,
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  AppDims.vericalPadding_14,

                  // สินค้าที่กำลังจะซื้อ
                  ValueListenableBuilder(
                    valueListenable: _viewmodel.couponDetailNotifier!,
                    builder: (context, couponDetailResult, child) {
                      // Success state - get data
                      final couponDetail = couponDetailResult.data!;
                      final couponData = couponDetail.coupon!;

                      // Use selected package or fallback to first package
                      final packageData = package;
                      return _card(
                        child: Column(
                          children: [
                            // Title
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Assets.svg.icLikeBadgeRoundedGreen.svg(),
                                AppDims.horizonPadding_8,

                                SizedBox(
                                  child: AppText(
                                    context.wording.products,
                                    style: _textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            AppDims.vericalPadding_8,

                            _buildItemCard(
                              context,
                              couponData,
                              packageData,
                              couponDetail,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  AppDims.vericalPadding_14,

                  // ประเภทชำระ
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Row(
                          children: [
                            Assets.svg.icWalletRoundedGreen.svg(),
                            AppDims.horizonPadding_8,

                            Expanded(
                              child: AppText(
                                'เลือกวิธีชำระเงิน',
                                style: _textPrimary,
                              ),
                            ),

                            GestureDetector(
                              onTap: () {},
                              child: Row(
                                children: [
                                  AppText(
                                    'ดูทั้งหมด',
                                    style: _textPrimary,
                                  ),
                                  AppDims.horizonPadding_8,
                                  Assets.svg.icArrowForward.svg(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        AppDims.vericalPadding_16,

                        _cardPaymentDependOnState(
                          selected: false,
                          child: ListTile(
                            minVerticalPadding: 0,
                            contentPadding: EdgeInsets.zero,
                            minTileHeight: 0,
                            horizontalTitleGap: AppDims.size_8.w,
                            leading: Assets.svg.icBahtRoundedGreen.svg(
                              width: 22.w,
                              height: 22.h,
                            ),
                            title: AppText(
                              'Qr พร้อมเพย์',
                              style: _textPrimary,
                            ),
                            trailing: Padding(
                              padding: EdgeInsets.only(right: 6.0.w),
                              child: Assets.svg.icChecked.svg(),
                            ),
                          ),
                        ),
                        AppDims.vericalPadding_24,

                        _cardPaymentDependOnState(
                          selected: true,
                          child: ListTile(
                            minVerticalPadding: 0,
                            contentPadding: EdgeInsets.zero,
                            minTileHeight: 0,
                            horizontalTitleGap: AppDims.size_8.w,
                            leading: Assets.svg.icTpWallet.svg(
                              width: 22.w,
                              height: 22.h,
                            ),
                            title: AppText(
                              'TP+ Wallet',
                              style: _textPrimary,
                            ),
                            // trailing: Padding(
                            //   padding: EdgeInsets.only(right: 6.0.w),
                            //   child: Assets.svg.icChecked.svg(),
                            // ),
                          ),
                        ),
                        AppDims.vericalPadding_24,

                        _cardPaymentDependOnState(
                          child: ListTile(
                            minVerticalPadding: 0,
                            contentPadding: EdgeInsets.zero,
                            minTileHeight: 0,
                            horizontalTitleGap: AppDims.size_8.w,
                            leading: Assets.png.brownyCoin.image(
                              width: 25.w,
                              height: 25.h,
                            ),
                            title: AppText(
                              'Browny Coin',
                              style: _textPrimary,
                            ),
                            // trailing: Padding(
                            //   padding: EdgeInsets.only(right: 6.0.w),
                            //   child: Assets.svg.icChecked.svg(),
                            // ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppDims.vericalPadding_14,

                  // สรุปยอดเงิน
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Row(
                          children: [
                            Assets.svg.icListRoundedGreen.svg(),
                            AppDims.horizonPadding_8,

                            AppText(
                              'สรุปการสั่งซื้อ',
                              style: _textPrimary,
                            ),
                          ],
                        ),
                        AppDims.vericalPadding_16,

                        // detail
                        // Title
                        _lineSummay(
                          title: 'สรุปการสั่งซื้อ',
                          price: package.price.ifNullOrEmpty('0.0'),
                        ),
                        AppDims.vericalPadding_16,
                        // ส่วนลดถ้ามี
                        _lineSummay(
                          title: 'ส่วนลดสินค้า',
                          price: '0',
                        ),
                        AppDims.vericalPadding_16,
                        // สรุปยอด
                        _lineSummay(
                          title: 'ยอดชำระทั้งหมด',
                          price: package.price.ifNullOrEmpty('0.0'),
                          textPriceColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),

                  AppDims.vericalPadding_14,
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    CouponData couponData,
    PackageDetailData packageData,
    CouponDetailModel couponDetail,
  ) {
    return CouponEVoucherCardWidget(
      icon: Image.network(
        couponData.couponImageDisplay(context),
        errorBuilder: (_, _, _) => _onImageError(),
      ),
      title: packageData.packageNameDisplay(context),
      description: packageData.storeNameDisplay(context),
      detailUsing: packageData.usageLabelDisplay(context),
      expired: couponData.usageDurationTextDisplay(context),
    );
  }

  Widget _onImageError() {
    return Container(
      color: AppColors.ci2,
    );
  }

  Widget _lineSummay({
    required String title,
    required String price,
    Color? textPriceColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          title,
          style: _textPrimary,
        ),

        AppText(
          formatCurrency(
            string: price,
            decimal: true,
            leadingSign: '฿',
          ),
          style: _textPrice.copyWith(color: textPriceColor),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppDims.size_16.w,
        vertical: AppDims.size_16.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: child,
    );
  }

  Widget _cardPaymentDependOnState({
    bool selected = false,
    required Widget child,
  }) {
    return Container(
      padding: selected ? EdgeInsets.all(AppDims.size_16) : null,
      decoration: selected
          ? BoxDecoration(
              border: BoxBorder.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(
                AppDims.size_8.r,
              ),
            )
          : null,
      child: child,
    );
  }
}
