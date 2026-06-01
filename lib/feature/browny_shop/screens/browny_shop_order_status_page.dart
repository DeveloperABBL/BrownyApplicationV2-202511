import 'dart:async';

import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/browny_shop_order_detail_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/shipping_provider_data.dart';
import 'package:browny_applications_new/core/widgets/qr_promptpay_dialog.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:browny_applications_new/feature/browny_shop/screens/browny_shop_page.dart';
import 'package:browny_applications_new/feature/browny_shop/screens/receipt_browny_shop_page.dart';
import 'package:browny_applications_new/feature/browny_shop/viewmodel/browny_shop_order_status_viewmodel.dart';
import 'package:browny_applications_new/feature/contacts/models/contact_model.dart';
import 'package:browny_applications_new/feature/contacts/screens/contact_page.dart';
import 'package:browny_applications_new/feature/home/screens/home_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

/// หน้าสถานะคำสั่งซื้อ Browny Shop (Figma node 185:4613)
///
/// แสดงสถานะออร์เดอร์ทุกสถานะ (รอชำระเงิน / รอจัดส่ง / จัดส่งแล้ว / ยกเลิก) —
/// รับ [orderId] เข้ามาเพื่อให้ VM fetch รายละเอียดจริง (GET /browny-shop/orders/
/// {orderId}); สถานะ pending_payment เปิดให้กลับเข้า process ชำระเงินที่ค้างอยู่
class BrownyShopOrderStatusPage extends StatelessWidget {
  const BrownyShopOrderStatusPage({super.key, required this.orderId});

  static final pagePath = '/browny_shop_order_status';
  static final pageName = 'BrownyShopOrderStatus';

  final String orderId;

  static Future<T?> goToPage<T>(
    BuildContext context, {
    required String orderId,
  }) async =>
      context.pushNamed(BrownyShopOrderStatusPage.pageName, extra: orderId);

  static void goReplacementPage(
    BuildContext context, {
    required String orderId,
  }) => context.pushReplacementNamed(
    BrownyShopOrderStatusPage.pageName,
    extra: orderId,
  );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => BrownyShopOrderStatusViewModel(
        context: ctx,
        repo: BrownyShopRepo(),
        orderId: orderId,
      ),
      child: const _OrderStatusWidget(),
    );
  }
}

class _OrderStatusWidget extends StatefulWidget {
  const _OrderStatusWidget();

  @override
  State<_OrderStatusWidget> createState() => _OrderStatusWidgetState();
}

