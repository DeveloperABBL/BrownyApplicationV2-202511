import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/address_response.dart';
import 'package:browny_applications_new/feature/browny_shop/screens/customer_ship_to_page.dart';
import 'package:browny_applications_new/feature/browny_shop/viewmodel/browny_shop_selected_viewmodel.dart';
import 'package:browny_applications_new/feature/transactions/models/coupon_detail_model.dart';
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

class _BrownyShopSelectedWidgetState extends State<_BrownyShopSelectedWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ตะกร้า (vm.lines) ถูกโหลดจากหน้าตะกร้าแล้ว — ที่นี่โหลด payment methods
      // + ที่อยู่จัดส่งเริ่มต้น (ที่อยู่หลัก)
      final vm = context.read<BrownyShopSelectedViewModel>();
      vm.fetchPaymentMethod(context);
      vm.loadDefaultShippingAddress();
    });
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
      bottomNavigationBar: const _BottomBar(), // Frame 2087326691
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
              fontSize: 16.sp,
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
          style: context.textTheme.bodyMedium?.copyWith(
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

/// TODO(api): API วิธีจัดส่งยังไม่พร้อม — mock ข้อมูลตาม design ไปก่อน
class _ShippingCard extends StatelessWidget {
  const _ShippingCard();

  // ===== mock data (รอ API) =====
  static const _methodName = 'Standard Shipping';
  static const _estimate = 'ขนส่งโดยประมาณ 8-11 วัน';

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitleRow(
            icon: _SectionIcon(
              child: Assets.icShop.icBoxLineWhite.image(
                width: 20.w,
                height: 20.w,
                // color: AppColors.white,
              ),
            ),
            title: context.wording.shipping,
          ),
          SizedBox(height: AppDims.size_8.h),
          _buildOption(context),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context) {
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
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.darkBrown,
                  ),
                ),
              ),
              AppText(
                formatCurrency(value: 0, leadingSign: '฿'),
                style: context.textTheme.titleSmall?.copyWith(
                  fontSize: 14.sp,
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
          SizedBox(height: AppDims.size_8.h),
          const _FreeShippingBadge(),
        ],
      ),
    );
  }
}

// ============================================================
// Frame 2087327036 — คูปอง / E-Voucher
// ============================================================

