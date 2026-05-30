import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/feature/browny_shop/models/browny_shop_order_status_model.dart';
import 'package:browny_applications_new/feature/browny_shop/viewmodel/browny_shop_order_status_viewmodel.dart';
import 'package:browny_applications_new/feature/contacts/models/contact_model.dart';
import 'package:browny_applications_new/feature/contacts/screens/contact_page.dart';
import 'package:browny_applications_new/feature/home/screens/home_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

/// หน้าสถานะคำสั่งซื้อ Browny Shop (Figma node 185:4613)
///
/// แสดงสถานะออร์เดอร์ทั้งที่ยังไม่ชำระเงิน / ชำระแล้ว / ระหว่างจัดส่ง — รับ
/// [orderId] เข้ามาเพื่อให้ VM fetch ข้อมูล (API ยังไม่พร้อม → mock ตาม design)
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
      create: (ctx) =>
          BrownyShopOrderStatusViewModel(context: ctx, orderId: orderId),
      child: const _OrderStatusWidget(),
    );
  }
}

class _OrderStatusWidget extends StatefulWidget {
  const _OrderStatusWidget();

  @override
  State<_OrderStatusWidget> createState() => _OrderStatusWidgetState();
}

class _OrderStatusWidgetState extends State<_OrderStatusWidget> {
  BrownyShopOrderStatusViewModel get _vm =>
      context.read<BrownyShopOrderStatusViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _vm.attachContext(context);
    });
  }

  void _popToHome() {
    context.popUntil(
      predicate: (route) => route.name.orEmpty == HomePage.pageName,
    );
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
          vertical: AppDims.size_16.h,
        ),
      ),
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
      bottomNavigationBar: _BottomBar(onBack: _popToHome),
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
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
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
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDims.size_16.w),
        child: SizedBox(
          height: AppDims.size_56.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AppText(
                context.wording.orderStatus,
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
            style: context.textTheme.titleSmall?.copyWith(
              fontSize: 14.sp,
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
          Expanded(
            child: AppText(
              label,
              style: context.textTheme.titleMedium?.copyWith(
                fontSize: 14.sp,
                color: AppColors.gray600,
              ),
            ),
          ),
          SizedBox(width: AppDims.size_8.w),
          Expanded(
            child: AppText(
              value ?? '',
              textAlign: TextAlign.end,
              style: context.textTheme.titleSmall?.copyWith(
                fontSize: 14.sp,
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
                fontSize: 14.sp,
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
// ผู้ขาย / ที่อยู่ติดต่อ
// ============================================================

class _SellerCard extends StatelessWidget {
  const _SellerCard({required this.data});

  final BrownyShopOrderStatusModel data;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: const BoxDecoration(
              color: AppColors.ci7,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Assets.icShop.icBoxLineWhite.image(
              width: 16.w,
              height: 16.w,
            ),
          ),
          SizedBox(width: AppDims.size_8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: AppText(
                        data.recipientName,
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
                      data.phone,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontSize: 14.sp,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDims.size_2.h),
                AppText(
                  data.fullAddress,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppDims.size_8.w),
          Assets.svg.icArrowForward.svg(width: 16.w, height: 16.w),
        ],
      ),
    );
  }
}

// ============================================================
// สถานะ + stepper + เลขพัสดุ + ข้อมูลการจัดส่ง
// ============================================================

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.data, required this.onCopyTracking});

  final BrownyShopOrderStatusModel data;
  final void Function(String) onCopyTracking;

  /// hero image (Frame 2087326612) — pending ใช้ warning ตาม locale, นอกนั้น thank you
  AssetGenImage _heroAsset(BuildContext context) {
    if (!data.isPending) return Assets.icShop.brownyThankYou;
    switch (context.languageCode) {
      case 'en':
        return Assets.icShop.brownyWarningTransferEn;
      case 'zh':
        return Assets.icShop.brownyWarningTransferZh;
      default:
        return Assets.icShop.brownyWarningTransferTh;
    }
  }

  String _bannerText(BuildContext context) {
    if (data.isPending) return context.wording.pendingPayment;
    return context.wording.waitingForDelivery;
  }

  @override
  Widget build(BuildContext context) {
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
          _StatusBanner(text: _bannerText(context)),
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
                    fontSize: 14.sp,
                    color: AppColors.gray600,
                  ),
                ),
              ),
              if (data.hasTrackingNumber)
                AppText(
                  data.trackingNumber!,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: 14.sp,
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
              onTap: data.trackingNumber.orEmpty.isNotEmpty
                  ? () => onCopyTracking(data.trackingNumber!)
                  : null,
              green: data.trackingNumber.orEmpty.isNotEmpty,
            ),
          ),
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
            label: context.wording.recipientName,
            value: data.recipientName,
          ),
          _DetailRow(
            label: context.wording.phoneNumber,
            value: data.phone,
          ),
          SizedBox(height: AppDims.size_2.h),
          AppText(
            context.wording.shippingAddressDetail,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: 14.sp,
              color: AppColors.gray600,
            ),
          ),
          SizedBox(height: AppDims.size_4.h),
          AppText(
            data.fullAddress,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: 14.sp,
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}