class _OrderStatusWidgetState extends State<_OrderStatusWidget>
    with WidgetsBindingObserver {
  Timer? _pollingTimer;
  String? _currentPaymentRef;
  bool _isPolling = false;
  bool _paymentProcessing = false;

  /// กันกดปุ่ม "ชำระเงิน" ซ้ำระหว่าง process
  bool _isPayClicked = false;

  BrownyShopOrderStatusViewModel get _vm =>
      context.read<BrownyShopOrderStatusViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _vm.attachContext(context);
    });
  }

  @override
  void dispose() {
    _stopPolling();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // กลับเข้าแอประหว่างรอชำระ → เช็คสถานะทันที
    if (state == AppLifecycleState.resumed && _isPolling) {
      _checkPaymentStatus();
    }
  }

  void _popToHome() {
    context.popUntil(
      predicate: (route) => route.name.orEmpty == HomePage.pageName,
    );
    BrownyShopPage.goToPage(context);
  }

  void _copy(String value) {
    if (value.isEmpty) return;
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText(
          context.wording.copied,
          style: context.textTheme.labelLarge!.copyWith(
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(
          horizontal: AppDims.size_24.w,
          vertical: AppDims.size_46.h,
        ),
        duration: Durations.medium2,
      ),
    );
  }

  // ========== Resume payment (สถานะ pending_payment) ==========

  void _startPolling(String paymentRef) {
    _currentPaymentRef = paymentRef;
    _isPolling = true;
    _checkPaymentStatus();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkPaymentStatus(),
    );
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
    _currentPaymentRef = null;
  }

  Future<void> _checkPaymentStatus() async {
    final ref = _currentPaymentRef;
    if (ref == null) return;
    final result = await _vm.checkPaymentStatus(ref);
    if (!mounted) return;
    if (result.isSuccess && (result.data?.isPaid ?? false)) {
      _stopPolling();
      // ปิด dialog QR ถ้ายังเปิดอยู่
      if (_paymentProcessing && context.canPop()) context.pop();
      _showSuccessThenReceipt(result.data?.orderId?.toString());
    }
    // pending → polling ต่อ
  }

  /// popup สำเร็จ → replace ไปหน้าใบเสร็จ Browny Shop
  void _showSuccessThenReceipt(String? orderId) {
    AppOverlays.showBrownyDialog(
      context,
      imageAsset: Assets.png.brownySuccess3.path,
      title: context.wording.transactionSuccessful,
      message: context.wording.orderCompletedMessage,
      confirmText: context.wording.confirm,
      onConfirm: () {
        if (!mounted) return;
        ReceiptBrownyShop.goReplacementPage(
          context,
          orderId: orderId ?? _vm.orderId,
        );
      },
    );
  }

  /// กดปุ่ม "ชำระเงิน" — กลับเข้า process ชำระเงินของ order ที่ค้างอยู่
  ///
  /// ดึง order (GET /checkout/{orderId}) เพื่อเอา response_payload/payment_url
  /// แล้วแสดง QR ในแอป (PromptPay/WeChat) หรือเปิด web ภายนอก + polling สถานะ
  /// — เหมือน flow ใน [BrownyShopSelected]
  Future<void> _onPayPending() async {
    if (_isPayClicked) return;
    _isPayClicked = true;

    AppOverlays.showLoading(context);
    final result = await _vm.fetchPendingOrder();
    if (!mounted) return;
    AppOverlays.hideLoading();

    if (!result.isSuccess) {
      _isPayClicked = false;
      final err = result.error;
      AppOverlays.showBrownyDialog(
        context,
        message: err is BrownyShopApiException
            ? err.message
            : context.wording.errorUi,
      );
      return;
    }

    final order = result.data;
    final paymentRef = order?.paymentRef;
    if (order == null || paymentRef == null || paymentRef.isEmpty) {
      _isPayClicked = false;
      AppOverlays.showBrownyDialog(
        context,
        message: context.wording.paymentReferenceNotFound,
      );
      return;
    }

    // เผื่อชำระไปแล้ว (race) → เช็คสถานะแล้วไปใบเสร็จ
    final isPaid = order.status == 'paid' || order.paymentStatus == 'paid';
    if (isPaid) {
      _currentPaymentRef = paymentRef;
      await _checkPaymentStatus();
      if (mounted) _isPayClicked = false;
      return;
    }

    // เลือก path: QR ในแอป (qrcode/wechat) หรือเปิด web ภายนอก (payment_url)
    final qrcode = order.responsePayload?.qrcode;
    final wechat = order.responsePayload?.wechat;
    final isWeChat = wechat != null && wechat.isNotEmpty;
    final qrData = isWeChat ? wechat : qrcode;
    final hasInAppQr = qrData != null && qrData.isNotEmpty;
    final paymentUrl = order.paymentUrl;

    if (!hasInAppQr && (paymentUrl == null || paymentUrl.isEmpty)) {
      _isPayClicked = false;
      AppOverlays.showBrownyDialog(
        context,
        message: context.wording.incompletePaymentData,
      );
      return;
    }

    _startPolling(paymentRef);
    _paymentProcessing = true;

    if (hasInAppQr) {
      await showDialog(
        useSafeArea: false,
        context: context,
        builder: (_) => Dialog.fullscreen(
          child: QrPromptpayDialog(
            qrData: qrData,
            paymentDadge: isWeChat
                ? Assets.png.wechatPayBadge
                : Assets.png.promptpayBadgeNoLine,
          ),
        ),
      );
    } else {
      // เปิด web ภายนอก + หน้ารอดำเนินการ
      LaunchHelper.openUrlInBrowser(paymentUrl!);
      await showModalBottomSheet(
        context: context,
        showDragHandle: true,
        enableDrag: false,
        isScrollControlled: true,
        isDismissible: false,
        builder: (dialogContext) {
          return SizedBox(
            height: 812.h * 0.85,
            child: Scaffold(
              persistentFooterDecoration: const BoxDecoration(),
              persistentFooterButtons: [
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDims.size_16.w,
                    ),
                    child: ElevatedButton(
                      onPressed: () => dialogContext.pop(),
                      child: AppText(context.wording.backToMainPage),
                    ),
                  ),
                ),
              ],
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: AppDims.size_8.h,
                  children: [
                    const CircularProgressIndicator(),
                    AppText(
                      context.wording.processingPleaseWait,
                      style: context.textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    // ปิด QR/web เอง (ยังไม่จ่าย) → เช็คอีกรอบ; ถ้ายังไม่จ่ายให้รีเฟรชสถานะหน้า
    _paymentProcessing = false;
    _stopPolling();
    final status = await _vm.checkPaymentStatus(paymentRef);
    if (!mounted) return;
    if (status.isSuccess && (status.data?.isPaid ?? false)) {
      _showSuccessThenReceipt(status.data?.orderId?.toString());
      return;
    }
    _isPayClicked = false;
    _vm.fetchOrderDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bareBackground,
      appBar: AppBar(
        title: AppText(
          context.wording.orderStatus,
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: 20.sp,
            color: AppColors.white,
          ),
        ),
        flexibleSpace: _buildAppBar(context),
      ),
      body: ValueListenableBuilder(
        valueListenable: _vm.statusNotifier,
        builder: (context, result, _) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!result.isSuccess || result.data == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(AppDims.size_24.w),
                child: AppText(context.wording.errorUi),
              ),
            );
          }
          final data = result.data!;
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.ci,
                  onRefresh: _vm.fetchOrderDetail,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDims.size_16.w,
                      vertical: AppDims.size_14.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppDims.size_14.h,
                      children: [
                        // ผู้ขาย / ที่อยู่ติดต่อ
                        // _SellerCard(data: data),
                        // สถานะ + stepper + เลขพัสดุ + ข้อมูลการจัดส่ง
                        _StatusCard(data: data, onCopyTracking: _copy),
                        // Order ID + รายการสินค้า + รวมคำสั่งซื้อ
                        _ProductsCard(data: data, onCopy: _copy),
                        // การชำระเงิน
                        _PaymentCard(data: data),
                        // บริการหลังการขาย
                        const _SupportCard(),
                        // คำสั่งซื้อ + เวลา + QR
                        _OrderDetailCard(data: data, onCopy: _copy),
                      ],
                    ),
                  ),
                ),
              ),
              // แถบล่าง — pending_payment = "ชำระเงิน", สถานะอื่น = "กลับสู่หน้าหลัก"
              _BottomBar(
                isPendingPayment: data.isPendingPayment,
                onBack: _popToHome,
                onPay: _onPayPending,
              ),
            ],
          );
        },
      ),
    );
  }

  /// AppBar — bg gradient image + title กลาง (ขาว)
  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          image: Assets.png.bgAppBar.provider(),
        ),
      ),
    );
  }
}