/// กด → เข้าหน้าเลือกคูปอง/E-Voucher ([CouponVoucherPage] state brownyShop)
///
/// TODO(api): การ์ดคูปองที่เลือกยัง mock — รอ API คูปองของ shop
class _CouponCard extends StatelessWidget {
  const _CouponCard();

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
                // color: AppColors.white,
              ),
            ),
            // icon: Assets.icShop.icTicketLineWhite.image(
            //   width: 28.w,
            //   height: 28.w,
            // ),
            title: context.wording.couponAndVoucherCode,
            trailing: GestureDetector(
              onTap: () => CouponVoucherPage.goToPage(
                context,
                state: CouponVoucherState.brownyShop,
              ),
              child: Assets.svg.icArrowForward.svg(
                width: AppDims.size_16.w,
                height: AppDims.size_16.w,
              ),
            ),
          ),
          SizedBox(height: AppDims.size_8.h),
          GestureDetector(
            onTap: () => CouponVoucherPage.goToPage(
              context,
              state: CouponVoucherState.brownyShop,
            ),
            behavior: HitTestBehavior.opaque,
            child: _buildCouponPreview(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponPreview(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.ci),
        borderRadius: BorderRadius.circular(8.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(
            width: AppDims.size_85.w,
            height: AppDims.size_85.w,
            color: const Color(0xA681E287),
            alignment: Alignment.center,
            child: Assets.icShop.icTruckTick.image(
              width: 32.w,
              height: 32.w,
            ),
          ),
          SizedBox(width: AppDims.size_8.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppDims.size_8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    // คูปองส่งฟรี ไม่มีขั้นต่ำ
                    context.wording.freeShippingCouponNoMin,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  AppText(
                    context.wording.onlyParticipatingItems,
                    style: context.textTheme.labelSmall?.copyWith(
                      fontSize: 10.sp,
                      color: AppColors.ci,
                    ),
                  ),
                  SizedBox(height: AppDims.size_8.h),
                  AppText(
                    // mock — รอ API
                    '${context.wording.couponExpiresLabel} 12 พ.ย. 2025',
                    style: context.textTheme.labelSmall?.copyWith(
                      fontSize: 10.sp,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
              return Column(
                children: [
                  for (var i = 0; i < lines.length; i++) ...[
                    if (i > 0) SizedBox(height: AppDims.size_16.h),
                    _ProductItem(
                      line: lines[i],
                      onIncrement: () => vm.increment(lines[i]),
                      onDecrement: () => vm.decrement(lines[i]),
                    ),
                  ],
                ],
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

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8.r),
      ),
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
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.darkBrown,
                  ),
                ),
                if (variant.isNotEmpty)
                  AppText(
                    variant,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelSmall?.copyWith(
                      fontSize: 10.sp,
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
              Assets.png.brownyCoin.image(width: 10.w, height: 10.w),
              SizedBox(width: AppDims.size_4.w),
              AppText(
                formatCurrency(
                  value: line.unitCoinPrice,
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
        SizedBox(height: 2.h),
        AppText(
          formatCurrency(value: line.unitMoneyPrice, leadingSign: '฿'),
          style: context.textTheme.titleSmall?.copyWith(
            fontSize: 14.sp,
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
    return _SectionCard(
      child: Consumer<BrownyShopSelectedViewModel>(
        builder: (context, vm, _) {
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
              // ราคาสินค้า — ยอดรวมก่อนหักส่วนลด
              _line(
                context,
                title: context.wording.productSubtotal,
                value: formatCurrency(
                  value: vm.selectedMoneySubtotal,
                  leadingSign: '฿',
                ),
              ),
              SizedBox(height: AppDims.size_16.h),
              // ส่วนลดสินค้า — รวมส่วนลดของรายการที่เลือก
              _line(
                context,
                title: context.wording.productDiscount,
                value: formatCurrency(
                  value: vm.selectedMoneyDiscount,
                  leadingSign: '฿',
                ),
                valueColor: AppColors.error,
              ),
              SizedBox(height: AppDims.size_16.h),
              // คูปอง / E-Voucher — TODO(api): รอ API คูปองของ shop
              _line(
                context,
                icon: _lineIcon(
                  Assets.icShop.icTicket.image(width: 16.w, height: 16.w),
                ),
                title: context.wording.couponAndVoucherCode,
                value: formatCurrency(value: 0, leadingSign: '฿'),
                valueColor: AppColors.error,
              ),
              SizedBox(height: AppDims.size_16.h),
              // ค่าจัดส่ง — TODO(api): รอ API วิธีจัดส่ง
              _line(
                context,
                icon: _lineIcon(
                  Assets.icShop.icBox.image(width: 16.w, height: 16.w),
                ),
                title: context.wording.shipping,
                value: formatCurrency(value: 0, leadingSign: '฿'),
              ),
              SizedBox(height: AppDims.size_16.h),
              // ยอดชำระทั้งหมด
              _line(
                context,
                title: context.wording.totalPayment,
                value: formatCurrency(
                  value: vm.selectedMoneyGrandTotal,
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
              fontSize: 16.sp,
              color: AppColors.darkBrown,
            ),
          ),
        ),
        AppText(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: 16.sp,
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

/// bar ล่าง — ส่วนลด/ยอดชำระยึดจากรายการที่ติ๊กเลือกในตะกร้า
///
/// TODO(api): การกดปุ่มชำระเงินรอ shop order API — ตอนนี้ยัง debugPrint
class _BottomBar extends StatelessWidget {
  const _BottomBar();

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
                      value: vm.selectedMoneyDiscount,
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
                    '${formatCurrency(value: vm.selectedMoneyGrandTotal, leadingSign: '฿')}',
                background: AppColors.ci,
                textColor: AppColors.white,
                // ปิดปุ่มระหว่าง sync ตะกร้า / ยังไม่มีของติ๊กเลือก
                enabled: vm.canCheckout,
                onTap: () => debugPrint('tap pay (TODO)'),
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
