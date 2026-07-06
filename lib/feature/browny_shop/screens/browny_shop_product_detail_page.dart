import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/products_response.dart';
import 'package:browny_applications_new/feature/browny_shop/providers/browny_shop_cart_count_store.dart';
import 'package:browny_applications_new/feature/browny_shop/providers/browny_shop_favorite_store.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:browny_applications_new/feature/browny_shop/widgets/cart_count_badge.dart';
import 'package:browny_applications_new/feature/browny_shop/viewmodel/browny_shop_product_detail_viewmodel.dart';
import 'package:browny_applications_new/feature/browny_shop/screens/browny_shop_cart_page.dart';
import 'package:browny_applications_new/feature/browny_shop/screens/customer_ship_to_page.dart';
import 'package:browny_applications_new/feature/browny_shop/widgets/add_to_cart_bottom_sheet.dart';
import 'package:browny_applications_new/feature/contacts/models/contact_model.dart';
import 'package:browny_applications_new/feature/contacts/screens/contact_page.dart';
import 'package:browny_applications_new/feature/transactions/models/customer_coupon_model.dart';
import 'package:browny_applications_new/feature/transactions/screens/coupons_evoucher/coupon_voucher_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';

/// หน้ารายละเอียดสินค้าใน Browny Shop
///
/// Figma: node 56:20103
class BrownyShopProductDetailPage extends StatelessWidget {
  const BrownyShopProductDetailPage({super.key, required this.productId});

  static final pagePath = '/browny_shop_product_detail_page/:productId';
  static final pageName = 'BrownyShopProductDetailPage';

  /// Path param: product UUID
  static const kProductId = 'productId';

  final String productId;

  static Future<T?> goToPage<T>(
    BuildContext context, {
    required String productId,
  }) async {
    return await context.pushNamed(
      BrownyShopProductDetailPage.pageName,
      pathParameters: {kProductId: productId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BrownyShopProductDetailViewmodel(
        context: context,
        repo: BrownyShopRepo(),
        productId: productId,
      ),
      child: const _BrownyShopProductDetailWidget(),
    );
  }
}

class _BrownyShopProductDetailWidget extends StatefulWidget {
  const _BrownyShopProductDetailWidget();