// ============================================================
// Shared building blocks
// ============================================================

/// การ์ดสีขาวมุมโค้ง ครอบแต่ละ section
class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDims.size_16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: child,
    );
  }
}

/// ไอคอนหัวข้อ section — วงกลมเขียว + ไอคอนขาวข้างใน (Frame 2087327026 bg)
class _SectionIconCircle extends StatelessWidget {
  const _SectionIconCircle({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.w,
      height: 24.w,
      decoration: const BoxDecoration(
        color: AppColors.ci,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// แถวหัวข้อ section — ไอคอน + ชื่อ
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final Widget icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        SizedBox(width: AppDims.size_8.w),
        Expanded(
          child: AppText(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              color: AppColors.textBare,
            ),
          ),
        ),
      ],
    );
  }
}

/// แถว label (ซ้าย) + value (ขวา)
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDims.size_2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            style: context.textTheme.titleMedium?.copyWith(
              color: AppColors.gray600,
            ),
          ),
          SizedBox(width: AppDims.size_8.w),
          Expanded(
            child: AppText(
              value ?? '',
              textAlign: TextAlign.end,
              style: context.textTheme.titleMedium?.copyWith(
                color: AppColors.gray600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ปุ่มชิป "คัดลอก" — variant สีเทา (grey) หรือเขียว (green)
class _CopyChip extends StatelessWidget {
  const _CopyChip({required this.onTap, this.green = false});

  final VoidCallback? onTap;
  final bool green;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDims.size_8.w,
          vertical: AppDims.size_4.h,
        ),
        decoration: BoxDecoration(
          color: green ? AppColors.ci3 : AppColors.bareBackground,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              context.wording.copy,
              style: context.textTheme.titleMedium?.copyWith(
                color: green ? AppColors.ci : AppColors.gray500,
              ),
            ),
            SizedBox(width: AppDims.size_8.w),
            Assets.icShop.icCopy.svg(
              width: 16.w,
              height: 16.w,
              color: green ? null : AppColors.gray500,
            ),
          ],
        ),
      ),
    );
  }
}

