// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coupon_order_response.dart';
import 'package:browny_applications_new/feature/authentication/error/authen_exception.dart';
import 'package:browny_applications_new/feature/authentication/screen/app_pin_page.dart';
import 'package:browny_applications_new/feature/contacts/models/contact_model.dart';
import 'package:browny_applications_new/feature/contacts/screens/contact_page.dart';
import 'package:browny_applications_new/feature/transactions/models/coupon_detail_model.dart';
import 'package:browny_applications_new/feature/transactions/screens/available_payment_method_page.dart';
import 'package:browny_applications_new/feature/transactions/screens/receipt_page.dart';
import 'package:browny_applications_new/feature/transactions/viewmodel/transactions_viewmodel.dart';
import 'package:browny_applications_new/feature/wallet/screen/wallet_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

class _TransactionSelectedPageState extends State<TransactionSelectedPage>
    with WidgetsBindingObserver {
  TextStyle get _textPrimary => context.textTheme.labelLarge!.copyWith(
    color: AppColors.textPrimary,
  );
  TextStyle get _textPrimarySelected => context.textTheme.labelLarge!.copyWith(
    color: AppColors.primary,
  );

  TextStyle get _textPrice => context.textTheme.headlineSmall!.copyWith(
    fontSize: AppDims.size_16.sp,
    color: AppColors.textPrimary,
  );

  late final TransactionsViewmodel _viewmodel;
  bool _paymentProcessing = false;

  Timer? _pollingTimer;
  CouponOrderData? _currentOrderData;
  bool _isPolling = false;

  @override
  void initState() {
    super.initState();
    _viewmodel = widget.viewmodel;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewmodel.fetchPaymentMethod(context);
    });
  }

  @override
  void dispose() {
    _stopPolling();
    WidgetsBinding.instance.removeObserver(this);
    _viewmodel.disposeTransaction();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && _isPolling) {
      // App resumed - check payment status immediately
      _checkPaymentStatus();
    }
  }

  void _startPolling(CouponOrderData orderData) {
    _currentOrderData = orderData;
    _isPolling = true;

    // Check immediately
    _checkPaymentStatus();

    // Start periodic timer (5 seconds)
    _pollingTimer = Timer.periodic(Duration(seconds: 5), (_) {
      _checkPaymentStatus();
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
    _currentOrderData = null;
  }

  Future<void> _checkPaymentStatus() async {
    if (_currentOrderData == null) return;

    final result = await _viewmodel.checkPaymentStatus(_currentOrderData!);

    if (!mounted || !context.mounted) return;

    if (result.isSuccess && result.data != null) {
      final status = result.data!;

      if (status.isPaid) {
        // Payment successful
        _stopPolling();

        // Close WebView if open
        if (_paymentProcessing && context.canPop()) {
          context.pop();
        }
        await _viewmodel.fetchCouponReceipt();
        ReceiptPage.goReplacementPage(
          context,
          viewmodel: _viewmodel,
        );
      } else if (status.isNotFound) {
        // Order not found
        _stopPolling();

        if (context.canPop()) {
          context.pop();
        }

        AppOverlays.showBrownyDialog(
          context,
          imageAsset: Assets.png.brownyError2.path,
          title: 'ไม่พบรายการ',
          message: 'ไม่พบรายการสั่งซื้อนี้',
          confirmText: 'ตกลง',
          onConfirm: () {},
        );
      }
      // If pending, continue polling
    }
  }

  void onPurchaseClicked() async {
    final result = await _viewmodel.verifyOrder();
    if (!mounted) return;

    if (result.isEmpty && _viewmodel.paymentSelected!.isTpWallet) {
      AppOverlays.showBrownyDialog(
        context,
        title: 'TP+ Wallet เงินไม่เพียงพอ',
        message: 'กรุณาเติมเงิน หรือเปลี่ยนวิธีการชำระเงิน',
      );
      return;
    }
    TransactionAuthenPage.goToPage(context).then((
      result,
    ) async {
      if (!context.mounted) return;

      if (result is bool) {
        if (result) {
          // _startPolling(CouponOrderData(paymentRef: '20260208150706'));
          // return;

          AppOverlays.showLoading(context);
          final orderResult = await _viewmodel.createCouponOrder();

          if (!context.mounted) return;
          AppOverlays.hideLoading();

          if (orderResult.isSuccess) {
            final orderResponse = orderResult.data!;
            final orderData = orderResponse.data;

            if (orderData == null) {
              AppOverlays.showBrownyDialog(
                context,
                message: 'ไม่สามารถสร้างคำสั่งซื้อได้',
              );
              return;
            }

            // Start polling for payment status
            _startPolling(orderData);

            // Show WebView
            WebViewController? controller;
            _paymentProcessing = true;
            await showModalBottomSheet(
              context: context,
              showDragHandle: true,
              enableDrag: false,
              isScrollControlled: true,
              isDismissible: false,
              builder: (dialogContext) {
                controller = WebViewController()
                  ..setJavaScriptMode(
                    JavaScriptMode.unrestricted,
                  )
                  ..setBackgroundColor(AppColors.background)
                  ..loadRequest(
                    Uri.parse(orderResponse.redirectUrl!),
                  );
                return SizedBox(
                  height: 812.h * 0.85,
                  child: WebViewWidget(controller: controller!),
                );
              },
            );
            controller?.clearCache();
            _paymentProcessing = false;
            _stopPolling();
            await _checkPaymentStatus();
            return;
          }

          AppOverlays.showBrownyDialog(
            context,
            message: orderResult.error.toString(),
          );
          return;
        }
        return;
      }
      // Handler develop
      // ถ้าส่ง type มาผิดจะ throw ให้ App Error
      throw Unprocessable();
    });
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
        ValueListenableBuilder(
          valueListenable: _viewmodel.paymentMethodNotifier,
          builder: (context, value, child) {
            return Container(
              padding: EdgeInsets.only(
                left: AppDims.size_24.w,
                right: AppDims.size_24.w,
                top: AppDims.size_8.h,
              ),
              child: ElevatedButton(
                onPressed: value.isSuccess ? onPurchaseClicked : null,
                child: AppText(context.wording.makePayment),
              ),
            );
          },
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
            onPressed: () {
              ContactPage.goToPage(context, ContactProvider.helpAndProblemNoti);
            },
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
                  ValueListenableBuilder(
                    valueListenable: _viewmodel.paymentMethodNotifier,
                    builder: (context, value, child) {
                      if (value.isLoading) {
                        return _card(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (value.hasError) {
                        return _card(
                          child: AppText(context.wording.errorUi),
                        );
                      }

                      return _card(
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

                                // ดูประเภทชำระทั้งหมด
                                GestureDetector(
                                  onTap: () {
                                    context.pushNamed(
                                      AvailablePaymentMethodPage.pageName,
                                      extra: _viewmodel,
                                    );
                                  },
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
                            AppDims.vericalPadding_8,

                            // ประเภทชำระแต่ละละแบบ ตามที่ API ส่งมา
                            ...value.data!
                                .take(3)
                                .map(
                                  (payment) => _cardPaymentDependOnState(
                                    isTPWallet:
                                        payment.isSelected &&
                                        payment.method == 'tp_wallet',
                                    selected: payment.isSelected,
                                    child: ListTile(
                                      minVerticalPadding: 0,
                                      contentPadding: EdgeInsets.zero,
                                      minTileHeight: 0,
                                      horizontalTitleGap: AppDims.size_8.w,
                                      leading: payment.icon,
                                      title: AppText(
                                        payment.name,
                                        style: payment.isSelected
                                            ? _textPrimarySelected
                                            : _textPrimary,
                                      ),
                                      onTap: () {
                                        _viewmodel.onPaymentChanged(
                                          payment,
                                        );
                                      },
                                      trailing: payment.isSelected
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                right: 6.0.w,
                                              ),
                                              child: Assets.svg.icChecked.svg(),
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      );
                    },
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
    required bool isTPWallet,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppDims.size_8.h),
      padding: EdgeInsets.symmetric(
        horizontal: selected ? AppDims.size_16.w : AppDims.size_8.w,
        vertical: selected ? AppDims.size_16.h : AppDims.size_8.h,
      ),
      decoration: selected
          ? BoxDecoration(
              border: BoxBorder.all(
                color: AppColors.primary,
                width: AppDims.size_2.h,
              ),
              borderRadius: BorderRadius.circular(
                AppDims.size_8.r,
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          child,
          if (isTPWallet) ...[
            Consumer<CustomerProvider>(
              builder: (context, provider, _) {
                return ListTile(
                  minVerticalPadding: AppDims.size_8.h,
                  contentPadding: EdgeInsets.zero,
                  minTileHeight: 0,
                  horizontalTitleGap: AppDims.size_8.w,
                  title: AppText(
                    'จำนวนเงินคงเหลือ',
                    style: _textPrimary,
                  ),
                  trailing: AppText(
                    formatCurrency(
                      leadingSign: '฿ ',
                      string: provider.current.creditBalance,
                      decimal: true,
                    ),
                    style: _textPrimarySelected.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),

            ElevatedButton(
              onPressed: () {
                context.pushNamed(WalletPage.pageName);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(54.w, 30.h),
              ),
              child: AppText(
                context.wording.topup,
                style: context.textTheme.labelMedium!.copyWith(
                  color: AppColors.textWhite,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