  @override
  State<_BrownyShopProductDetailWidget> createState() =>
      _BrownyShopProductDetailWidgetState();
}

class _BrownyShopProductDetailWidgetState
    extends State<_BrownyShopProductDetailWidget> {
  BrownyShopProductDetailViewmodel get _vm =>
      context.read<BrownyShopProductDetailViewmodel>();

  /// AppBar overlay จะ slide ขึ้นเมื่อ user scroll ลง และ slide กลับมาเมื่อ scroll ขึ้น
  bool _isAppBarVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm.attachContext(context);
      _vm.fetchProductDetail();
      // อัปเดตจำนวนตะกร้าสำหรับ badge
      context.read<BrownyShopCartCountStore>().refresh(
        context.read<CustomerProvider>().current.id.orEmpty,
      );
    });
  }

  bool _onScrollNotification(UserScrollNotification notification) {
    final direction = notification.direction;
    if (direction == ScrollDirection.reverse && _isAppBarVisible) {
      setState(() => _isAppBarVisible = false);
    } else if (direction == ScrollDirection.forward && !_isAppBarVisible) {
      setState(() => _isAppBarVisible = true);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: ValueListenableBuilder(
        valueListenable: _vm.productNotifier,
        builder: (context, result, _) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (result.hasError || result.isEmpty || result.data == null) {
            return Center(child: AppText(context.wording.errorUi));
          }
          return Stack(
            children: [
              NotificationListener<UserScrollNotification>(
                onNotification: _onScrollNotification,
                child: _buildContent(context, result.data!),
              ),
              _buildAppBar(context),
            ],
          );
        },
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: _vm.productNotifier,
        builder: (context, result, _) {
          if (!result.isSuccess) return const SizedBox.shrink();
          return _BottomActionBar(product: result.data!);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProductData product) {
    // bg #F5F5F5 เห็นเป็นช่องว่าง 8px ระหว่างแต่ละ section
    return ColoredBox(
      color: AppColors.inputFieldDefaultBg,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // [Section 1] รูปสินค้า + ราคา + ชื่อ (มุมบนโค้ง 16)
            _Section(
              topRounded: true,
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MainImage(vm: _vm, product: product),
                  _ThumbnailStrip(vm: _vm, product: product),
                  AppDims.vericalPadding_16,
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDims.size_16.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PriceSection(product: product),
                        AppDims.vericalPadding_8,
                        _TitleSection(product: product),
                      ],
                    ),
                  ),
                  AppDims.vericalPadding_16,
                ],
              ),
            ),
            _sectionGap,
            // [Section 2] สูตร (product_subs)
            _Section(
              child: _ProductSubsSection(vm: _vm, product: product),
            ),
            // TODO(api): [Section 3] "ขนาด" — ยังไม่มี API รองรับ ข้ามไปก่อน
            _sectionGap,
            // [Section 4] คูปอง/E-Voucher + ที่อยู่จัดส่ง
            _Section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CouponCard(),
                  AppDims.vericalPadding_8,
                  const _ShippingInfo(),
                ],
              ),
            ),
            _sectionGap,
            // [Section 5] รายละเอียดเพิ่มเติม — คำอธิบาย + แกลเลอรีรูป (collapse)
            _Section(child: _MoreInfoSection(product: product)),
          ],
        ),
      ),
    );
  }

  /// ช่องว่างระหว่าง section (เห็นพื้น #F5F5F5)
  Widget get _sectionGap => SizedBox(height: AppDims.size_8.h);

  /// AppBar overlay — back button + bag + headset (semi-transparent brown)
  ///
  /// Animation: scroll ลง → slide ขึ้นซ่อน, scroll ขึ้น → slide ลงโผล่
  Widget _buildAppBar(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: IgnorePointer(
        ignoring: !_isAppBarVisible,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          offset: _isAppBarVisible ? Offset.zero : const Offset(0, -1),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isAppBarVisible ? 1.0 : 0.0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDims.size_16.w,
                  vertical: AppDims.size_8.h,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BackButton(color: AppColors.darkBrown),
                    Row(
                      children: [
                        CartCountBadge(
                          child: _RoundIconButton(
                            icon: Assets.icShop.icBagOutline,
                            onTap: () => BrownyShopCartPage.goToPage(context),
                          ),
                        ),
                        SizedBox(width: AppDims.size_8.w),
                        _RoundIconButton(
                          svg: Assets.svg.icHeadset,
                          onTap: () => ContactPage.goToPage(
                            context,
                            ContactProvider.helpAndProblemNoti,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ปุ่มกลม semi-transparent brown ใน AppBar overlay
class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({this.icon, this.svg, required this.onTap});

  final AssetGenImage? icon;
  final SvgGenImage? svg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.w,
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: AppColors.darkBrown.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: icon != null
            ? icon?.image(
                color: AppColors.white,
              )
            : svg!.svg(
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
      ),
    );
  }
}

/// Main product image — swipe ซ้าย-ขวาเพื่อเปลี่ยนรูป
/// sync กับ [_ThumbnailStrip] ผ่าน [BrownyShopProductDetailViewmodel.selectedThumbnailNotifier]
class _MainImage extends StatefulWidget {
  const _MainImage({required this.vm, required this.product});

  final BrownyShopProductDetailViewmodel vm;
  final ProductData product;

  @override
  State<_MainImage> createState() => _MainImageState();
}

class _MainImageState extends State<_MainImage> {
  late final PageController _pageController;
  late List<ProductImageThumb> _thumbs;

  @override
  void initState() {
    super.initState();
    _thumbs = widget.vm.buildThumbnails(widget.product);
    _pageController = PageController(initialPage: _initialIndex());
    widget.vm.selectedThumbnailNotifier.addListener(_syncFromNotifier);
  }

  int _initialIndex() {
    final selected = widget.vm.selectedThumbnailNotifier.value;
    final idx = _thumbs.indexOf(
      selected ?? const ProductImageThumb(imageUrl: ''),
    );
    return idx < 0 ? 0 : idx;
  }

  /// sync PageView → ตำแหน่งของ thumbnail ที่ถูกเลือกจากภายนอก (เช่น tap ที่ strip)
  void _syncFromNotifier() {
    if (!_pageController.hasClients) return;
    final selected = widget.vm.selectedThumbnailNotifier.value;
    if (selected == null) return;
    final idx = _thumbs.indexOf(selected);
    if (idx < 0) return;
    final current = _pageController.page?.round() ?? -1;
    if (current == idx) return;
    _pageController.animateToPage(
      idx,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  /// sync ทาง PageView → notifier (เมื่อ user swipe)
  void _onPageChanged(int index) {
    if (index < 0 || index >= _thumbs.length) return;
    final thumb = _thumbs[index];
    if (widget.vm.selectedThumbnailNotifier.value == thumb) return;
    widget.vm.onThumbnailSelected(thumb);
  }

  @override
  void dispose() {
    widget.vm.selectedThumbnailNotifier.removeListener(_syncFromNotifier);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_thumbs.isEmpty) {
      return SizedBox(height: 375.h);
    }
    return Container(
      width: double.infinity,
      height: 375.h,
      color: AppColors.bareBackground,
      padding: EdgeInsets.only(top: 22.h),
      child: PageView.builder(
        controller: _pageController,
        itemCount: _thumbs.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          return Center(
            child: CachedNetworkImage(
              height: 271.h,
              imageUrl: _thumbs[index].imageUrl,
              fit: BoxFit.contain,
              errorWidget: (_, _, _) => const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}

/// Thumbnail row — แสดง mainImageUrl + imageUrl ของ productSubs ทั้งหมด
///
/// Active check ใช้ subId เพื่อแยกรายการที่ share image url เดียวกัน
class _ThumbnailStrip extends StatelessWidget {
  const _ThumbnailStrip({required this.vm, required this.product});

  final BrownyShopProductDetailViewmodel vm;
  final ProductData product;

  @override
  Widget build(BuildContext context) {
    final thumbs = vm.buildThumbnails(product);
    if (thumbs.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(
        left: AppDims.size_16.w,
        top: AppDims.size_8.h,
      ),
      child: SizedBox(
        height: AppDims.size_50.h,
        child: ValueListenableBuilder<ProductImageThumb?>(
          valueListenable: vm.selectedThumbnailNotifier,
          builder: (context, selected, _) {
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: thumbs.length,
              separatorBuilder: (_, _) => SizedBox(width: AppDims.size_8.w),
              itemBuilder: (context, index) {
                final thumb = thumbs[index];
                final isActive = thumb == selected;
                return GestureDetector(
                  onTap: () => vm.onThumbnailSelected(thumb),
                  child: Container(
                    width: AppDims.size_50.w,
                    height: AppDims.size_50.w,
                    decoration: BoxDecoration(
                      color: AppColors.bareBackground,
                      borderRadius: BorderRadius.circular(4.r),
                      border: isActive
                          ? Border.all(color: AppColors.primary, width: 1.5)
                          : null,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      imageUrl: thumb.imageUrl,
                      fit: BoxFit.contain,
                      errorWidget: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// ราคา money + strike + -% / coin chip + strike
class _PriceSection extends StatelessWidget {
  const _PriceSection({required this.product});

  final ProductData product;

  @override
  Widget build(BuildContext context) {
    final sub = (product.productSubs?.isNotEmpty ?? false)
        ? product.productSubs!.first
        : null;
    if (sub == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (sub.moneyPrice != null)
              AppText(
                formatCurrency(
                  value: sub.moneyPrice,
                  leadingSign: '฿',
                  trailingSign: ' ${context.wording.baht}',
                ),
                style: context.textTheme.titleLarge?.copyWith(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ci,
                ),
              ),
            SizedBox(width: AppDims.size_8.w),
            if (sub.hasMoneyDiscount) ...[
              AppText(
                formatCurrency(value: sub.originalMoneyPrice, leadingSign: '฿'),
                style: context.textTheme.labelMedium?.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.error,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppColors.error,
                ),
              ),
              SizedBox(width: AppDims.size_4.w),
              AppText(
                '-${_discountPercent(sub.originalMoneyPrice!, sub.moneyPrice!)}%',
                style: context.textTheme.labelMedium?.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ],
        ),
        AppDims.vericalPadding_8,
        Row(
          children: [
            if (sub.coinPrice != null) _coinChip(context, sub),
            if (sub.coinPrice != null) SizedBox(width: AppDims.size_8.w),
            if (sub.originalCoinPrice != null &&
                sub.originalCoinPrice != sub.coinPrice)
              AppText(
                formatCurrency(value: sub.originalCoinPrice),
                style: context.textTheme.labelMedium?.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.error,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppColors.error,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _coinChip(BuildContext context, ProductSubData sub) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDims.size_8.w,
        vertical: AppDims.size_4.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.ci3,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.png.brownyCoin.image(width: 18.w, height: 18.w),
          SizedBox(width: AppDims.size_8.w),
          AppText(
            formatCurrency(
              value: sub.coinPrice,
              trailingSign: ' ${context.wording.coin}',
            ),
            style: context.textTheme.labelMedium?.copyWith(
              fontSize: 16.sp,
              color: AppColors.ci,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  int _discountPercent(num original, num sale) {
    if (original <= 0) return 0;
    return (((original - sale) / original) * 100).round();
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection({required this.product});

  final ProductData product;

  @override
  Widget build(BuildContext context) {
    return AppText(
      product.getNameDisplay(context.languageCode),
      style: context.textTheme.headlineLarge?.copyWith(
        fontSize: 26.sp,
        color: AppColors.darkBrown,
      ),
    );
  }
}

/// การ์ดสีขาวครอบ 1 section — section แรกมุมบนโค้ง 16 (Frame 2087328380)
class _Section extends StatelessWidget {
  const _Section({
    required this.child,
    this.topRounded = false,
    this.padding,
  });

  final Widget child;
  final bool topRounded;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(AppDims.size_16.w),
      clipBehavior: topRounded ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: topRounded
            ? BorderRadius.vertical(top: Radius.circular(16.r))
            : null,
      ),
      child: child,
    );
  }
}

/// [Section 2] สูตร — แสดง product_subs ที่มี (Frame 2087328382)
///
/// แตะการ์ดเพื่อเปลี่ยนรูปหลัก (sync กับ thumbnail strip ผ่าน
/// [BrownyShopProductDetailViewmodel.selectedThumbnailNotifier])
class _ProductSubsSection extends StatelessWidget {
  const _ProductSubsSection({required this.vm, required this.product});

  final BrownyShopProductDetailViewmodel vm;
  final ProductData product;

  @override
  Widget build(BuildContext context) {
    final subs = product.productSubs ?? const <ProductSubData>[];
    if (subs.isEmpty) return const SizedBox.shrink();
    final locale = context.languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          context.wording.productOption,
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: 16.sp,
            color: AppColors.darkBrown,
          ),
        ),
        AppDims.vericalPadding_8,
        SizedBox(
          height: 94.h,
          // ใช้ selectedSubIdNotifier (variant) แยกจากรูปหลัก — กดตัวเลือกแล้ว
          // รูปหลัก "ไม่เลื่อน" ตาม (decouple จาก selectedThumbnailNotifier)
          child: ValueListenableBuilder<int?>(
            valueListenable: vm.selectedSubIdNotifier,
            builder: (context, selectedSubId, _) {
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: subs.length,
                separatorBuilder: (_, _) => SizedBox(width: AppDims.size_8.w),
                itemBuilder: (context, index) {
                  final sub = subs[index];
                  return _ProductSubItem(
                    name: sub.getNameDisplay(locale),
                    imageUrl: sub.imageUrl,
                    isActive: selectedSubId == sub.id,
                    onTap: () => vm.onSubOptionSelected(sub.id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 1 การ์ดสูตร — รูป + ชื่อ + (เผื่อไว้) badge "ขายดี"
class _ProductSubItem extends StatelessWidget {
  const _ProductSubItem({
    required this.name,
    required this.imageUrl,
    required this.isActive,
    required this.onTap,
  });

  final String name;
  final String? imageUrl;
  final bool isActive;
  final VoidCallback onTap;

  /// badge "ขายดี" (Frame 2087326874) — ออกแบบเผื่อไว้ แต่ซ่อนเพราะ API ยังไม่มี
  static const bool _showBestSeller = false;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.only(
          top: 8.h,
          bottom: 8.h,
          left: 4.w,
          right: 4.w,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: 2,
          ),
        ),
        width: 66.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: AppColors.bareBackground,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: url.orEmpty,
                    fit: BoxFit.contain,
                    errorWidget: (_, _, _) => SizedBox(),
                  ),
                ),
                if (_showBestSeller)
                  Positioned(
                    top: -4.h,
                    right: -4.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDims.size_4.w,
                        vertical: AppDims.size_2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: AppText(
                        context.wording.bestSeller,
                        style: context.textTheme.labelSmall?.copyWith(
                          fontSize: 8.sp,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Spacer(),
            AppText(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textTheme.labelSmall?.copyWith(
                fontSize: 14.sp,
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// คูปอง Browny Shop — แตะเพื่อเลือกใน [CouponVoucherPage] (tab Browny Shop)
///
/// คูปองที่เลือกเก็บใน [BrownyShopProductDetailViewmodel.selectedCouponNotifier]
/// และจะถูก carry ไป auto-apply หน้า checkout เมื่อกด "ซื้อเลย"
class _CouponCard extends StatelessWidget {
  const _CouponCard();

  /// เปิดหน้าเลือกคูปอง (tab Browny Shop, flow brownyUsing) แล้วเก็บผลลัพธ์
  Future<void> _onTapCoupon(BuildContext context) async {
    final vm = context.read<BrownyShopProductDetailViewmodel>();
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
    final vm = context.read<BrownyShopProductDetailViewmodel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _onTapCoupon(context),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Assets.icShop.icCouponRoundedGreen.image(
                width: AppDims.size_20.w,
                height: AppDims.size_20.w,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: AppText(
                  // 'คูปอง / E-Voucher',
                  context.wording.couponAndEVoucher,
                  style: context.textTheme.labelLarge?.copyWith(
                    fontSize: 16.sp,
                    color: AppColors.darkBrown,
                  ),
                ),
              ),
              Assets.svg.icArrowForward.svg(
                width: AppDims.size_16.w,
                height: AppDims.size_16.w,
              ),
            ],
          ),
        ),
        AppDims.vericalPadding_8,
        ValueListenableBuilder(
          valueListenable: vm.selectedCouponNotifier,
          builder: (context, coupon, _) {
            if (coupon == null) {
              return _buildUnselected(context);
            }
            return _buildSelected(context, vm, coupon);
          },
        ),
      ],
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
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  /// เลือกคูปองแล้ว — แสดงการ์ด + กรอบเขียว/แดงตามเงื่อนไข + ข้อความ error
  Widget _buildSelected(
    BuildContext context,
    BrownyShopProductDetailViewmodel vm,
    CustomerCouponModel coupon,
  ) {
    final errorMessage = vm.validSelectedCouponMessage(context);
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

/// ข้อมูลการจัดส่ง — แตะเพื่อเลือกที่อยู่ ([CustomerShipToPage])
///
/// แสดงที่อยู่จัดส่งที่เลือก (ค่าเริ่มต้น = ที่อยู่หลัก) + ค่าจัดส่งโดยประมาณ
/// (shipping_total) จาก cart/summary ที่ re-fetch เมื่อเปลี่ยนที่อยู่/คูปอง
class _ShippingInfo extends StatelessWidget {
  const _ShippingInfo();

  Future<void> _onTap(BuildContext context) async {
    final vm = context.read<BrownyShopProductDetailViewmodel>();
    final selected = await CustomerShipToPage.goToPage(context);
    if (selected != null) vm.setShippingAddress(selected);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<BrownyShopProductDetailViewmodel>();
    return GestureDetector(
      onTap: () => _onTap(context),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppDims.size_20.w,
            height: AppDims.size_20.w,
            decoration: const BoxDecoration(
              color: AppColors.ci7,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Assets.icShop.icBox.image(width: 16.w, height: 16.w),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  '${context.wording.willReceiveWithin} 30 ${context.wording.dayUnit}',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: 16.sp,
                    color: AppColors.ci,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                // ที่อยู่จัดส่งที่เลือก (ค่าเริ่มต้น = ที่อยู่หลัก)
                ValueListenableBuilder(
                  valueListenable: vm.shippingAddressNotifier,
                  builder: (context, address, _) {
                    final place = address == null
                        ? context.wording.selectAddress
                        : (address.district ??
                              address.subdistrict ??
                              address.province ??
                              address.displayName);
                    return AppText(
                      '${context.wording.deliverToLabel} $place',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.gray600,
                      ),
                    );
                  },
                ),
                // ค่าจัดส่งโดยประมาณ — shipping_total จาก cart/summary
                ValueListenableBuilder(
                  valueListenable: vm.summaryNotifier,
                  builder: (context, result, _) {
                    return Row(
                      children: [
                        AppText(
                          '${context.wording.priceLabel} ',
                          style: context.textTheme.titleSmall?.copyWith(
                            fontSize: 16.sp,
                            color: AppColors.gray600,
                          ),
                        ),
                        AppText(
                          formatCurrency(
                            value: result.data?.shippingTotal ?? 0,
                            leadingSign: '฿',
                          ),
                          style: context.textTheme.titleSmall?.copyWith(
                            fontSize: 16.sp,
                            color: AppColors.ci,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Assets.svg.icArrowForward.svg(
            width: AppDims.size_16.w,
            height: AppDims.size_16.w,
          ),
        ],
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.product});

  final ProductData product;

  @override
  Widget build(BuildContext context) {
    final description = product.getDescriptionDisplay(context.languageCode);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          context.wording.productDetails,
          style: context.textTheme.bodyMedium?.copyWith(
            fontSize: 16.sp,
            color: AppColors.darkBrown,
          ),
        ),
        AppDims.vericalPadding_8,
        Html(
          data: description,
          style: {
            'body': Style(
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
              fontSize: FontSize(16.sp),
              color: AppColors.textBare,
              lineHeight: const LineHeight(1.6),
            ),
            'p': Style(
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
          },
        ),
      ],
    );
  }
}

/// แสดงรูปสินค้าใหญ่ — วน imageUrl ของ productSubs (rounded 24)
class _ImageGallery extends StatelessWidget {
  const _ImageGallery({required this.product});

  final ProductData product;

  @override
  Widget build(BuildContext context) {
    final subs = product.productSubs ?? <ProductSubData>[];
    final images = subs.map((s) => s.imageUrl).whereType<String>().toList();
    if (images.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (final url in images) ...[
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bareBackground,
                borderRadius: BorderRadius.circular(24.r),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: url,
                // contain — กันรูปแกลเลอรีด้านล่างโดนซูม/ครอป (ให้เหมือนรูปอื่นในหน้า)
                fit: BoxFit.contain,
                errorWidget: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
          AppDims.vericalPadding_16,
        ],
      ],
    );
  }
}

/// [Section 5] รายละเอียดเพิ่มเติม (Frame 2087327979)
///
/// แสดง product description ก่อน — ส่วน [_ImageGallery] collapse ไว้ แตะปุ่ม
/// (ไอคอน chevron) เพื่อขยาย (ยังไม่มี wording.showMore จึงใช้ไอคอนล้วน)
class _MoreInfoSection extends StatefulWidget {
  const _MoreInfoSection({required this.product});

  final ProductData product;

  @override
  State<_MoreInfoSection> createState() => _MoreInfoSectionState();
}

class _MoreInfoSectionState extends State<_MoreInfoSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final subs = widget.product.productSubs ?? <ProductSubData>[];
    final hasGallery = subs.any((s) => (s.imageUrl ?? '').isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // คำอธิบายสินค้า — แสดงเสมอ
        _DescriptionSection(product: widget.product),
        // แกลเลอรีรูป — collapse ไว้ก่อน แตะปุ่มเพื่อขยาย
        if (hasGallery) ...[
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: EdgeInsets.only(top: AppDims.size_16.h),
              child: _ImageGallery(product: widget.product),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppDims.size_8.h),
                child: Column(
                  children: [
                    AppText(
                      _expanded
                          ? context.wording.collapseMore
                          : context.wording.showMore,
                      style: context.textTheme.titleMedium!.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: AppDims.size_24.w,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// แถบล่าง: ถูกใจ + เพิ่มลงรถเข็น (mint) + ซื้อเลย (primary CI)
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.product});

  final ProductData product;

  /// เพิ่มสินค้าลงตะกร้าออนไลน์ผ่าน ViewModel แล้วแสดงผลลัพธ์
  ///
  /// - [goToCart] = true (ปุ่มซื้อเลย) → เข้าหน้าตะกร้าเมื่อสำเร็จ
  /// - [goToCart] = false (ปุ่มเพิ่มลงรถเข็น) → แสดง toast ยืนยัน
  Future<void> _onConfirm(
    BuildContext context, {
    required int subId,
    required int quantity,
    required bool goToCart,
  }) async {
    final vm = context.read<BrownyShopProductDetailViewmodel>();
    final result = await vm.addToCart(subId: subId, quantity: quantity);
    if (!context.mounted) return;

    if (!result.isSuccess) {
      AppOverlays.showBrownyDialog(context, message: context.wording.errorUi);
      return;
    }

    // เพิ่มลงตะกร้าสำเร็จ → อัปเดต badge จำนวนตะกร้า
    context.read<BrownyShopCartCountStore>().refresh(
      context.read<CustomerProvider>().current.id.orEmpty,
    );

    if (goToCart) {
      // ซื้อเลย → ผ่านหน้าตะกร้า แล้วเด้งเข้าหน้าสรุปเฉพาะสินค้านี้
      // carry คูปองที่เลือกไว้ไป auto-apply หน้า checkout
      BrownyShopCartPage.goToPage(
        context,
        buyNowSubId: subId,
        buyNowQuantity: quantity,
        buyNowCoupon: vm.selectedCouponNotifier.value,
      );
    } else {
      AppOverlays.showToast(
        context,
        message: context.wording.addedToCartSuccess,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.gray400)),
      ),
      padding: EdgeInsets.only(
        left: AppDims.size_16.w,
        right: AppDims.size_16.w,
        top: AppDims.size_8.h,
        bottom: AppDims.size_36.h,
      ),
      child: Row(
        children: [
          _FavoriteButton(
            // resolve ผ่าน store กลาง — sync กับหน้า list/หน้าอื่น
            isActive: context.watch<BrownyShopFavoriteStore>().resolve(
              product.id,
              product.favoriteStatus ?? false,
            ),
            onTap: () => context
                .read<BrownyShopProductDetailViewmodel>()
                .toggleFavorite(),
          ),
          SizedBox(width: AppDims.size_8.w),
          Expanded(
            child: _CtaButton(
              // เพิ่มลงรถเข็น
              label: context.wording.addToCart,
              background: AppColors.mintCartButton,
              textColor: AppColors.ci,
              iconPng: Assets.icShop.icBagOutline,
              onTap: () => showAddToCartBottomSheet(
                context,
                product: product,
                actionLabel: context.wording.addToCart,
                // sync ตัวเลือกที่เลือกใน _ProductSubsSection
                initialSubId: context
                    .read<BrownyShopProductDetailViewmodel>()
                    .selectedSubIdNotifier
                    .value,
                onConfirm: (subId, qty) => _onConfirm(
                  context,
                  subId: subId,
                  quantity: qty,
                  goToCart: false,
                ),
              ),
            ),
          ),
          SizedBox(width: AppDims.size_8.w),
          Expanded(
            child: _CtaButton(
              // ซื้อเลย
              label: context.wording.buyNow,
              background: AppColors.ci,
              textColor: AppColors.white,
              onTap: () => showAddToCartBottomSheet(
                context,
                product: product,
                actionLabel: context.wording.buyNow,
                // sync ตัวเลือกที่เลือกใน _ProductSubsSection
                initialSubId: context
                    .read<BrownyShopProductDetailViewmodel>()
                    .selectedSubIdNotifier
                    .value,
                onConfirm: (subId, qty) => _onConfirm(
                  context,
                  subId: subId,
                  quantity: qty,
                  goToCart: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isActive, this.onTap});
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // active = หัวใจสีแบรนด์ (ci), inactive = หัวใจเทา — ใช้ asset เดียว tint สี
    final color = isActive ? AppColors.ci : AppColors.gray500;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: AppDims.size_40.w,
        height: AppDims.size_40.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isActive
                ? Assets.icShop.icHeartActive.image(
                    width: 19.w,
                    height: 16.h,
                  )
                : Assets.icShop.icHeart.image(
                    width: 19.w,
                    height: 16.h,
                  ),
            SizedBox(height: 2.h),
            AppText(
              context.wording.favoriteLike,
              style: context.textTheme.labelSmall?.copyWith(
                fontSize: 14.sp,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  const _CtaButton({
    required this.label,
    required this.background,
    required this.textColor,
    this.iconPng,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color textColor;
  final AssetGenImage? iconPng;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppDims.size_40.h,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(4.r),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              label,
              style: context.textTheme.labelLarge?.copyWith(
                fontSize: 16.sp,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (iconPng != null) ...[
              SizedBox(width: AppDims.size_8.w),
              iconPng!.image(
                width: AppDims.size_16.w,
                height: AppDims.size_16.w,
                color: AppColors.ci,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
