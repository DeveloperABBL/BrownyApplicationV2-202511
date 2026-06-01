import 'dart:async';

import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/address_response.dart';
import 'package:browny_applications_new/core/widgets/qr_promptpay_dialog.dart';
import 'package:browny_applications_new/feature/authentication/screen/app_pin_page.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:browny_applications_new/feature/browny_shop/screens/browny_shop_order_status_page.dart';
import 'package:browny_applications_new/feature/browny_shop/screens/customer_ship_to_page.dart';
import 'package:browny_applications_new/feature/browny_shop/screens/receipt_browny_shop_page.dart';
import 'package:browny_applications_new/feature/browny_shop/viewmodel/browny_shop_selected_viewmodel.dart';
import 'package:browny_applications_new/feature/transactions/models/coupon_detail_model.dart';
import 'package:browny_applications_new/feature/transactions/models/customer_coupon_model.dart';
import 'package:browny_applications_new/feature/transactions/screens/available_payment_method_page.dart';
import 'package:browny_applications_new/feature/transactions/screens/coupons_evoucher/coupon_voucher_page.dart';
import 'package:browny_applications_new/feature/wallet/screen/wallet_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// หน้า checkout / สรุปก่อนชำระเงิน ของ Browny Shop
///
/// Figma: node 56:23587
/// เข้าจากปุ่ม "ชำระเงิน" ในหน้าตะกร้า ([BrownyShopCartPage]) — รับ
/// [BrownyShopSelectedViewModel] instance เดียวกับหน้าตะกร้าผ่าน `extra`
///
/// NOTE: API ที่อยู่จัดส่ง / วิธีจัดส่ง / order ยังไม่พร้อม — ส่วนนั้น mock ตาม design
class BrownyShopSelected extends StatelessWidget {
  const BrownyShopSelected({super.key, required this.viewModel});

  static final pagePath = '/browny_shop_selected';
  static final pageName = 'BrownyShopSelected';

  /// ViewModel จากหน้าตะกร้า (cart เป็นเจ้าของ + dispose)
  final BrownyShopSelectedViewModel viewModel;

  static Future<T?> goToPage<T>(
    BuildContext context, {
    required BrownyShopSelectedViewModel viewModel,
  }) async {
    return await context.pushNamed(
      BrownyShopSelected.pageName,
      extra: viewModel,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ใช้ .value — VM เป็นของหน้าตะกร้า ไม่ dispose ซ้ำที่นี่
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: const _BrownyShopSelectedWidget(),
    );
  }
}

class _BrownyShopSelectedWidget extends StatefulWidget {
  const _BrownyShopSelectedWidget();

  @override
  State<_BrownyShopSelectedWidget> createState() =>
      _BrownyShopSelectedWidgetState();
}