/// เส้นคั่น
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDims.size_4.h),
      child: Container(height: 1, color: AppColors.productStroke),
    );
  }
}

// ============================================================
// สถานะ + stepper + เลขพัสดุ + ข้อมูลการจัดส่ง
// ============================================================

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.data, required this.onCopyTracking});

  final BrownyShopOrderDetailData data;
  final void Function(String) onCopyTracking;

  /// hero image (Frame 2087326612) — pending_payment ใช้ warning ตาม locale,
  /// นอกนั้น thank you
  AssetGenImage _heroAsset(BuildContext context) {
    if (data.isCancelled) return Assets.icShop.brownyWarningCanceled;
    if (!data.isPendingPayment) return Assets.icShop.brownyThankYou;
    switch (context.languageCode) {
      case 'en':
        return Assets.icShop.brownyWarningTransferEn;
      case 'zh':
        return Assets.icShop.brownyWarningTransferZh;
      default:
        return Assets.icShop.brownyWarningTransferTh;
    }
  }

  /// ป้ายสถานะ (Frame 2087326613) — ไอคอน/สี/ข้อความ ตาม status
  _StatusBannerStyle _bannerStyle(BuildContext context) {
    final label = data.getStatusLabelDisplay(context.languageCode);
    if (data.isCancelled) {
      return _StatusBannerStyle(
        icon: Assets.icShop.icCanceledRounded,
        background: AppColors.errorBackground,
        textColor: AppColors.error,
        text: label.isNotEmpty ? label : context.wording.orderCancelled,
      );
    }
    if (data.isDelivered) {
      return _StatusBannerStyle(
        icon: Assets.icShop.icTruckRoundedCi3,
        background: AppColors.ci3,
        textColor: AppColors.ci,
        text: label.isNotEmpty ? label : context.wording.delivery,
      );
    }
    if (data.isPendingPayment) {
      return _StatusBannerStyle(
        icon: Assets.icShop.icCardRoundedOrange,
        background: AppColors.warningBackground,
        textColor: AppColors.gray500,
        text: label.isNotEmpty ? label : context.wording.pendingPayment,
      );
    }
    // pending_shipment (default)
    return _StatusBannerStyle(
      icon: Assets.icShop.icTruckRoundedOrange,
      background: AppColors.warningBackground,
      textColor: AppColors.gray500,
      text: label.isNotEmpty ? label : context.wording.waitingForDelivery,
    );
  }

  @override
  Widget build(BuildContext context) {
    final address = data.shippingAddress;
    final banner = _bannerStyle(context);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // hero
          Center(child: _heroAsset(context).image(height: 85.h)),
          SizedBox(height: AppDims.size_16.h),
          // stepper
          _StatusStepper(data: data),
          SizedBox(height: AppDims.size_16.h),
          // banner
          _StatusBanner(style: banner),
          SizedBox(height: AppDims.size_16.h),
          // เลขพัสดุ
          _SectionTitle(
            icon: _SectionIconCircle(
              child: Assets.icShop.icBoxLineWhite.image(
                width: 16.w,
                height: 16.w,
              ),
            ),
            title: context.wording.parcelNumber,
          ),
          SizedBox(height: AppDims.size_8.h),
          Row(
            children: [
              Expanded(
                child: AppText(
                  'Tracking number',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ),
              if (data.hasTrackingNumber)
                AppText(
                  data.trackingNumber!,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
            ],
          ),
          SizedBox(height: AppDims.size_4.h),
          Align(
            alignment: Alignment.centerRight,
            // tracking
            child: _CopyChip(
              onTap: data.hasTrackingNumber
                  ? () => onCopyTracking(data.trackingNumber!)
                  : null,
              green: data.hasTrackingNumber,
            ),
          ),
          // บริษัทขนส่ง (shipping_provider) — ชื่อ + โลโก้ (Frame 2087327125)
          if (data.shippingProvider != null) ...[
            SizedBox(height: AppDims.size_8.h),
            _ShippingProviderRow(provider: data.shippingProvider!),
          ],
          SizedBox(height: AppDims.size_16.w),
          const _Divider(),
          // ข้อมูลการจัดส่ง
          _SectionTitle(
            icon: Assets.svg.icLocationRoundedGreen.svg(
              width: 24.w,
              height: 24.w,
            ),
            title: context.wording.shippingInfo,
          ),
          SizedBox(height: AppDims.size_8.h),
          _DetailRow(
            // ชื่อผู้รับสินค้า
            label: context.wording.recipientName,
            value: address?.recipientName,
          ),
          _DetailRow(
            // เบอร์โทรศัพท์
            label: context.wording.phoneNumber,
            value: address?.phone,
          ),
          SizedBox(height: AppDims.size_2.h),
          AppText(
            context.wording.shippingAddressDetail,
            style: context.textTheme.titleMedium?.copyWith(
              color: AppColors.gray600,
            ),
          ),
          SizedBox(height: AppDims.size_4.h),
          AppText(
            address?.fullAddress ?? '',
            style: context.textTheme.titleMedium?.copyWith(
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}

/// แถวบริษัทขนส่ง (Frame 2087327125) — ชื่อขนส่ง + โลโก้ ชิดขวา
class _ShippingProviderRow extends StatelessWidget {
  const _ShippingProviderRow({required this.provider});

  final ShippingProviderData provider;

  @override
  Widget build(BuildContext context) {
    final name = provider.name;
    final logoUrl = provider.logoUrl;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (name != null && name.isNotEmpty)
          Flexible(
            child: AppText(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: context.textTheme.titleMedium?.copyWith(
                color: AppColors.gray600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (logoUrl != null && logoUrl.isNotEmpty) ...[
          SizedBox(width: AppDims.size_8.w),
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(9.r),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: CachedNetworkImage(
              imageUrl: logoUrl,
              fit: BoxFit.contain,
              errorWidget: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ],
      ],
    );
  }
}

/// stepper 3 ขั้น (Frame 2087326634) — สั่งซื้อ → ชำระเงิน → จัดส่ง
class _StatusStepper extends StatelessWidget {
  const _StatusStepper({required this.data});

  final BrownyShopOrderDetailData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppDims.size_6.w,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // สั่งซื้อ — active เสมอ
        _step(
          context,
          icon: data.isCancelled
              ? Assets.icShop.icCartRoundedInactive
              : Assets.icShop.icCartRoundedGreen,
          label: context.wording.ordered,
        ),
        _connector(),
        // ชำระเงิน
        _step(
          context,
          icon: data.isPaymentConfirmed
              ? Assets.icShop.icCardRoundedActive
              : Assets.icShop.icCardRoundedInactive,
          label: context.wording.makePayment,
        ),
        _connector(),
        // จัดส่ง
        _step(
          context,
          icon: data.isShipped
              ? Assets.icShop.icTruckRoundedActive
              : Assets.icShop.icTruckRoundedInactive,
          label: context.wording.delivery,
        ),
      ],
    );
  }

  Widget _step(
    BuildContext context, {
    required AssetGenImage icon,
    required String label,
  }) {
    return SizedBox(
      child: Column(
        children: [
          icon.image(width: 34.w, height: 34.w),
          SizedBox(height: AppDims.size_4.h),
          AppText(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelMedium?.copyWith(
              color: AppColors.darkBrown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _connector() {
    // สูงเท่าไอคอน step (34) แล้ว center → arrow อยู่กึ่งกลางแนวตั้งกับไอคอน
    return SizedBox(
      height: 34.w,
      child: Center(
        child: Assets.icShop.icForward.svg(width: 10.w, height: 10.w),
      ),
    );
  }
}

/// style ของแถบสถานะ ตาม status
class _StatusBannerStyle {
  const _StatusBannerStyle({
    required this.icon,
    required this.background,
    required this.textColor,
    required this.text,
  });

  final AssetGenImage icon;
  final Color background;
  final Color textColor;
  final String text;
}

/// แถบสถานะ — ไอคอน + ข้อความ ตาม status (สี/ไอคอนต่างกันตามสถานะ)
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.style});

  final _StatusBannerStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDims.size_8.w),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          style.icon.image(width: 24.w, height: 24.w),
          SizedBox(width: AppDims.size_8.w),
          Expanded(
            child: AppText(
              style.text,
              style: context.textTheme.titleMedium?.copyWith(
                color: style.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Order ID + รายการสินค้า + รวมคำสั่งซื้อ
// ============================================================

class _ProductsCard extends StatelessWidget {
  const _ProductsCard({required this.data, required this.onCopy});

  final BrownyShopOrderDetailData data;
  final void Function(String) onCopy;

  @override
  Widget build(BuildContext context) {
    final items = data.items ?? const <BrownyShopOrderDetailItem>[];
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID
          Row(
            children: [
              AppText(
                'Order ID',
                style: context.textTheme.titleMedium?.copyWith(
                  color: AppColors.gray600,
                ),
              ),
              SizedBox(width: AppDims.size_8.w),
              Expanded(
                child: AppText(
                  data.orderIdDisplay,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ),
              SizedBox(width: AppDims.size_8.w),
              GestureDetector(
                onTap: () => onCopy(data.orderIdDisplay),
                behavior: HitTestBehavior.opaque,
                child: Assets.icShop.icCopy.svg(
                  width: 16.w,
                  height: 16.w,
                  colorFilter: ColorFilter.mode(
                    AppColors.gray500,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDims.size_16.h),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(height: AppDims.size_16.h),
            _ProductItem(item: items[i]),
          ],
          const _Divider(),
          // รวมคำสั่งซื้อ
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppDims.size_8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppText(
                  '${context.wording.orderTotal} : ',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: AppColors.textBare,
                  ),
                ),
                AppText(
                  formatCurrency(string: data.priceFinal, leadingSign: '฿'),
                  style: context.textTheme.titleMedium?.copyWith(
                    color: AppColors.textBare,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductItem extends StatelessWidget {
  const _ProductItem({required this.item});

  final BrownyShopOrderDetailItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputFieldDisableBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppDims.size_8.w,
        vertical: AppDims.size_4.h,
      ),
      child: Row(
        children: [
          _image(),
          SizedBox(width: AppDims.size_8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  item.getNameDisplay(context.languageCode),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: AppColors.darkBrown,
                  ),
                ),
                if (item.isFreeShipping) ...[
                  SizedBox(height: AppDims.size_4.h),
                  const _FreeShippingChip(),
                ],
                SizedBox(height: AppDims.size_8.h),
                _prices(context),
                SizedBox(height: AppDims.size_4.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppText(
                    'x${item.quantity ?? 0}',
                    style: context.textTheme.titleSmall?.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _image() {
    final url = item.imageUrl;
    return Container(
      width: 100.w,
      height: 100.w,
      decoration: BoxDecoration(
        color: AppColors.bareBackground,
        borderRadius: BorderRadius.circular(10.r),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: url == null || url.isEmpty
          ? Icon(Icons.image_outlined, size: 32.w, color: AppColors.gray400)
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              errorWidget: (_, _, _) => Icon(
                Icons.image_outlined,
                size: 32.w,
                color: AppColors.gray400,
              ),
            ),
    );
  }

  Widget _prices(BuildContext context) {
    final coinPrice = item.unitCoinPrice;
    final moneyPrice = item.unitMoneyPrice ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (coinPrice != null)
          Row(
            children: [
              _CoinChip(coin: coinPrice),
              if (item.hasCoinDiscount) ...[
                SizedBox(width: AppDims.size_4.w),
                AppText(
                  formatCurrency(value: item.originalCoinPrice!),
                  style: context.textTheme.labelSmall?.copyWith(
                    fontSize: 10.sp,
                    color: AppColors.gray500,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColors.gray500,
                  ),
                ),
              ],
            ],
          ),
        SizedBox(height: 2.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AppText(
              formatCurrency(value: moneyPrice, leadingSign: '฿'),
              style: context.textTheme.titleSmall?.copyWith(
                color: AppColors.ci,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (item.hasMoneyDiscount) ...[
              SizedBox(width: AppDims.size_4.w),
              AppText(
                formatCurrency(
                  value: item.originalMoneyPrice!,
                  leadingSign: '฿',
                ),
                style: context.textTheme.labelSmall?.copyWith(
                  color: AppColors.gray500,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppColors.gray500,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// ชิป "ส่งฟรี"
class _FreeShippingChip extends StatelessWidget {
  const _FreeShippingChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDims.size_4.w,
        vertical: AppDims.size_2.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.ci7,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Assets.icShop.icTruckTick.image(width: 12.w, height: 12.w),
          ),
          SizedBox(width: AppDims.size_4.w),
          AppText(
            context.wording.freeShipping,
            style: context.textTheme.labelSmall?.copyWith(
              fontSize: 12.sp,
              color: AppColors.ci,
            ),
          ),
        ],
      ),
    );
  }
}

/// ชิปราคา coin
class _CoinChip extends StatelessWidget {
  const _CoinChip({required this.coin});

  final num coin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDims.size_4.w,
        vertical: AppDims.size_2.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.ci6,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.png.brownyCoin.image(width: 10.w, height: 10.w),
          SizedBox(width: AppDims.size_4.w),
          AppText(
            formatCurrency(
              value: coin,
              trailingSign: ' ${context.wording.coin}',
            ),
            style: context.textTheme.labelSmall?.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// การชำระเงิน
// ============================================================

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.data});

  final BrownyShopOrderDetailData data;

  @override
  Widget build(BuildContext context) {
    final logoUrl = data.paymentIcon;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // การชำระเงิน
          _SectionTitle(
            icon: Assets.icShop.icCardRoundedActive.image(
              width: 24.w,
              height: 24.w,
            ),
            title: context.wording.orderHistoryPayment,
          ),
          SizedBox(height: AppDims.size_16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppText(
                  context.wording.paymentMethod,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ),
              SizedBox(width: AppDims.size_8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText(
                    data.getPaymentDisplay(context.languageCode),
                    style: context.textTheme.titleMedium?.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                  if (logoUrl != null && logoUrl.isNotEmpty) ...[
                    SizedBox(height: AppDims.size_4.h),
                    CachedNetworkImage(
                      imageUrl: logoUrl,
                      width: 30.w,
                      height: 30.w,
                      fit: BoxFit.contain,
                      errorWidget: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ],
                  // ใบเสร็จรับเงิน — แตะเพื่อเปิดหน้าใบเสร็จของออร์เดอร์นี้
                  // ซ่อนเมื่อ order ยังไม่ชำระเงิน (receipt จะตอบ 422)
                  // หรือเป็น order ที่ canceld แล้ว
                  if (!data.isPendingPayment && !data.isCancelled) ...[
                    SizedBox(height: AppDims.size_8.h),
                    GestureDetector(
                      onTap: () => ReceiptBrownyShop.goToPage(
                        context,
                        orderId: data.orderId.orEmpty,
                      ),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDims.size_8.w,
                          vertical: AppDims.size_4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.ci3,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: AppText(
                          context.wording.receipt,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: AppColors.ci,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppDims.size_8.w),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// บริการหลังการขาย
// ============================================================

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Assets.svg.icHeadset.svg(
              width: 24.w,
              height: 24.w,
              color: AppColors.gray600,
            ),
            title: context.wording.afterSalesService,
          ),
          SizedBox(height: AppDims.size_16.h),
          GestureDetector(
            onTap: () => ContactPage.goToPage(
              context,
              ContactProvider.helpAndProblemNoti,
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    // ศูนย์ความช่วยเหลือ
                    context.wording.helpCenter,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ),
                Assets.icShop.icChevronRight.image(
                  width: 8.w,
                  color: AppColors.gray600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// คำสั่งซื้อ + เวลา + QR
// ============================================================

class _OrderDetailCard extends StatelessWidget {
  const _OrderDetailCard({required this.data, required this.onCopy});

  final BrownyShopOrderDetailData data;
  final void Function(String) onCopy;

  @override
  Widget build(BuildContext context) {
    // คำสั่งซื้อ
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            context.wording.order,
            style: context.textTheme.titleMedium?.copyWith(
              color: AppColors.textBare,
            ),
          ),
          SizedBox(height: AppDims.size_8.h),
          Row(
            children: [
              AppText(
                'Order ID',
                style: context.textTheme.titleMedium?.copyWith(
                  color: AppColors.gray600,
                ),
              ),
              SizedBox(width: AppDims.size_8.w),
              Expanded(
                child: AppText(
                  data.orderIdDisplay,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.gray600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDims.size_4.w),
          Align(
            alignment: AlignmentGeometry.centerRight,
            // Order ID
            child: _CopyChip(
              onTap: () => onCopy(data.orderIdDisplay),
              green: true,
            ),
          ),
          SizedBox(height: AppDims.size_16.w),
          const _Divider(),
          if (data.createdAt != null)
            _DetailRow(
              // เวลาที่สั่งซื้อ
              label: context.wording.orderTime,
              value: data.createdAt,
            ),
          if (data.paidAt != null)
            _DetailRow(
              // เวลาที่ชำระเงิน
              label: context.wording.paymentTime,
              value: data.paidAt,
            ),
          if (data.deliveredAt != null)
            _DetailRow(
              // เวลาที่จัดส่ง
              label: context.wording.deliveryTime,
              value: data.deliveredAt,
            ),
          SizedBox(height: AppDims.size_8.h),
          // QR สำหรับ Browny Support
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDims.size_4.w,
                    vertical: AppDims.size_2.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bareBackground,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: AppText(
                    context.wording.qrCodeForSupportOnly,
                    style: context.textTheme.labelSmall?.copyWith(
                      fontSize: 10.sp,
                      color: AppColors.gray500,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                if (data.qrImage != null && data.qrImage!.isNotEmpty)
                  Image.network(
                    data.qrImage!,
                    width: 90.w,
                    height: 90.w,
                    fit: BoxFit.contain,
                    errorBuilder: (_, e, st) => const SizedBox.shrink(),
                  )
                else
                  Container(
                    width: 90.w,
                    height: 90.w,
                    decoration: BoxDecoration(
                      color: AppColors.bareBackground,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.qr_code_2,
                      size: 48.w,
                      color: AppColors.gray400,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// bar ล่าง — "ชำระเงิน" (pending_payment) หรือ "กลับสู่หน้าหลัก"
// ============================================================

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isPendingPayment,
    required this.onBack,
    required this.onPay,
  });

  final bool isPendingPayment;
  final VoidCallback onBack;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(
        left: AppDims.size_24.w,
        right: AppDims.size_24.w,
        top: AppDims.size_16.h,
        bottom: AppDims.size_32.h,
      ),
      child: GestureDetector(
        onTap: isPendingPayment ? onPay : onBack,
        child: Container(
          width: double.infinity,
          height: AppDims.size_40.h,
          decoration: BoxDecoration(
            color: AppColors.ci,
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: AppText(
            isPendingPayment
                ? context.wording.makePayment
                : context.wording.backToHome,
            style: context.textTheme.labelLarge?.copyWith(
              fontSize: 14.sp,
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
