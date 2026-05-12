import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/products_response.dart';
import 'package:browny_applications_new/feature/browny_shop/repository/browny_shop_repo.dart';
import 'package:browny_applications_new/feature/browny_shop/viewmodel/browny_shop_product_detail_viewmodel.dart';
import 'package:browny_applications_new/feature/contacts/models/contact_model.dart';
import 'package:browny_applications_new/feature/contacts/screens/contact_page.dart';
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MainImage(vm: _vm, product: product),
          _ThumbnailStrip(vm: _vm, product: product),
          AppDims.vericalPadding_16,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDims.size_16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PriceSection(product: product),
                AppDims.vericalPadding_8,
                _TitleSection(product: product),
                AppDims.vericalPadding_16,
                const _Divider(),
                AppDims.vericalPadding_16,
                const _CouponCard(),
                AppDims.vericalPadding_8,
                const _ShippingInfo(),
                AppDims.vericalPadding_16,
                const _Divider(),
                AppDims.vericalPadding_16,
                _DescriptionSection(product: product),
                AppDims.vericalPadding_16,
                _ImageGallery(product: product),
                AppDims.vericalPadding_24,
              ],
            ),
          ),
        ],
      ),
    );
  }

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
                        _RoundIconButton(
                          icon: Assets.icShop.icBagOutline,
                          onTap: () => debugPrint('tap bag (TODO)'),
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
        width: 31.w,
        height: 31.w,
        decoration: BoxDecoration(
          color: AppColors.darkBrown.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: icon != null
            ? icon?.image(color: AppColors.white, width: AppDims.size_16.w)
            : svg!.svg(
                width: AppDims.size_16.w,
                height: AppDims.size_16.w,
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
              RichText(
                text: TextSpan(
                  style: context.textTheme.titleLarge?.copyWith(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ci,
                  ),
                  children: [
                    TextSpan(text: '฿${_fmt(sub.moneyPrice)}'),
                    TextSpan(
                      text: ' ${context.wording.baht}',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontSize: 22.sp,
                        color: AppColors.ci,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(width: AppDims.size_8.w),
            if (sub.hasMoneyDiscount) ...[
              AppText(
                '฿${_fmt(sub.originalMoneyPrice)}',
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
                _fmt(sub.originalCoinPrice),
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
          RichText(
            text: TextSpan(
              style: context.textTheme.labelMedium?.copyWith(
                fontSize: 16.sp,
                color: AppColors.ci,
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(text: _fmt(sub.coinPrice)),
                TextSpan(text: ' ${context.wording.coin}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(num? n) {
    if (n == null) return '';
    if (n == n.truncate()) return n.toInt().toString();
    return n.toStringAsFixed(2);
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
      style: context.textTheme.headlineSmall?.copyWith(
        fontSize: 26.sp,
        color: AppColors.darkBrown,
        height: 32 / 24,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColors.productStroke);
  }
}

/// คูปอง / E-Voucher placeholder (TODO: ดึงจาก API)
class _CouponCard extends StatelessWidget {
  const _CouponCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        AppDims.vericalPadding_8,
        _buildCouponPreview(context),
      ],
    );
  }

  Widget _buildCouponPreview(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.ci, width: 2),
        borderRadius: BorderRadius.circular(8.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(
            width: AppDims.size_85.w,
            height: AppDims.size_85.w,
            color: const Color(0x6681E287),
            alignment: Alignment.center,
            child: Assets.icShop.icTruckTick.svg(
              width: 32.w,
              height: 32.w,
              colorFilter: const ColorFilter.mode(
                AppColors.ci,
                BlendMode.srcIn,
              ),
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
                    'คูปองส่งฟรี ไม่มีขั้นต่ำ',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  AppText(
                    'เฉพาะสินค้าที่ร่วมรายการ',
                    style: context.textTheme.labelSmall?.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.ci,
                    ),
                  ),
                  SizedBox(height: AppDims.size_8.h),
                  AppText(
                    'คูปองหมดอายุ 12 พ.ย. 2025',
                    style: context.textTheme.labelSmall?.copyWith(
                      fontSize: 12.sp,
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

/// TODO Mockup ข้อมูล
/// ส่งให้ภายใน 30 วัน / address / ราคา ฿30
class _ShippingInfo extends StatelessWidget {
  const _ShippingInfo();

  @override
  Widget build(BuildContext context) {
    return Row(
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
                'จะได้รับภายใน 30 วัน',
                style: context.textTheme.titleSmall?.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.ci,
                  fontWeight: FontWeight.w400,
                ),
              ),
              AppText(
                'ส่งไปที่ ยานนาวา',
                style: context.textTheme.titleSmall?.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.gray600,
                ),
              ),
              RichText(
                text: TextSpan(
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: 16.sp,
                    color: AppColors.gray600,
                  ),
                  children: [
                    TextSpan(text: 'ราคา '),
                    TextSpan(
                      text: '฿30',
                      style: AppTextNumberStyles.bodySmall.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.ci,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Assets.svg.icArrowForward.svg(
          width: AppDims.size_16.w,
          height: AppDims.size_16.w,
        ),
      ],
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
          'รายละเอียดสินค้า',
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
                fit: BoxFit.cover,
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

/// แถบล่าง: ถูกใจ + เพิ่มลงรถเข็น (mint) + ซื้อเลย (primary CI)
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.product});

  final ProductData product;

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
          _FavoriteButton(isActive: product.favoriteStatus ?? false),
          SizedBox(width: AppDims.size_8.w),
          Expanded(
            child: _CtaButton(
              label: 'เพิ่มลงรถเข็น',
              background: AppColors.mintCartButton,
              textColor: AppColors.ci,
              iconPng: Assets.icShop.icBagOutline,
              onTap: () => debugPrint('tap add to cart (TODO)'),
            ),
          ),
          SizedBox(width: AppDims.size_8.w),
          Expanded(
            child: _CtaButton(
              label: 'ซื้อเลย',
              background: AppColors.ci,
              textColor: AppColors.white,
              onTap: () => debugPrint('tap buy now (TODO)'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => debugPrint('tap favorite (TODO)'),
      child: SizedBox(
        width: AppDims.size_40.w,
        height: AppDims.size_40.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.icShop.icHeart.image(
              width: 19.w,
              height: 16.h,
            ),
            SizedBox(height: 2.h),
            AppText(
              'ถูกใจ',
              style: context.textTheme.labelSmall?.copyWith(
                fontSize: 12.sp,
                color: AppColors.gray500,
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
