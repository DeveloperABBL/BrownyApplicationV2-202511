import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/feature/browny_shop/models/product_data_selected.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

/// หน้าตะกร้าสินค้า Browny Shop (POC)
///
/// Figma: node 56:20258
/// อ่าน state จาก [CustomerProvider.shopCartItems] — in-memory ยังไม่ sync API
class BrownyShopSelected extends StatelessWidget {
  const BrownyShopSelected({super.key});

  static final pagePath = '/browny_shop_selected';
  static final pageName = 'BrownyShopSelected';

  static Future<T?> goToPage<T>(BuildContext context) async {
    return await context.pushNamed(BrownyShopSelected.pageName);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerProvider>();
    final items = provider.shopCartItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          AppDims.size_56.h + MediaQuery.of(context).padding.top,
        ),
        child: _buildAppBar(context),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: items.isEmpty
            ? _buildEmpty(context)
            : ListView.separated(
                // padding: EdgeInsets.all(AppDims.size_16.w),
                itemCount: items.length,
                // separatorBuilder: (_, _) => Divider(),
                separatorBuilder: (_, _) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppDims.size_16.w),
                  child: Divider(),
                ),
                itemBuilder: (context, index) {
                  return _CartItemCard(
                    item: items[index],
                    onToggleSelected: () => provider.toggleShopCartItemSelected(
                      items[index].id ?? '',
                      items[index].selectedSubId,
                    ),
                    onQuantityChanged: (q) =>
                        provider.updateShopCartItemQuantity(
                          items[index].id ?? '',
                          items[index].selectedSubId,
                          q,
                        ),
                    onRemove: () => provider.removeShopCartItem(
                      items[index].id ?? '',
                      items[index].selectedSubId,
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: items.isEmpty
          ? null
          : _CheckoutBar(
              selectedCount: provider.shopCartSelectedCount,
              moneyTotal: provider.shopCartSelectedMoneyTotal,
              moneyDiscount: provider.shopCartSelectedMoneyDiscount,
              allSelected: provider.shopCartIsAllSelected,
              onToggleAll: () => provider.setShopCartAllSelected(
                !provider.shopCartIsAllSelected,
              ),
              onCheckout: () => debugPrint('tap checkout (TODO)'),
            ),
    );
  }

  /// AppBar — bg gradient image + back (white) + title "ตะกร้า"
  /// อิงสไตล์เดียวกับ [BrownyShopPage._buildAppBar] / `_buildTopRow`
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTopRow(context),
            AppDims.vericalPadding_8,
          ],
        ),
      ),
    );
  }

  /// Top Row: back (white) + title "ตะกร้า" กลาง + placeholder ขวา
  Widget _buildTopRow(BuildContext context) {
    return SizedBox(
      height: AppDims.size_39.h,
      child: Stack(
        alignment: AlignmentGeometry.center,
        children: [
          Row(
            spacing: AppDims.size_4.w,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppText(
                context.wording.cart,
                style: context.textTheme.titleMedium?.copyWith(
                  fontSize: 20.sp,
                  color: AppColors.white,
                ),
              ),
              Assets.icShop.icBagOutline2.image(width: AppDims.size_20.w),
            ],
          ),
          Align(
            alignment: AlignmentGeometry.centerLeft,
            child: BackButton(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          alignment: AlignmentGeometry.topCenter,
          image: Assets.png.bgPawnPattern.provider(),
          repeat: ImageRepeat.repeatY,
          isAntiAlias: true,
          opacity: 0.15,
        ),
      ),
      child: Center(
        child: Column(
          spacing: AppDims.size_16.h,
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.icShop.bronwyShopOrderEmpty.image(width: 200.w),
            AppDims.vericalPadding_16,
            SizedBox(
              width: 200.w,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                child: AppText(context.wording.goShoppingNow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatefulWidget {
  const _CartItemCard({
    required this.item,
    required this.onToggleSelected,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final ProductDataSelected item;
  final VoidCallback onToggleSelected;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  State<_CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<_CartItemCard> {
  late final TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: '${widget.item.quantity}');
  }

  @override
  void didUpdateWidget(covariant _CartItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // sync เมื่อ provider เปลี่ยน quantity จากที่อื่น (เช่น toggle select)
    if (widget.item.quantity != oldWidget.item.quantity &&
        _qtyController.text != '${widget.item.quantity}') {
      _qtyController.text = '${widget.item.quantity}';
      _qtyController.selection = TextSelection.fromPosition(
        TextPosition(offset: _qtyController.text.length),
      );
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  ProductDataSelected get item => widget.item;

  /// stock max — null = unlimited (เมื่อ stock ไม่ส่งมา)
  ///
  /// API ส่งเป็น String อาจมีทศนิยม (เช่น "30.00") → parse ผ่าน num ก่อน truncate
  int? get _stockMax {
    final raw = item.selectedSub?.stock;
    if (raw == null || raw.isEmpty) return null;
    return num.tryParse(raw)?.toInt();
  }

  void _setQuantity(int next) {
    final max = _stockMax;
    final clamped = next.clamp(1, max ?? 99999);
    // sync controller ทุกครั้ง — กันกรณี ProductDataSelected ถูก mutate
    // โดย provider (เป็น object เดียวกัน) ทำให้ didUpdateWidget จับไม่ได้
    if (_qtyController.text != '$clamped') {
      _qtyController.text = '$clamped';
      _qtyController.selection = TextSelection.fromPosition(
        TextPosition(offset: _qtyController.text.length),
      );
    }
    if (clamped == item.quantity) return;
    widget.onQuantityChanged(clamped);
  }

  void _onQuantityInput(String text) {
    if (text.isEmpty) return;
    final parsed = int.tryParse(text);
    if (parsed == null) return;
    _setQuantity(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFC),
        // borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.symmetric(
        vertical: AppDims.size_16.h,
        horizontal: AppDims.size_16.w,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: AppDims.size_16.h,
          bottom: AppDims.size_16.h,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Checkbox(checked: item.selected, onTap: widget.onToggleSelected),
            SizedBox(width: AppDims.size_8.w),
            _buildImage(),
            SizedBox(width: AppDims.size_8.w),
            Expanded(
              child: SizedBox(
                height: 100.w,
                child: _buildInfo(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final url = item.selectedSub?.imageUrl ?? item.mainImageUrl;
    return Container(
      width: 100.w,
      height: 100.w,
      decoration: BoxDecoration(
        color: AppColors.bareBackground,
        borderRadius: BorderRadius.circular(10.r),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      padding: EdgeInsets.all(AppDims.size_8.w),
      child: url == null
          ? const SizedBox.shrink()
          : CachedNetworkImage(
              imageUrl: item.selectedSub!.imageUrl.orEmpty,
              fit: BoxFit.contain,
              errorWidget: (_, _, _) => CachedNetworkImage(
                imageUrl: item.mainImageUrl!,
                fit: BoxFit.contain,
                errorWidget: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ชื่อกินพื้นที่ที่เหลือทั้งหมด (maxLines 2) — push widgets อื่นชิดขอบล่าง
        Expanded(
          child: AppText(
            item.getNameDisplay(context.languageCode),
            style: context.textTheme.titleMedium?.copyWith(
              fontSize: 16.sp,
              color: AppColors.darkBrown,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (item.selectedSub != null)
          Expanded(
            child: AppText(
              item.selectedSub!.getNameDisplay(context.languageCode),
              style: context.textTheme.titleMedium?.copyWith(
                fontSize: 12.sp,
                color: AppColors.gray600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        _buildBadgesRow(context),
        SizedBox(height: AppDims.size_4.h),
        _buildCoinRow(context),
        SizedBox(height: 2.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _buildPrice(context)),
            _buildQtyStepper(context),
          ],
        ),
      ],
    );
  }

  /// badges (ลดราคา / ส่งฟรี) — horizontal scroll
  Widget _buildBadgesRow(BuildContext context) {
    final isOnSale = item.selectedSub?.hasMoneyDiscount ?? false;
    final isFreeShipping = item.isFreeShipping ?? false;
    if (!isOnSale && !isFreeShipping) return const SizedBox.shrink();
    return SizedBox(
      height: 18.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (isOnSale) _saleBadge(context),
            if (isOnSale && isFreeShipping) SizedBox(width: AppDims.size_4.w),
            if (isFreeShipping) _freeShippingBadge(context),
          ],
        ),
      ),
    );
  }

  Widget _saleBadge(BuildContext context) {
    return Container(
      height: 18.h,
      padding: EdgeInsets.symmetric(horizontal: AppDims.size_4.w),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icShop.icFlash.svg(
            width: 8.w,
            height: 8.h,
            colorFilter: const ColorFilter.mode(
              AppColors.white,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: AppDims.size_4.w),
          AppText(
            context.wording.onSale,
            style: context.textTheme.labelSmall?.copyWith(
              fontSize: 12.sp,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _freeShippingBadge(BuildContext context) {
    return Container(
      height: 18.h,
      padding: EdgeInsets.symmetric(horizontal: AppDims.size_4.w),
      decoration: BoxDecoration(
        gradient: AppColors.claimCoinButtonGradient,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icShop.icBox.image(width: 12.w, height: 12.w),
          SizedBox(width: AppDims.size_2.w),
          AppText(
            context.wording.freeShipping,
            style: context.textTheme.labelSmall?.copyWith(
              fontSize: 12.sp,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinRow(BuildContext context) {
    final sub = item.selectedSub;
    if (sub == null || sub.coinPrice == null) return const SizedBox.shrink();
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDims.size_4.w,
            vertical: 2.h,
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
                  value: sub.coinPrice,
                  trailingSign: ' ${context.wording.coin}',
                ),
                style: context.textTheme.labelSmall?.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (sub.hasCoinDiscount) ...[
          SizedBox(width: AppDims.size_4.w),
          AppText(
            formatCurrency(value: sub.originalCoinPrice),
            style: context.textTheme.labelSmall?.copyWith(
              fontSize: 12.sp,
              color: AppColors.gray500,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.gray500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPrice(BuildContext context) {
    final sub = item.selectedSub;
    if (sub == null) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          formatCurrency(value: sub.moneyPrice, leadingSign: '฿'),
          style: context.textTheme.titleSmall?.copyWith(
            fontSize: 16.sp,
            color: AppColors.ci,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (sub.hasMoneyDiscount) ...[
          SizedBox(width: AppDims.size_4.w),
          AppText(
            formatCurrency(value: sub.originalMoneyPrice, leadingSign: '฿'),
            style: context.textTheme.labelSmall?.copyWith(
              fontSize: 12.sp,
              color: AppColors.gray500,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.gray500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQtyStepper(BuildContext context) {
    final max = _stockMax;
    final atMin = item.quantity <= 1;
    final atMax = max != null && item.quantity >= max;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _qtyButton(
          icon: Icons.remove,
          enabled: !atMin,
          onTap: () => _setQuantity(item.quantity - 1),
        ),
        SizedBox(width: AppDims.size_8.w),
        SizedBox(
          width: 32.w,
          child: TextField(
            controller: _qtyController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: context.textTheme.titleSmall?.copyWith(
              fontSize: 18.sp,
              color: AppColors.black.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            textInputAction: TextInputAction.done,
            onChanged: _onQuantityInput,
          ),
        ),
        SizedBox(width: AppDims.size_8.w),
        _qtyButton(
          icon: Icons.add,
          enabled: !atMax,
          onTap: () => _setQuantity(item.quantity + 1),
        ),
      ],
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 18.w,
        height: 18.w,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.productStroke,
          borderRadius: BorderRadius.circular(2.r),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 12.w, color: AppColors.white),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.checked, required this.onTap});

  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 14.w,
        height: 14.w,
        decoration: BoxDecoration(
          color: checked ? AppColors.ci : AppColors.transparent,
          border: Border.all(color: AppColors.ci),
          borderRadius: BorderRadius.circular(2.r),
        ),
        alignment: Alignment.center,
        child: checked
            ? Icon(Icons.check, size: 10.w, color: AppColors.white)
            : null,
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.selectedCount,
    required this.moneyTotal,
    required this.moneyDiscount,
    required this.allSelected,
    required this.onToggleAll,
    required this.onCheckout,
  });

  final int selectedCount;
  final num moneyTotal;
  final num moneyDiscount;
  final bool allSelected;
  final VoidCallback onToggleAll;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: const [
          BoxShadow(color: Color(0x29000000), blurRadius: 4),
        ],
      ),
      padding: EdgeInsets.only(
        left: AppDims.size_16.w,
        right: AppDims.size_16.w,
        top: 6.h,
        bottom: AppDims.size_48.h,
      ),
      child: Row(
        children: [
          // Left: เลือกทั้งหมด
          GestureDetector(
            onTap: onToggleAll,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Checkbox(checked: allSelected, onTap: onToggleAll),
                SizedBox(width: AppDims.size_8.w),
                AppText(
                  context.wording.all,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: 16.sp,
                    color: AppColors.darkBrown,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    '${context.wording.total} : ',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 16.sp,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  AppText(
                    formatCurrency(value: moneyTotal, leadingSign: '฿'),
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 16.sp,
                      color: AppColors.ci,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    '${context.wording.discount} : ',
                    style: context.textTheme.labelSmall?.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  AppText(
                    formatCurrency(value: moneyDiscount, leadingSign: '฿'),
                    style: context.textTheme.labelSmall?.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(width: AppDims.size_14.w),
          GestureDetector(
            onTap: selectedCount > 0 ? onCheckout : null,
            child: Container(
              width: 101.w,
              height: AppDims.size_40.h,
              decoration: BoxDecoration(
                color: selectedCount > 0
                    ? AppColors.ci
                    : AppColors.ctaPrimaryDisable,
                borderRadius: BorderRadius.circular(8.r),
              ),
              alignment: Alignment.center,
              child: AppText(
                '${context.wording.makePayment} ($selectedCount)',
                style: context.textTheme.labelLarge?.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