/// stepper 3 ขั้น (Frame 2087326634) — สั่งซื้อ → ชำระเงิน → จัดส่ง
class _StatusStepper extends StatelessWidget {
  const _StatusStepper({required this.data});

  final BrownyShopOrderStatusModel data;

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
          icon: Assets.icShop.icCartRoundedGreen,
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
          icon: data.isDelivered
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
      // width: 78.w,
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
              fontSize: 12.sp,
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

/// แถบสถานะ — "รอจัดส่ง" / "รอชำระเงิน"
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDims.size_8.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDBC),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Assets.icShop.icTruckRoundedOrange.image(
            width: 24.w,
            height: 24.w,
          ),
          SizedBox(width: AppDims.size_8.w),
          AppText(
            text,
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: 12.sp,
              color: AppColors.gray500,
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

  final BrownyShopOrderStatusModel data;
  final void Function(String) onCopy;

  @override
  Widget build(BuildContext context) {
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
                  fontSize: 14.sp,
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
          for (var i = 0; i < data.products.length; i++) ...[
            if (i > 0) SizedBox(height: AppDims.size_16.h),
            _ProductItem(product: data.products[i]),
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
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.textBare,
                  ),
                ),
                AppText(
                  formatCurrency(value: data.orderTotal, leadingSign: '฿'),
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: 14.sp,
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
  const _ProductItem({required this.product});

  final BrownyShopOrderStatusProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFC),
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
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.darkBrown,
                  ),
                ),
                if (product.isFreeShipping) ...[
                  SizedBox(height: AppDims.size_4.h),
                  const _FreeShippingChip(),
                ],
                SizedBox(height: AppDims.size_8.h),
                _prices(context),
                SizedBox(height: AppDims.size_4.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppText(
                    'x${product.quantity}',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontSize: 14.sp,
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
    final url = product.imageUrl;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.coinPrice != null)
          Row(
            children: [
              _CoinChip(coin: product.coinPrice!),
              if (product.hasCoinDiscount) ...[
                SizedBox(width: AppDims.size_4.w),
                AppText(
                  formatCurrency(value: product.originalCoinPrice!),
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
              formatCurrency(value: product.moneyPrice, leadingSign: '฿'),
              style: context.textTheme.titleSmall?.copyWith(
                fontSize: 14.sp,
                color: AppColors.ci,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (product.hasMoneyDiscount) ...[
              SizedBox(width: AppDims.size_4.w),
              AppText(
                formatCurrency(
                  value: product.originalMoneyPrice!,
                  leadingSign: '฿',
                ),
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
        color: const Color(0xFFC9F3CB),
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
              fontSize: 10.sp,
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

  final BrownyShopOrderStatusModel data;

  @override
  Widget build(BuildContext context) {
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
                    fontSize: 14.sp,
                    color: AppColors.gray600,
                  ),
                ),
              ),
              SizedBox(width: AppDims.size_8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText(
                    data.paymentChannelName,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.gray600,
                    ),
                  ),
                  if (data.paymentLogoUrl != null) ...[
                    SizedBox(height: AppDims.size_4.h),
                    CachedNetworkImage(
                      imageUrl: data.paymentLogoUrl!,
                      width: 30.w,
                      height: 30.w,
                      fit: BoxFit.contain,
                      errorWidget: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ],
                  SizedBox(height: AppDims.size_8.h),
                  Container(
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
                        fontSize: 14.sp,
                        color: AppColors.ci,
                      ),
                    ),
                  ),
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
                      fontSize: 14.sp,
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

  final BrownyShopOrderStatusModel data;
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
            style: context.textTheme.titleSmall?.copyWith(
              fontSize: 14.sp,
              color: AppColors.textBare,
            ),
          ),
          SizedBox(height: AppDims.size_8.h),
          Row(
            children: [
              AppText(
                'Order ID',
                style: context.textTheme.titleMedium?.copyWith(
                  fontSize: 14.sp,
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

              // SizedBox(width: AppDims.size_8.w),
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
          if (data.orderTime != null)
            _DetailRow(
              label: context.wording.orderTime,
              value: data.orderTime,
            ),
          if (data.paymentTime != null)
            _DetailRow(
              label: context.wording.paymentTime,
              value: data.paymentTime,
            ),
          if (data.deliveryTime != null)
            _DetailRow(
              label: context.wording.deliveryTime,
              value: data.deliveryTime,
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
// bar ล่าง — กลับไปหน้าหลัก
// ============================================================

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onBack});

  final VoidCallback onBack;

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
        onTap: onBack,
        child: Container(
          width: double.infinity,
          height: AppDims.size_40.h,
          decoration: BoxDecoration(
            color: AppColors.ci,
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: AppText(
            context.wording.backToHome,
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
