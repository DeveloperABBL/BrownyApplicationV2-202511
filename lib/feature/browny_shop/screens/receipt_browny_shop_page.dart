import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/browny_shop_receipt_response.dart';
import 'package:browny_applications_new/core/utils/share_helper.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:browny_applications_new/feature/browny_shop/screens/browny_shop_order_status_page.dart';
import 'package:browny_applications_new/feature/browny_shop/viewmodel/browny_shop_receipt_viewmodel.dart';
import 'package:browny_applications_new/feature/home/screens/home_page.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

/// หน้าใบเสร็จ Browny Shop — รับ [orderId] แล้วสร้าง VM ข้างใน
class ReceiptBrownyShop extends StatelessWidget {
  const ReceiptBrownyShop({super.key, required this.orderId});

  static final pagePath = '/receipt_browny_shop';
  static final pageName = 'ReceiptBrownyShop';

  final String orderId;

  static Future<T?> goToPage<T>(
    BuildContext context, {
    required String orderId,
  }) async =>
      context.pushNamed(ReceiptBrownyShop.pageName, extra: orderId);

  static void goReplacementPage(
    BuildContext context, {
    required String orderId,
  }) =>
      context.pushReplacementNamed(ReceiptBrownyShop.pageName, extra: orderId);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => BrownyShopReceiptViewModel(
        context: ctx,
        repo: BrownyShopRepo(),
        orderId: orderId,
      ),
      child: const _ReceiptBrownyShopWidget(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// StatefulWidget — GlobalKey สำหรับ capture + share/save
// ─────────────────────────────────────────────────────────────────

class _ReceiptBrownyShopWidget extends StatefulWidget {
  const _ReceiptBrownyShopWidget();

  @override
  State<_ReceiptBrownyShopWidget> createState() =>
      _ReceiptBrownyShopWidgetState();
}

class _ReceiptBrownyShopWidgetState extends State<_ReceiptBrownyShopWidget> {
  final GlobalKey _receiptKey = GlobalKey();

  BrownyShopReceiptViewModel get _vm =>
      context.read<BrownyShopReceiptViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _vm.attachContext(context);
    });
  }

  Future<Uint8List?> _captureWidget() async {
    try {
      final boundary =
          _receiptKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> _shareReceipt() async {
    final bytes = await _captureWidget();
    if (bytes == null) {
      if (!mounted) return;
      _showSnack(context.wording.errorOccurred, isError: true);
      return;
    }
    if (!mounted) return;
    await ShareHelper.shareImage(
      bytes,
      fileName: 'browny_shop_receipt.png',
      text: context.wording.brownyReceipt,
    );
  }

  Future<void> _saveReceipt() async {
    final bytes = await _captureWidget();
    if (bytes == null) {
      if (!mounted) return;
      _showSnack(context.wording.errorOccurred, isError: true);
      return;
    }
    final result = await ImageGallerySaverPlus.saveImage(
      bytes,
      quality: 100,
      name: 'browny_shop_receipt',
    );
    if (!mounted) return;
    if (result['isSuccess'] == true) {
      _showSnack(context.wording.saveTheReceipt);
    } else {
      _showSnack(context.wording.cannotSaveQRCode, isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText(
          message,
          style: context.textTheme.labelLarge!.copyWith(
            color: AppColors.white,
          ),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(
          horizontal: AppDims.size_24.w,
          vertical: AppDims.size_16.h,
        ),
      ),
    );
  }

  void _popToHome() {
    context.popUntil(
      predicate: (route) => route.name.orEmpty == HomePage.pageName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: AppColors.textPrimary,
          onPressed: _popToHome,
        ),
        title: AppText(
          context.wording.receipt,
          style: context.textTheme.titleLarge!.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      persistentFooterDecoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      persistentFooterButtons: [
        Container(
          padding: EdgeInsets.fromLTRB(
            AppDims.size_24.w,
            AppDims.size_16.h,
            AppDims.size_24.w,
            AppDims.size_8.h,
          ),
          child: Column(
            spacing: AppDims.size_16.h,
            children: [
              ElevatedButton(
                onPressed: _popToHome,
                child: AppText(context.wording.backToHome),
              ),
              GestureDetector(
                onTap: () => BrownyShopOrderStatusPage.goReplacementPage(
                  context,
                  orderId: _vm.orderId,
                ),
                child: Container(
                  width: double.infinity,
                  height: AppDims.size_40.h,
                  decoration: BoxDecoration(
                    color: AppColors.ci3,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: AppText(
                    context.wording.checkStatus,
                    style: context.textTheme.labelLarge?.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.ci,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== Capturable receipt card =====
            _capturableArea(
              child: ValueListenableBuilder(
                valueListenable: _vm.receiptNotifier,
                builder: (context, result, _) {
                  if (result.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (result.hasError) {
                    return Padding(
                      padding: EdgeInsets.all(AppDims.size_24.w),
                      child: Center(
                        child: AppText(result.error.toString()),
                      ),
                    );
                  }
                  if (!result.isSuccess || result.data == null) {
                    return Padding(
                      padding: EdgeInsets.all(AppDims.size_24.w),
                      child: Center(
                        child: AppText(context.wording.receiptNotFound),
                      ),
                    );
                  }
                  return _ReceiptContent(receipt: result.data!);
                },
              ),
            ),

            AppDims.vericalPadding_24,

            // ===== Share + Save =====
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  icon: Assets.svg.icShare.svg(),
                  label: context.wording.share,
                  onTap: _shareReceipt,
                ),
                AppDims.horizonPadding_32,
                _ActionButton(
                  icon: Assets.svg.icDownStorage.svg(),
                  label: context.wording.saveTheReceipt,
                  onTap: _saveReceipt,
                ),
              ],
            ),

            AppDims.vericalPadding_32,

            // ===== Review card =====
            _ReviewCard(vm: _vm),

            AppDims.vericalPadding_32,

            // ===== Browny Care + LINE =====
            ValueListenableBuilder(
              valueListenable: _vm.receiptNotifier,
              builder: (context, result, _) {
                if (!result.isSuccess || result.data == null) {
                  return const SizedBox.shrink();
                }
                final d = result.data!;
                return _SupportRow(
                  callCenter: d.callCenter.orEmpty,
                  lineLink: d.lineLink.orEmpty,
                );
              },
            ),

            AppDims.vericalPadding_32,
          ],
        ),
      ),
    );
  }

  Widget _capturableArea({required Widget child}) {
    return RepaintBoundary(
      key: _receiptKey,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.all(AppDims.size_15.w),
        decoration: BoxDecoration(
          color: AppColors.background,
          image: DecorationImage(
            alignment: AlignmentGeometry.topCenter,
            image: Assets.png.bgPawnPattern.provider(),
            repeat: ImageRepeat.repeatY,
            isAntiAlias: true,
            opacity: 0.15,
          ),
          borderRadius: BorderRadius.circular(AppDims.size_16.r),
          boxShadow: AppColors.defatultShadow,
        ),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Receipt content (inside the capturable card)
// ─────────────────────────────────────────────────────────────────

class _ReceiptContent extends StatelessWidget {
  const _ReceiptContent({required this.receipt});

  final BrownyShopReceiptResponse receipt;

  @override
  Widget build(BuildContext context) {
    final summary = receipt.summary;
    final shipping = receipt.shippingAddress;
    final hasLucky =
        receipt.luckyImage != null && receipt.luckyImage!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDims.size_24.w,
          ).copyWith(top: AppDims.size_24.h),
          child: Column(
            children: [
              Center(
                child: Assets.png.brownySuccess.image(
                  width: AppDims.size_100.w,
                ),
              ),
              AppDims.vericalPadding_4,
              Center(
                child: AppText(
                  context.wording.operationSuccessful,
                  style: context.textTheme.titleMedium!.copyWith(
                    color: AppColors.textBlack,
                  ),
                ),
              ),
              Center(
                child: AppText(
                  receipt.paidAt?.formatDateDDMMMMyyyyHHmmMinText(
                        context.languageCode,
                      ) ??
                      '',
                  style: context.textTheme.bodySmall!.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ),
              AppDims.vericalPadding_8,
              const Divider(),
              AppDims.vericalPadding_4,
              Center(
                child: AppText(
                  formatCurrency(string: receipt.priceFinal, leadingSign: '฿'),
                  style: context.textTheme.displayLarge!.copyWith(
                    color: AppColors.primary,
                    fontSize: AppDims.size_36.sp,
                  ),
                ),
              ),
              // ── Browny Coin Bonus ──
              if (receipt.bonus.orEmpty.isNotEmpty) ...[
                AppDims.vericalPadding_4,
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: AppDims.size_2.h,
                      horizontal: AppDims.size_8.w,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.walletCoinBonusGradient,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Assets.png.brownyCoin.image(width: 20.w, height: 20.w),
                        SizedBox(width: 8.w),
                        AppText(
                          // คุณได้รับโบนัส
                          context.wording.youReceivedBonus,
                          style: context.textTheme.labelMedium!.copyWith(
                            color: AppColors.cocoaBrown,
                          ),
                        ),
                        AppText(
                          ' Browny Coin ${formatCurrency(string: receipt.bonus, leadingSign: '+ ')}',
                          style: context.textTheme.labelMedium!.copyWith(
                            color: AppColors.cocoaBrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              AppDims.vericalPadding_8,
            ],
          ),
        ),

        // ── Info rows ──
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDims.size_24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Row(leading: 'Order ID', trailing: receipt.receiptNo.orEmpty),
              _Row(
                leading: context.wording.dateTime,
                trailing:
                    receipt.paidAt?.formatDateLocale(context.languageCode) ??
                    '',
              ),
              _Row(
                leading: context.wording.paymentMethod,
                trailingWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppText(
                      receipt.paymentDisplay
                              ?.getTextByLocale(context.languageCode)
                              .orEmpty ??
                          receipt.paymentChannel.orEmpty,
                      style: context.textTheme.titleMedium!.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                    if (receipt.paymentIcon.orEmpty.isNotEmpty)
                      Image.network(
                        receipt.paymentIcon!,
                        width: AppDims.size_30.w,
                        height: AppDims.size_30.h,
                        errorBuilder: (_, e, st) => const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
              const Divider(),

              // ── การสั่งซื้อ section ──
              _SectionHeader(context.wording.orderShopping),
              _Row(
                leading:
                    summary?.quantity?.wording
                        ?.getTextByLocale(context.languageCode)
                        .orEmpty ??
                    'จำนวน',
                trailing: receipt.totalQuantity?.toString() ?? '-',
              ),
              _Row(
                leading:
                    summary?.subtotal?.wording
                        ?.getTextByLocale(context.languageCode)
                        .orEmpty ??
                    context.wording.totalAmount,
                trailing: formatCurrency(
                  string: summary?.subtotal?.amount,
                  leadingSign: '฿',
                ),
              ),
              _Row(
                leading:
                    summary?.discount?.wording
                        ?.getTextByLocale(context.languageCode)
                        .orEmpty ??
                    context.wording.storePromotion,
                trailingWidget: AppText(
                  formatCurrency(
                    string: summary?.discount?.amount,
                    leadingSign: _isNegative(summary?.discount?.amount)
                        ? '-฿'
                        : '฿',
                  ),
                  style: context.textTheme.titleMedium!.copyWith(
                    color: _isNegative(summary?.discount?.amount)
                        ? AppColors.error
                        : AppColors.gray600,
                  ),
                ),
              ),
              _Row(
                leading:
                    summary?.couponDiscount?.wording
                        ?.getTextByLocale(context.languageCode)
                        .orEmpty ??
                    context.wording.discountCoupon,
                trailingWidget: AppText(
                  formatCurrency(
                    string: summary?.couponDiscount?.amount,
                    leadingSign: _isNegative(summary?.couponDiscount?.amount)
                        ? '-฿'
                        : '฿',
                  ),
                  style: context.textTheme.titleMedium!.copyWith(
                    color: _isNegative(summary?.couponDiscount?.amount)
                        ? AppColors.error
                        : AppColors.gray600,
                  ),
                ),
              ),
              _Row(
                leading:
                    summary?.shipping?.wording
                        ?.getTextByLocale(context.languageCode)
                        .orEmpty ??
                    context.wording.shipping,
                trailing: formatCurrency(
                  string: summary?.shipping?.amount,
                  leadingSign: '฿',
                ),
              ),
              _Row(
                leading:
                    summary?.total?.wording
                        ?.getTextByLocale(context.languageCode)
                        .orEmpty ??
                    context.wording.totalAmount,
                trailingWidget: AppText(
                  formatCurrency(
                    string: summary?.total?.amount,
                    leadingSign: '฿',
                  ),
                  style: context.textTheme.titleMedium!.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(),

              // ── ข้อมูลการจัดส่ง section ──
              _SectionHeader(context.wording.shippingInfo),
              _Row(
                leading: context.wording.recipientName,
                trailing: shipping?.recipientName.orEmpty ?? '-',
              ),
              _Row(
                leading: context.wording.phoneNumber,
                trailing: shipping?.phone.orEmpty ?? '-',
              ),
              _SectionHeader(
                context.wording.shippingAddressDetail,
                isBold: false,
              ),
              if (shipping?.fullAddress != null)
                Padding(
                  padding: EdgeInsets.only(bottom: AppDims.size_8.h),
                  child: AppText(
                    shipping!.fullAddress!,
                    style: context.textTheme.titleMedium!.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ),

              // ── QR Code ──
              if (receipt.qrImage != null && receipt.qrImage!.isNotEmpty)
                _QrCodeSection(qrImage: receipt.qrImage!),

              AppDims.vericalPadding_8,
            ],
          ),
        ),

        // ── Lucky Number banner ──
        if (hasLucky)
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.network(
              receipt.luckyImage!,
              errorBuilder: (_, e, st) => const SizedBox.shrink(),
            ),
          ),
        if (!hasLucky) SizedBox(height: AppDims.size_16.h),
      ],
    );
  }

  bool _isNegative(String? amount) {
    final v = double.tryParse(amount ?? '0') ?? 0;
    return v < 0;
  }
}

// ─────────────────────────────────────────────────────────────────
// QR Code section (right-aligned, inside receipt card)
// ─────────────────────────────────────────────────────────────────

class _QrCodeSection extends StatelessWidget {
  const _QrCodeSection({required this.qrImage});

  final String qrImage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDims.size_8.h),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFFEFEFEF),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: AppText(
                'QR Code สำหรับฝ่าย Browny Support เท่านั้น',
                style: context.textTheme.labelSmall!.copyWith(
                  color: AppColors.gray500,
                  fontSize: 10.sp,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Image.network(
              qrImage,
              width: 90.w,
              height: 90.w,
              fit: BoxFit.contain,
              errorBuilder: (_, e, st) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Review card
// ─────────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.vm});

  final BrownyShopReceiptViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: AppDims.size_15.h,
        horizontal: AppDims.size_6.w,
      ),
      margin: EdgeInsets.symmetric(horizontal: AppDims.size_15.w),
      decoration: BoxDecoration(
        gradient: AppColors.popupGradient,
        image: DecorationImage(
          image: Assets.icReviews.bgReview.provider(),
          fit: BoxFit.cover,
        ),
        border: BoxBorder.all(color: AppColors.productStroke),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        spacing: 6.h,
        children: [
          Assets.icReviews.brownyReview.image(width: AppDims.size_77.w),
          AppText(
            context.wording.rateStoreCleanlinessTitle,
            style: context.textTheme.labelLarge,
          ),
          AppDims.vericalPadding_2,
          ValueListenableBuilder<int?>(
            valueListenable: vm.reviewScoreNotifier,
            builder: (context, score, _) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDims.size_6.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ScoreItem(
                      label: context.wording.reviewVeryBad,
                      icon: Assets.icReviews.icLv1,
                      reviewScore: score,
                      selfScore: 1,
                      onTap: vm.onScoreTap,
                    ),
                    _ScoreItem(
                      label: context.wording.reviewDissatisfied,
                      icon: Assets.icReviews.icLv2,
                      reviewScore: score,
                      selfScore: 2,
                      onTap: vm.onScoreTap,
                    ),
                    _ScoreItem(
                      label: context.wording.reviewNeutral,
                      icon: Assets.icReviews.icLv3,
                      reviewScore: score,
                      selfScore: 3,
                      onTap: vm.onScoreTap,
                    ),
                    _ScoreItem(
                      label: context.wording.reviewGood,
                      icon: Assets.icReviews.icLv4,
                      reviewScore: score,
                      selfScore: 4,
                      onTap: vm.onScoreTap,
                    ),
                    _ScoreItem(
                      label: context.wording.reviewExcellent,
                      icon: Assets.icReviews.icLv5,
                      reviewScore: score,
                      selfScore: 5,
                      onTap: vm.onScoreTap,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  const _ScoreItem({
    required this.label,
    required this.icon,
    required this.reviewScore,
    required this.selfScore,
    required this.onTap,
  });

  final String label;
  final AssetGenImage icon;
  final int? reviewScore;
  final int selfScore;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(selfScore),
      child: Container(
        foregroundDecoration:
            (reviewScore == null || reviewScore != selfScore)
            ? const BoxDecoration(
                color: Colors.grey,
                backgroundBlendMode: BlendMode.saturation,
              )
            : null,
        child: Column(
          spacing: 8.h,
          children: [
            icon.image(width: AppDims.size_44.w),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: AppDims.size_44.w),
              child: AppText(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Browny Care + LINE row
// ─────────────────────────────────────────────────────────────────

class _SupportRow extends StatelessWidget {
  const _SupportRow({required this.callCenter, required this.lineLink});

  final String callCenter;
  final String lineLink;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDims.size_16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _SupportCard(
            icon: Assets.iconProfilePreferences.icCallOut.svg(
              width: AppDims.size_44.w,
            ),
            title: 'Browny Care',
            subtitle: callCenter,
            onTap: () => LaunchHelper.makePhoneCall(callCenter),
          ),
          _SupportCard(
            icon: Assets.iconProfilePreferences.lineRegPng.image(
              width: AppDims.size_44.w,
            ),
            title: 'LINE',
            subtitle: 'Browny Official',
            onTap: () => LaunchHelper.openUrlInWebView(lineLink),
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Widget icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
          left: AppDims.size_8.w,
          top: AppDims.size_8.h,
          right: AppDims.size_16.w,
          bottom: AppDims.size_12.h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.productStroke),
        ),
        child: Row(
          children: [
            icon,
            AppDims.horizonPadding_8,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  style: context.textTheme.labelLarge!.copyWith(
                    fontSize: AppDims.size_14.sp,
                  ),
                ),
                AppText(
                  subtitle,
                  style: context.textTheme.labelMedium!.copyWith(
                    fontSize: AppDims.size_12.sp,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Small helpers
// ─────────────────────────────────────────────────────────────────

class _Row extends StatelessWidget {
  const _Row({required this.leading, this.trailing, this.trailingWidget});

  final String leading;
  final String? trailing;
  final Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDims.size_2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppText(
              leading,
              style: context.textTheme.titleMedium!.copyWith(
                color: AppColors.gray600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailingWidget ??
              AppText(
                trailing ?? '',
                style: context.textTheme.titleMedium!.copyWith(
                  color: AppColors.gray600,
                ),
                textAlign: TextAlign.end,
              ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {this.isBold = true});

  final String title;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppDims.size_4.h, bottom: AppDims.size_2.h),
      child: AppText(
        title,
        style: context.textTheme.titleMedium!.copyWith(
          color: AppColors.gray600,
          fontWeight: isBold ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Column(
        children: [
          icon,
          AppDims.vericalPadding_8,
          AppText(
            label,
            style: context.textTheme.labelSmall!.copyWith(
              color: AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }
}