class _BrownyShopSelectedWidgetState extends State<_BrownyShopSelectedWidget>
    with WidgetsBindingObserver {
  Timer? _pollingTimer;
  String? _currentPaymentRef;
  bool _isPolling = false;
  bool _paymentProcessing = false;

  /// กันกดปุ่มชำระเงินซ้ำระหว่าง process
  bool _isPurchaseClicked = false;

  BrownyShopSelectedViewModel get _vm =>
      context.read<BrownyShopSelectedViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ตะกร้า (vm.lines) ถูกโหลดจากหน้าตะกร้าแล้ว — ที่นี่โหลด payment methods
      // + ที่อยู่จัดส่งเริ่มต้น (ที่อยู่หลัก) แล้ว preview summary จาก server
      final vm = _vm;
      vm.fetchPaymentMethod(context);
      vm.loadDefaultShippingAddress();
      vm.fetchCartSummary();
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
    final result = await _vm.checkBrownyShopPaymentStatus(ref);
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
        ReceiptBrownyShop.goReplacementPage(context, orderId: orderId ?? '');
      },
    );
  }

  /// กดปุ่มชำระเงิน — ลอก flow ของ [MachineTransactionPage2._onPurchaseClicked]
  /// มาครบทุกเงื่อนไข (เพิ่ม guard ที่อยู่/วิธีชำระ ที่เป็นของ Browny Shop เอง)
  ///
  /// guard ที่อยู่/วิธีชำระ → verifyBalance (wallet/coin) → PIN/Biometric เฉพาะ
  /// TP+ Wallet → confirmCheckout → ตรวจ order/paymentRef → ถ้า paid (coin/wallet/
  /// free) เช็คสถานะไปใบเสร็จ; ถ้า pending แสดง QR ในแอป (qr/wechat) หรือเปิด web
  /// ภายนอก + หน้ารอดำเนินการ แล้ว polling จน paid
  Future<void> _onPurchaseClicked() async {
    if (_isPurchaseClicked) return;
    final vm = _vm;

    // guard: ที่อยู่จัดส่ง
    if (vm.shippingAddressNotifier.value == null) {
      AppOverlays.showBrownyDialog(
        context,
        message: context.wording.selectAddress,
      );
      return;
    }
    // guard: วิธีชำระเงิน
    final payment = vm.paymentSelected;
    if (payment == null) {
      AppOverlays.showBrownyDialog(
        context,
        message: context.wording.selectPaymentMethod,
      );
      return;
    }

    // flag กันคลิกเบิ้ล
    _isPurchaseClicked = true;

    // ตรวจยอดคงเหลือก่อน (verifyBalance คืน success ทันทีถ้าไม่ใช่ wallet/coin)
    AppOverlays.showLoading(context);
    final verify = await vm.verifyBalance();
    if (!mounted) return;
    AppOverlays.hideLoading();
    if (verify.isEmpty && (payment.isTpWallet || payment.isCoin)) {
      _isPurchaseClicked = false;
      final String title;
      final String message;
      if (payment.isTpWallet) {
        // TP+ Wallet เงินไม่เพียงพอ / กรุณาเติมเงิน หรือเปลี่ยนวิธีการชำระเงิน
        title = context.wording.insufficientWalletBalanceTitle;
        message = context.wording.insufficientWalletBalanceMessage;
      } else {
        // Browny Coin ไม่เพียงพอ / กรุณาเปลี่ยนวิธีชำระเงิน
        title = context.wording.insufficientCoinTitle;
        message = context.wording.changePaymentMethod;
      }
      AppOverlays.showBrownyDialog(context, title: title, message: message);
      return;
    }

    // ผ่าน PIN/Biometric เฉพาะ TP+ Wallet
    if (payment.isTpWallet) {
      final authed = await TransactionAuthenPage.goToPage(context);
      if (!mounted) return;
      if (authed is! bool || !authed) {
        _isPurchaseClicked = false;
        return;
      }
    }

    AppOverlays.showLoading(context, timeout: Duration.zero);
    final result = await vm.confirmCheckout();
    if (!mounted) return;

    if (!result.isSuccess) {
      AppOverlays.hideLoading();
      _isPurchaseClicked = false;
      final err = result.error;
      AppOverlays.showBrownyDialog(
        context,
        message: err is BrownyShopApiException
            ? err.message
            : context.wording.errorUi,
      );
      return;
    }

    // ไม่มีข้อมูล order → สร้างคำสั่งซื้อไม่ได้
    final order = result.data;
    if (order == null) {
      AppOverlays.hideLoading();
      _isPurchaseClicked = false;
      AppOverlays.showBrownyDialog(
        context,
        // เดิม: ไม่สามารถสร้างคำสั่งซื้อได้
        message: context.wording.cannotCreateOrder,
      );
      return;
    }

    // ตรวจ payment_ref
    final paymentRef = order.paymentRef;
    if (paymentRef == null || paymentRef.isEmpty) {
      AppOverlays.hideLoading();
      _isPurchaseClicked = false;
      AppOverlays.showBrownyDialog(
        context,
        // เดิม: ไม่พบข้อมูล Payment Reference
        message: context.wording.paymentReferenceNotFound,
      );
      return;
    }

    // ชำระทันที (coin / wallet / free) → เช็คสถานะแล้วไปหน้าใบเสร็จ
    final isPaid = order.status == 'paid' || order.paymentStatus == 'paid';
    if (isPaid) {
      _paymentProcessing = false;
      // เก็บ paymentRef ก่อน call payment check
      _currentPaymentRef = paymentRef;
      await _checkPaymentStatus();
      if (!mounted) return;
      AppOverlays.hideLoading();
      return;
    }

    // ปิด loading ถ้าผ่าน condition ข้างบนทั้งหมด
    AppOverlays.hideLoading();

    // เก็บ QRCode ที่ได้จาก payload — เฉพาะวิธีที่โชว์ QR ในแอป
    String? qrData = '';
    if (payment.isShowInAppQR) {
      if (payment.isWeChat) {
        // WeChat
        qrData = order.responsePayload?.wechat;
      } else {
        // QR Promptpay
        qrData = order.responsePayload?.qrcode;
      }
    }
    // ถ้ามีค่าเป็น null จะ error
    if (qrData == null) {
      _isPurchaseClicked = false;
      AppOverlays.showBrownyDialog(
        context,
        // ข้อมูลการชำระไม่ครบถ้วน กรุณาลองใหม่อีกครั้ง
        message: context.wording.incompletePaymentData,
      );
      return;
    }

    // เริ่ม polling สถานะการชำระเงิน
    _startPolling(paymentRef);
    _paymentProcessing = true;
    if (payment.isShowInAppQR) {
      // QR ในแอป (PromptPay / WeChat)
      await showDialog(
        useSafeArea: false,
        context: context,
        builder: (_) => Dialog.fullscreen(
          child: QrPromptpayDialog(
            qrData: qrData!,
            paymentDadge: payment.isWeChat
                ? Assets.png.wechatPayBadge
                : Assets.png.promptpayBadgeNoLine,
          ),
        ),
      );
    } else {
      // เปิด web ภายนอก (ถ้าวิธีชำระต้องเปิด) + แสดงหน้ารอดำเนินการ
      if (payment.isLaunchExternalWeb && order.paymentUrl != null) {
        LaunchHelper.openUrlInBrowser(order.paymentUrl!);
      }
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
                      // กำลังดำเนินการ กรุณารอซักครู่...
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
    // ปิด QR/web เอง (ยังไม่จ่าย) → เช็คอีกรอบ
    _paymentProcessing = false;
    _stopPolling();
    final status = await _vm.checkBrownyShopPaymentStatus(paymentRef);
    if (!mounted) return;
    if (status.isSuccess && (status.data?.isPaid ?? false)) {
      _showSuccessThenReceipt(status.data?.orderId?.toString());
      return;
    }
    // ยังไม่ชำระ → order ถูกสร้างเป็น pending_payment แล้ว ออกจากหน้า checkout
    // ไปหน้าสถานะคำสั่งซื้อ (ผู้ใช้กลับเข้ามาชำระต่อภายหลังได้)
    _isPurchaseClicked = false;
    BrownyShopOrderStatusPage.goReplacementPage(
      context,
      orderId: order.id ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bareBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          AppDims.size_56.h + MediaQuery.of(context).padding.top,
        ),
        child: _buildAppBar(context),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: AppDims.size_16.w,
          vertical: AppDims.size_14.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppDims.size_14.h,
          children: const [
            // ที่อยู่จัดส่ง
            _ShipToCard(),
            // วิธีการจัดส่ง
            _ShippingCard(),
            // คูปอง / E-Voucher
            _CouponCard(),
            // รายการสินค้าในตะกร้า
            _ProductsCard(),
            // วิธีการชำระเงิน
            _PaymentCard(),
            // สรุปการสั่งซื้อ
            _OrderSummaryCard(),
          ],
        ),
      ),
      bottomNavigationBar: _BottomBar(
        onPay: _onPurchaseClicked,
      ), // Frame 2087326691
    );
  }

  /// AppBar — bg gradient image + back (white) + title กลาง
  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          image: Assets.png.bgAppBar.provider(),
        ),
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDims.size_16.w),
        child: SizedBox(
          height: AppDims.size_56.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AppText(
                context.wording.makeOrder,
                style: context.textTheme.titleMedium?.copyWith(
                  fontSize: 20.sp,
                  color: AppColors.white,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: BackButton(color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Shared widgets
// ============================================================

/// การ์ดสีขาวมุมโค้ง ครอบแต่ละ section ของหน้า checkout
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDims.size_16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }
}

/// ไอคอนหัวข้อ section — วงกลมเขียว + ไอคอนข้างใน (ตาม design)
class _SectionIcon extends StatelessWidget {
  const _SectionIcon({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: const BoxDecoration(
        color: AppColors.ci,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// แถวหัวข้อ section — ไอคอน + ชื่อ + (ปุ่มขวา ถ้ามี)
class _SectionTitleRow extends StatelessWidget {
  const _SectionTitleRow({
    required this.icon,
    required this.title,
    this.trailing,
  });

  final Widget icon;
  final String title;
  final Widget? trailing;

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
              // fontSize: 16.sp,
              color: AppColors.darkBrown,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Badge "ส่งฟรี" — ไอคอนรถส่งของในวงกลมขาว + ข้อความ
///
/// - default: pill gradient เหลือง→เขียว ตัวอักษรขาว (ใช้ในการ์ดการจัดส่ง)
/// - [solid] = true: พื้นเขียวอ่อน มุมโค้งเล็ก ตัวอักษรเขียว (ใช้ในการ์ดสินค้า)
class _FreeShippingBadge extends StatelessWidget {
  const _FreeShippingBadge({this.solid = false});

  final bool solid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDims.size_8.w,
        vertical: AppDims.size_6.h,
      ),
      decoration: BoxDecoration(
        color: solid ? AppColors.ci7 : null,
        gradient: solid ? null : AppColors.claimCoinButtonGradient,
        borderRadius: BorderRadius.circular(solid ? 4.r : 58.r),
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
            child: Assets.icShop.icTruckTick.image(
              width: 12.w,
              height: 12.w,
            ),
          ),
          SizedBox(width: AppDims.size_4.w),
          AppText(
            context.wording.freeShipping,
            style: context.textTheme.labelSmall?.copyWith(
              fontSize: 12.sp,
              color: solid ? AppColors.ci : AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Frame 2087327034 — ที่อยู่จัดส่ง
// ============================================================

/// การ์ดที่อยู่จัดส่ง — โชว์ที่อยู่ที่เลือก, แตะเพื่อเปลี่ยนใน [CustomerShipToPage]
class _ShipToCard extends StatelessWidget {
  const _ShipToCard();

  @override
  Widget build(BuildContext context) {
    final vm = context.read<BrownyShopSelectedViewModel>();
    return ValueListenableBuilder(
      valueListenable: vm.shippingAddressNotifier,
      builder: (context, address, _) {
        return _SectionCard(
          onTap: () async {
            final selected = await CustomerShipToPage.goToPage(context);
            if (selected != null) vm.setShippingAddress(selected);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Assets.svg.icLocationRoundedGreen.svg(width: 28.w, height: 28.w),
              SizedBox(width: AppDims.size_8.w),
              Expanded(
                child: address == null
                    ? _buildEmpty(context)
                    : _buildAddress(context, address),
              ),
              SizedBox(width: AppDims.size_8.w),
              Padding(
                padding: EdgeInsets.only(top: AppDims.size_4.h),
                child: Assets.svg.icArrowForward.svg(
                  width: AppDims.size_16.w,
                  height: AppDims.size_16.w,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ยังไม่มีที่อยู่ที่เลือก — โชว์ข้อความชวนเลือก
  Widget _buildEmpty(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDims.size_4.h),
      child: AppText(
        context.wording.selectAddress,
        style: context.textTheme.titleSmall?.copyWith(
          fontSize: 14.sp,
          color: AppColors.gray500,
        ),
      ),
    );
  }

  Widget _buildAddress(BuildContext context, AddressData address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: AppText(
                address.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleSmall?.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.darkBrown,
                ),
              ),
            ),
            SizedBox(width: AppDims.size_4.w),
            AppText(
              address.phone ?? '',
              style: context.textTheme.titleSmall?.copyWith(
                fontSize: 14.sp,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDims.size_2.h),
        AppText(
          address.fullAddress,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleSmall?.copyWith(
            fontSize: 14.sp,
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Frame 2087327035 — การจัดส่ง
// ============================================================

/// การจัดส่ง — ชื่อ/ระยะเวลายัง mock (รอ API วิธีจัดส่ง) แต่ "ค่าจัดส่ง" ยึดจาก
/// summary จริง (field `shipping_total`) — ถ้า 0 แสดง Badge "ส่งฟรี"
class _ShippingCard extends StatelessWidget {
  const _ShippingCard();

  // ===== mock data (รอ API วิธีจัดส่ง) =====
  static const _methodName = 'Standard Shipping';
  static const _estimate = 'ขนส่งโดยประมาณ 8-11 วัน';

  @override
  Widget build(BuildContext context) {
    final vm = context.read<BrownyShopSelectedViewModel>();
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitleRow(
            icon: _SectionIcon(
              child: Assets.icShop.icBoxLineWhite.image(
                width: 20.w,
                height: 20.w,
              ),
            ),
            title: context.wording.shipping,
          ),
          SizedBox(height: AppDims.size_8.h),
          ValueListenableBuilder(
            valueListenable: vm.summaryNotifier,
            builder: (context, result, _) {
              final shipping = result.data?.shippingTotal ?? 0;
              return _buildOption(context, shipping);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, num shipping) {
    final isFree = shipping <= 0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDims.size_16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.ci),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  _methodName,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.darkBrown,
                  ),
                ),
              ),
              AppText(
                formatCurrency(value: shipping, leadingSign: '฿'),
                style: context.textTheme.titleSmall?.copyWith(
                  color: AppColors.ci,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          AppText(
            _estimate,
            style: context.textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              color: AppColors.gray600,
            ),
          ),
          // แสดง badge "ส่งฟรี" เฉพาะเมื่อค่าจัดส่งจริง = 0
          if (isFree) ...[
            SizedBox(height: AppDims.size_8.h),
            const _FreeShippingBadge(),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// Frame 2087327036 — คูปอง / E-Voucher
// ============================================================

/// กด → เข้าหน้าเลือกคูปอง ([CouponVoucherPage] tab Browny Shop)
///
/// คูปองที่เลือกเก็บใน [BrownyShopSelectedViewModel.selectedCouponNotifier]
/// (auto-apply จาก buy-now ได้ด้วย) — re-validate ทุกครั้งที่แก้จำนวนสินค้า
class _CouponCard extends StatelessWidget {
  const _CouponCard();

  /// เปิดหน้าเลือกคูปอง (tab Browny Shop, flow brownyUsing) แล้วเก็บผลลัพธ์
  Future<void> _onTapCoupon(BuildContext context) async {
    final vm = context.read<BrownyShopSelectedViewModel>();
    final result = await CouponVoucherPage.goToPage(
      context,
      state: CouponVoucherState.brownyUsing,
      brownyShopSelectedCouponId:
          vm.selectedCouponNotifier.value?.customerCouponId,
    );
    if (!context.mounted) return;
    // เลือกคูปอง → CustomerCouponModel | กดคูปองเดิมซ้ำ (ยกเลิก) → false
    // กดกลับเฉยๆ → true/null (ไม่เปลี่ยน)
    if (result is CustomerCouponModel) {
      vm.setSelectedCoupon(result);
    } else if (result == false) {
      vm.setSelectedCoupon(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitleRow(
            icon: _SectionIcon(
              child: Assets.icShop.icTicketLineWhite.image(
                width: 20.w,
                height: 20.w,
              ),
            ),
            title: context.wording.couponAndVoucherCode,
            trailing: GestureDetector(
              onTap: () => _onTapCoupon(context),
              child: Assets.svg.icArrowForward.svg(
                width: AppDims.size_16.w,
                height: AppDims.size_16.w,
              ),
            ),
          ),
          SizedBox(height: AppDims.size_8.h),
          // Consumer — rebuild ทั้งตอนเปลี่ยนคูปองและตอนแก้จำนวน (re-validate)
          Consumer<BrownyShopSelectedViewModel>(
            builder: (context, vm, _) {
              final coupon = vm.selectedCouponNotifier.value;
              if (coupon == null) return _buildUnselected(context);
              return _buildSelected(context, vm, coupon);
            },
          ),
        ],
      ),
    );
  }

  /// ยังไม่เลือกคูปอง — แสดง background ตาม design
  Widget _buildUnselected(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTapCoupon(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 85.h,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Assets.png.bgUnselectedCouponEvoucher.provider(),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  /// เลือกคูปองแล้ว — การ์ด + กรอบเขียว/แดงตามเงื่อนไข + ข้อความ error
  Widget _buildSelected(
    BuildContext context,
    BrownyShopSelectedViewModel vm,
    CustomerCouponModel coupon,
  ) {
    // error คูปองมาจาก server (cart/summary 422) — null = ใช้ได้
    final errorMessage = vm.summaryCouponError;
    final isValid = errorMessage == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _onTapCoupon(context),
          behavior: HitTestBehavior.opaque,
          child: CouponEVoucherCardWidget(
            icon: Image.network(
              coupon.imageUrlDisplay(context),
              errorBuilder: (_, _, _) => Container(color: AppColors.ci2),
            ),
            title: coupon.nameDisplay(context),
            description: coupon.brownyDescriptionDisplay(context),
            detailUsing: coupon.brownyUsageLabelDisplay(context),
            expired: coupon.expiresAtBrownyShopDisplay(context),
            isDisabled: !isValid,
            borderColor: isValid ? AppColors.primary : AppColors.error,
          ),
        ),
        if (!isValid)
          Row(
            spacing: AppDims.size_4.w,
            children: [
              Assets.svg.icInfoRad.svg(),
              Expanded(
                child: AppText(
                  errorMessage,
                  style: context.textTheme.labelSmall!.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

// ============================================================
// Frame 2087327037 — สินค้า (เฉพาะรายการที่เลือกจากตะกร้า)
// ============================================================

/// แสดงเฉพาะ [CartLine] ที่ `selected` — flow ซื้อเลยจะมีแค่ตัวเดียว
class _ProductsCard extends StatelessWidget {
  const _ProductsCard();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitleRow(
            icon: Assets.svg.icLikeBadgeRoundedGreen.svg(
              width: 28.w,
              height: 28.w,
            ),
            title: context.wording.products,
          ),
          SizedBox(height: AppDims.size_16.h),
          Consumer<BrownyShopSelectedViewModel>(
            builder: (context, vm, _) {
              // โชว์เฉพาะรายการที่ติ๊กเลือก — flow ซื้อเลยจะเลือกมาแค่ตัวเดียว
              final lines = vm.lines.where((l) => l.selected).toList();
              if (lines.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: AppDims.size_8.h),
                  child: AppText(
                    context.wording.cartIsEmpty,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                );
              }
              // กล่อง border ครอบรายการสินค้า (Frame 2087328861)
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.productStroke),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: AppDims.size_8.h),
                child: Column(
                  children: [
                    for (var i = 0; i < lines.length; i++) ...[
                      if (i > 0) SizedBox(height: AppDims.size_8.h),
                      _ProductItem(
                        line: lines[i],
                        // checkout ไม่ sync ตะกร้าขึ้น server — แค่ re-fetch
                        // cart/summary (รองรับซื้อบางไอเทม) แล้ว map ยอดจาก summary
                        onIncrement: () => vm.incrementCheckout(lines[i]),
                        onDecrement: () => vm.decrementCheckout(lines[i]),
                      ),
                    ],
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

/// 1 รายการสินค้าในหน้า checkout — render จาก [CartLine] (ตะกร้าจริง)
class _ProductItem extends StatelessWidget {
  const _ProductItem({
    required this.line,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CartLine line;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final locale = context.languageCode;
    final productName = line.data.product?.getNameDisplay(locale);
    final name = (productName != null && productName.isNotEmpty)
        ? productName
        : (line.data.productName ?? '');
    final variantName = line.data.matchedSub?.getNameDisplay(locale);
    final variant = (variantName != null && variantName.isNotEmpty)
        ? variantName
        : (line.data.variantName ?? '');
    final isFreeShipping = line.data.product?.isFreeShipping ?? false;

    // bg ใส — item อยู่ในกล่อง border ของ _ProductsCard (Frame 2087326971)
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDims.size_8.w,
        vertical: AppDims.size_4.h,
      ),
      child: Row(
        children: [
          _buildImage(),
          SizedBox(width: AppDims.size_8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: AppColors.darkBrown,
                  ),
                ),
                if (variant.isNotEmpty)
                  AppText(
                    variant,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                if (isFreeShipping) ...[
                  SizedBox(height: AppDims.size_4.h),
                  const _FreeShippingBadge(solid: true),
                ],
                SizedBox(height: AppDims.size_8.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _buildPrices(context)),
                    _buildQtyStepper(context),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final url = line.data.imageUrl;
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
              imageUrl: line.data.product!.mainImageUrl.orEmpty,
              fit: BoxFit.contain,
              errorWidget: (_, _, _) => CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                errorWidget: (_, _, _) => Icon(
                  Icons.image_outlined,
                  size: 32.w,
                  color: AppColors.gray400,
                ),
              ),
            ),
    );
  }

  Widget _buildPrices(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (line.data.unitCoinPrice != null)
          Row(
            children: [
              Assets.png.brownyCoin.image(width: 12.w),
              SizedBox(width: AppDims.size_4.w),
              AppText(
                formatCurrency(
                  value: line.unitCoinPrice,
                  trailingSign: ' ${context.wording.coin}',
                ),
                style: context.textTheme.titleSmall?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        SizedBox(height: 2.h),
        AppText(
          formatCurrency(value: line.unitMoneyPrice, leadingSign: '฿'),
          style: context.textTheme.titleSmall?.copyWith(
            color: AppColors.ci,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// ปรับจำนวน — ผูกกับ ViewModel (debounced batch sync เดียวกับหน้าตะกร้า)
  Widget _buildQtyStepper(BuildContext context) {
    final atMin = line.quantity <= 1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _qtyButton(Icons.remove, enabled: !atMin, onTap: onDecrement),
        SizedBox(width: AppDims.size_8.w),
        AppText(
          '${line.quantity}',
          style: context.textTheme.titleSmall?.copyWith(
            fontSize: 16.sp,
            color: AppColors.black.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: AppDims.size_8.w),
        _qtyButton(Icons.add, enabled: true, onTap: onIncrement),
      ],
    );
  }

  Widget _qtyButton(
    IconData icon, {
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 18.w,
        height: 18.w,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.gray400,
          borderRadius: BorderRadius.circular(2.r),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 12.w, color: AppColors.white),
      ),
    );
  }
}

// ============================================================
// Frame 2087327038 — เลือกวิธีการชำระเงิน (logic จริง)
// ============================================================

/// reuse ระบบ payment ของ [TransactionsViewmodel] — กด "ดูทั้งหมด" ไป
/// [AvailablePaymentMethodPage], กดเลือก → `vm.onPaymentChanged`
class _PaymentCard extends StatelessWidget {
  const _PaymentCard();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitleRow(
            icon: Assets.svg.icWalletRoundedGreen.svg(
              width: 28.w,
              height: 28.w,
            ),
            title: context.wording.selectPaymentMethod,
            trailing: GestureDetector(
              onTap: () => AvailablePaymentMethodPage.goToPage(
                context,
                viewmodel: context.read<BrownyShopSelectedViewModel>(),
              ),
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    context.wording.seeAll,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  SizedBox(width: AppDims.size_8.w),
                  Assets.svg.icArrowForward.svg(
                    width: AppDims.size_16.w,
                    height: AppDims.size_16.w,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppDims.size_8.h),
          Consumer<BrownyShopSelectedViewModel>(
            builder: (context, vm, _) {
              return ValueListenableBuilder(
                valueListenable: vm.paymentMethodNotifier,
                builder: (context, result, _) {
                  if (result.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!result.isSuccess || (result.data?.isEmpty ?? true)) {
                    return AppText(
                      context.wording.errorUi,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray500,
                      ),
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: result.data!
                        .take(3)
                        .map(
                          (payment) => _PaymentMethodTile(
                            payment: payment,
                            onTap: () => vm.onPaymentChanged(payment),
                          ),
                        )
                        .toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 1 วิธีชำระเงิน — ยก design จาก [MachineTransactionPage2] `_cardPaymentDependOnState`
///
/// การ์ดมีกรอบเสมอ — เลือกอยู่ = กรอบเขียวหนา + ติ๊กถูก
/// TP+ Wallet ที่เลือกอยู่ โชว์ยอดเงินคงเหลือ + ปุ่มเติมเงิน,
/// Coin โชว์มูลค่า + จำนวนเหรียญ
class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({required this.payment, required this.onTap});

  final PaymentMethodModel payment;
  final VoidCallback onTap;

  TextStyle _textPrimary(BuildContext context) =>
      context.textTheme.labelLarge!.copyWith(color: AppColors.textPrimary);

  TextStyle _textPrimarySelected(BuildContext context) =>
      context.textTheme.labelLarge!.copyWith(color: AppColors.primary);

  @override
  Widget build(BuildContext context) {
    final isSelected = payment.isSelected;
    final isTPWallet = payment.isTpWallet;
    final isCoin = payment.isCoin;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppDims.size_8.h),
        padding: EdgeInsets.symmetric(
          horizontal: AppDims.size_16.w,
          vertical: AppDims.size_16.h,
        ),
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: AppColors.primary, width: AppDims.size_2.h)
              : null,
          borderRadius: BorderRadius.circular(AppDims.size_8.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ListTile(
              minVerticalPadding: 0,
              contentPadding: EdgeInsets.zero,
              minTileHeight: 0,
              horizontalTitleGap: AppDims.size_8.w,
              leading: payment.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: payment.imageUrl!,
                      width: 22.w,
                      height: 22.h,
                      fit: BoxFit.contain,
                      placeholder: (_, _) =>
                          SizedBox(width: 22.w, height: 22.h),
                      errorWidget: (_, _, _) =>
                          SizedBox(width: 22.w, height: 22.h),
                    )
                  : null,
              title: AppText(
                payment.name,
                style: isSelected
                    ? _textPrimarySelected(context)
                    : _textPrimary(context),
              ),
              trailing: isSelected
                  ? Padding(
                      padding: EdgeInsets.only(right: 6.0.w),
                      child: Assets.svg.icChecked.svg(),
                    )
                  : null,
            ),
            if (isTPWallet && isSelected) ...[
              Consumer<CustomerProvider>(
                builder: (context, provider, _) {
                  return ListTile(
                    minVerticalPadding: AppDims.size_8.h,
                    contentPadding: EdgeInsets.zero,
                    minTileHeight: 0,
                    horizontalTitleGap: AppDims.size_8.w,
                    title: AppText(
                      context.wording.balanceRemaining,
                      style: _textPrimary(context),
                    ),
                    trailing: AppText(
                      formatCurrency(
                        leadingSign: '฿ ',
                        string: provider.current.creditBalance,
                        decimal: true,
                      ),
                      style: _textPrimarySelected(
                        context,
                      ).copyWith(fontWeight: FontWeight.w500),
                    ),
                  );
                },
              ),
              ElevatedButton(
                onPressed: () => WalletPage.goToPage(context),
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
            if (isCoin) ...[
              Consumer<CustomerProvider>(
                builder: (context, provider, _) {
                  return ListTile(
                    minVerticalPadding: AppDims.size_8.h,
                    contentPadding: EdgeInsets.zero,
                    minTileHeight: 0,
                    horizontalTitleGap: AppDims.size_8.w,
                    title: AppText(
                      context.wording.coinValue,
                      style: _textPrimary(context),
                    ),
                    trailing: AppText(
                      formatCurrency(
                        leadingSign: '฿ ',
                        string: provider.current.currentCoin,
                        decimal: true,
                      ),
                      style: _textPrimarySelected(context).copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                },
              ),
              Consumer<CustomerProvider>(
                builder: (context, provider, _) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: AppDims.size_4.w,
                    children: [
                      payment.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: payment.imageUrl!,
                              width: AppDims.size_12.w,
                              height: AppDims.size_12.h,
                              fit: BoxFit.contain,
                              placeholder: (_, _) => SizedBox(
                                width: AppDims.size_12.w,
                                height: AppDims.size_12.h,
                              ),
                              errorWidget: (_, _, _) => SizedBox(
                                width: AppDims.size_12.w,
                                height: AppDims.size_12.h,
                              ),
                            )
                          : SizedBox(
                              width: AppDims.size_12.w,
                              height: AppDims.size_12.h,
                            ),
                      AppText(
                        formatCurrency(
                          string: provider.current.brownyCoin,
                          decimal: true,
                          trailingSign: ' ${context.wording.coin}',
                        ),
                        style: _textPrimarySelected(context).copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Frame 2087327041 — สรุปการสั่งซื้อ
// ============================================================

/// สรุปยอด — ยึดราคา/ส่วนลดจริงจากรายการที่ติ๊กเลือกในตะกร้า ([CartLine])
///
/// TODO(api): ส่วนลดคูปอง + ค่าจัดส่ง รอ shop coupon/order API — แสดง ฿0.00
class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard();

  @override
  Widget build(BuildContext context) {
    final vm = context.read<BrownyShopSelectedViewModel>();
    return _SectionCard(
      child: ValueListenableBuilder(
        valueListenable: vm.summaryNotifier,
        builder: (context, result, _) {
          final s = result.data;
          // ส่วนลดสินค้า = flash sale + product discount (รวมเป็นบรรทัดเดียว)
          final productDiscount =
              (s?.flashSaleDiscount ?? 0) + (s?.productDiscount ?? 0);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitleRow(
                icon: Assets.svg.icListRoundedGreen.svg(
                  width: 28.w,
                  height: 28.w,
                ),
                title: context.wording.orderSummary,
              ),
              SizedBox(height: AppDims.size_16.h),
              // ราคาสินค้า — ยอดรวมก่อนหักส่วนลด (subtotal)
              _line(
                context,
                title: context.wording.productSubtotal,
                value: formatCurrency(value: s?.subtotal ?? 0, leadingSign: '฿'),
              ),
              SizedBox(height: AppDims.size_16.h),
              // ส่วนลดสินค้า (flash sale + product discount)
              _line(
                context,
                title: context.wording.productDiscount,
                value: formatCurrency(value: productDiscount, leadingSign: '฿'),
                valueColor: AppColors.error,
              ),
              SizedBox(height: AppDims.size_16.h),
              // คูปอง / E-Voucher — coupon_discount จาก summary
              _line(
                context,
                icon: _lineIcon(
                  Assets.icShop.icTicket.image(width: 16.w, height: 16.w),
                ),
                title: context.wording.couponAndVoucherCode,
                value: formatCurrency(
                  value: s?.couponDiscount ?? 0,
                  leadingSign: '฿',
                ),
                valueColor: AppColors.error,
              ),
              SizedBox(height: AppDims.size_16.h),
              // ค่าจัดส่ง — shipping_total จาก summary
              _line(
                context,
                icon: _lineIcon(
                  Assets.icShop.icBox.image(width: 16.w, height: 16.w),
                ),
                title: context.wording.shipping,
                value: formatCurrency(
                  value: s?.shippingTotal ?? 0,
                  leadingSign: '฿',
                ),
              ),
              SizedBox(height: AppDims.size_16.h),
              // ยอดชำระทั้งหมด (final_price)
              _line(
                context,
                title: context.wording.totalPayment,
                value: formatCurrency(
                  value: s?.finalPrice ?? 0,
                  leadingSign: '฿',
                ),
                valueColor: AppColors.ci,
                bold: true,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _lineIcon(Widget child) {
    return Container(
      width: 22.w,
      height: 22.w,
      decoration: const BoxDecoration(
        color: AppColors.ci7,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _line(
    BuildContext context, {
    Widget? icon,
    required String title,
    required String value,
    Color valueColor = AppColors.darkBrown,
    bool bold = false,
  }) {
    return Row(
      children: [
        if (icon != null) ...[icon, SizedBox(width: AppDims.size_16.w)],
        Expanded(
          child: AppText(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              color: AppColors.darkBrown,
            ),
          ),
        ),
        AppText(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            color: valueColor,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Frame 2087326691 — bar ล่าง
// ============================================================

/// bar ล่าง — ส่วนลด/ยอดชำระยึดจาก summary จริง (cart/summary)
/// ปุ่มชำระเงิน → [onPay] (POST /checkout/confirm)
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onPay});

  /// callback เมื่อกดปุ่มชำระเงิน — orchestrate confirm/QR/polling ที่ page state
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: const [
          BoxShadow(color: Color(0x33928B8B), blurRadius: 16, spreadRadius: 8),
        ],
      ),
      padding: EdgeInsets.only(
        left: AppDims.size_16.w,
        right: AppDims.size_16.w,
        top: AppDims.size_8.h,
        bottom: AppDims.size_32.h,
      ),
      child: Consumer<BrownyShopSelectedViewModel>(
        builder: (context, vm, _) {
          final summary = vm.summaryNotifier.value;
          final s = summary.data;
          // enable ครั้งเดียวหลัง POST /cart/summary เสร็จ — ระหว่างแก้จำนวน/
          // คูปอง/วิธีชำระ summary จะเป็น loading ทำให้ปุ่ม disable (กันกระพริบ)
          // + ปิดปุ่มถ้าคูปองที่เลือกไม่เข้าเงื่อนไข (summaryCouponError != null)
          final enabled =
              summary.isSuccess && s != null && vm.summaryCouponError == null;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    '${context.wording.totalDiscount} ',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  AppText(
                    formatCurrency(
                      value: s?.totalDiscount ?? 0,
                      leadingSign: '฿',
                    ),
                    style: context.textTheme.titleSmall?.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDims.size_8.h),
              _button(
                context,
                label:
                    '${context.wording.makePayment} '
                    '${formatCurrency(value: s?.finalPrice ?? 0, leadingSign: '฿')}',
                background: AppColors.ci,
                textColor: AppColors.white,
                enabled: enabled,
                onTap: onPay,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _button(
    BuildContext context, {
    required String label,
    required Color background,
    required Color textColor,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        height: AppDims.size_40.h,
        decoration: BoxDecoration(
          color: enabled ? background : AppColors.gray400,
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: AppText(
          label,
          style: context.textTheme.labelLarge?.copyWith(
            fontSize: 14.sp,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
