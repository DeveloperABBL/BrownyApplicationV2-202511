import 'dart:async';

import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/products_response.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

/// callback ที่หน้าหลักรับ subId + จำนวน หลังจาก user กดยืนยัน
typedef AddToCartConfirmed = void Function(int subId, int quantity);

/// แสดง Bottom Sheet เลือกตัวเลือกสินค้า + จำนวน ก่อน "เพิ่มลงรถเข็น" หรือ "ซื้อเลย"
///
/// - ถ้าสินค้ามี productSub เพียง 1 ชิ้น (และไม่ out-of-stock) จะข้าม sheet
///   เรียก [onConfirm] ทันที (subId, 1)
/// - sheet สูงผันแปรตามเนื้อหา รองรับ soft-keyboard (resize ตาม viewInsets)
Future<void> showAddToCartBottomSheet(
  BuildContext context, {
  required ProductData product,
  required String actionLabel,
  required AddToCartConfirmed onConfirm,
}) async {
  final subs = product.productSubs ?? <ProductSubData>[];
  final selectable = subs.where(_isInStock).toList();

  // ไม่มีตัวเลือกที่หยิบได้ → ไม่เปิด sheet (อาจ snack แทน — ฝั่ง caller จัดการ)
  if (selectable.isEmpty) return;

  // มี sub เดียวที่หยิบได้ → ข้าม sheet
  // if (subs.length <= 1) {
  //   final sub = selectable.first;
  //   if (sub.id != null) onConfirm(sub.id!, 1);
  //   return;
  // }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _AddToCartBottomSheet(
        product: product,
        actionLabel: actionLabel,
        onConfirm: (subId, qty) {
          Navigator.of(ctx).pop();
          onConfirm(subId, qty);
        },
      ),
    ),
  );
}

bool _isInStock(ProductSubData sub) => sub.stock != '0';

class _AddToCartBottomSheet extends StatefulWidget {
  const _AddToCartBottomSheet({
    required this.product,
    required this.actionLabel,
    required this.onConfirm,
  });

  final ProductData product;
  final String actionLabel;
  final AddToCartConfirmed onConfirm;

  @override
  State<_AddToCartBottomSheet> createState() => _AddToCartBottomSheetState();
}

class _AddToCartBottomSheetState extends State<_AddToCartBottomSheet> {
  late ProductSubData _selectedSub;
  int _quantity = 1;
  late final TextEditingController _qtyController;

  /// key ผูกกับรูปสินค้าใน sheet เพื่อหา global position ตอนเริ่ม animation
  final GlobalKey _productImageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final subs = widget.product.productSubs ?? <ProductSubData>[];
    _selectedSub = subs.firstWhere(_isInStock, orElse: () => subs.first);
    _qtyController = TextEditingController(text: '$_quantity');
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  /// stock max — null = unlimited (ถ้า api ไม่ส่งมา)
  ///
  /// API ส่งเป็น String อาจมีทศนิยม (เช่น "30.00") → parse ผ่าน num ก่อน truncate
  int? get _stockMax {
    final raw = _selectedSub.stock;
    if (raw == null || raw.isEmpty) return null;
    return num.tryParse(raw)?.toInt();
  }

  void _onSubSelected(ProductSubData sub) {
    if (!_isInStock(sub)) return;
    if (sub.id == _selectedSub.id) return;
    setState(() {
      _selectedSub = sub;
      _quantity = 1;
      _qtyController.text = '1';
    });
  }

  void _setQuantity(int next) {
    final max = _stockMax;
    final clamped = next.clamp(1, max ?? 99999);
    if (clamped == _quantity) return;
    setState(() {
      _quantity = clamped;
      _qtyController.text = '$_quantity';
      _qtyController.selection = TextSelection.fromPosition(
        TextPosition(offset: _qtyController.text.length),
      );
    });
  }

  void _onQuantityInput(String text) {
    final parsed = int.tryParse(text);
    if (parsed == null) return;
    _setQuantity(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      padding: EdgeInsets.all(AppDims.size_16.w),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductRow(context),
            AppDims.vericalPadding_16,
            _buildOptionsSection(context),
            AppDims.vericalPadding_16,
            _buildCtaButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductRow(BuildContext context) {
    final imageUrl = _selectedSub.imageUrl ?? widget.product.mainImageUrl;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          key: _productImageKey,
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            color: AppColors.bareBackground,
            borderRadius: BorderRadius.circular(10.r),
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          padding: EdgeInsets.all(AppDims.size_8.w),
          child: imageUrl == null
              ? const SizedBox.shrink()
              : CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  errorWidget: (_, _, _) => const SizedBox.shrink(),
                ),
        ),
        SizedBox(width: AppDims.size_8.w),
        Expanded(child: _buildProductInfo(context)),
      ],
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          widget.product.getNameDisplay(context.languageCode),
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: 16.sp,
            color: AppColors.darkBrown,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: AppDims.size_4.h),
        _buildBadgesRow(context),
        SizedBox(height: AppDims.size_4.h),
        _buildCoinRow(context),
        SizedBox(height: 2.h),
        _buildMoneyAndQtyRow(context),
        SizedBox(height: AppDims.size_2.h),
        AppText(
          '${context.wording.remaining} ${_selectedSub.stockInt} ${widget.product.getUnitDisplay(context.languageCode)}',
          style: context.textTheme.titleSmall?.copyWith(
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }

  /// row badges (ลดราคา / ส่งฟรี) — เลื่อนแนวนอนได้เมื่อข้อมูลล้น
  Widget _buildBadgesRow(BuildContext context) {
    final isOnSale = _selectedSub.hasMoneyDiscount;
    final isFreeShipping = widget.product.isFreeShipping ?? false;
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
    if (_selectedSub.coinPrice == null) return const SizedBox.shrink();
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
                  value: _selectedSub.coinPrice,
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
        if (_selectedSub.hasCoinDiscount) ...[
          SizedBox(width: AppDims.size_4.w),
          AppText(
            formatCurrency(value: _selectedSub.originalCoinPrice),
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

  Widget _buildMoneyAndQtyRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              AppText(
                formatCurrency(
                  value: _selectedSub.moneyPrice,
                  leadingSign: '฿',
                ),
                style: context.textTheme.titleSmall?.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.ci,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_selectedSub.hasMoneyDiscount) ...[
                SizedBox(width: AppDims.size_4.w),
                AppText(
                  formatCurrency(
                    value: _selectedSub.originalMoneyPrice,
                    leadingSign: '฿',
                  ),
                  style: context.textTheme.labelSmall?.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.gray500,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColors.gray500,
                  ),
                ),
              ],
            ],
          ),
        ),
        _buildQuantityControls(context),
      ],
    );
  }

  Widget _buildQuantityControls(BuildContext context) {
    final max = _stockMax;
    final atMin = _quantity <= 1;
    final atMax = max != null && _quantity >= max;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _qtyButton(
          icon: Icons.remove,
          enabled: !atMin,
          onTap: () => _setQuantity(_quantity - 1),
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
          onTap: () => _setQuantity(_quantity + 1),
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

  Widget _buildOptionsSection(BuildContext context) {
    final subs = widget.product.productSubs ?? <ProductSubData>[];
    if (subs.length == 1) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          context.wording.productOption,
          style: context.textTheme.titleMedium?.copyWith(
            fontSize: 18.sp,
            color: AppColors.darkBrown,
          ),
        ),
        AppDims.vericalPadding_8,
        Wrap(
          spacing: AppDims.size_8.w,
          runSpacing: AppDims.size_8.h,
          children: [for (final sub in subs) _optionChip(context, sub)],
        ),
      ],
    );
  }

  Widget _optionChip(BuildContext context, ProductSubData sub) {
    final inStock = _isInStock(sub);
    final isSelected = sub.id == _selectedSub.id;

    final Color bg;
    final Color borderColor;
    final Color textColor;
    if (!inStock) {
      bg = AppColors.transparent;
      borderColor = AppColors.productStroke;
      textColor = AppColors.productStroke;
    } else if (isSelected) {
      bg = AppColors.ci;
      borderColor = AppColors.ci;
      textColor = AppColors.white;
    } else {
      bg = AppColors.transparent;
      borderColor = AppColors.gray400;
      textColor = AppColors.darkBrown;
    }

    return GestureDetector(
      onTap: inStock ? () => _onSubSelected(sub) : null,
      child: Container(
        height: 28.h,
        padding: EdgeInsets.symmetric(horizontal: AppDims.size_8.w),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Center(
          widthFactor: 1,
          child: AppText(
            sub.getNameDisplay(context.languageCode),
            style: context.textTheme.titleSmall?.copyWith(
              fontSize: 16.sp,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  /// แสดง animation รูปสินค้าลอยเข้ามุมขวาบน (ตำแหน่งโดยประมาณของไอคอนตะกร้า)
  /// ก่อนเรียก onConfirm — ให้ feedback ทาง UI ว่ามีการเพิ่มเข้าตะกร้าจริง
  Future<void> _runFlyToCartAnimation() async {
    final renderBox =
        _productImageKey.currentContext?.findRenderObject() as RenderBox?;
    final imageUrl = _selectedSub.imageUrl ?? widget.product.mainImageUrl;
    if (renderBox == null || imageUrl == null || imageUrl.isEmpty) return;

    final sourceOffset = renderBox.localToGlobal(Offset.zero);
    final sourceSize = renderBox.size;
    final screenSize = MediaQuery.of(context).size;
    final topInset = MediaQuery.of(context).padding.top;

    // ปลายทาง: มุมขวาบน (โดยประมาณตำแหน่งไอคอนตะกร้าใน AppBar)
    final targetSize = 24.w;
    final targetOffset = Offset(
      screenSize.width - targetSize - 24.w,
      topInset + 16.h,
    );

    final overlay = Overlay.of(context);
    final completer = Completer<void>();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _FlyToCartImage(
        imageUrl: imageUrl,
        sourceOffset: sourceOffset,
        sourceSize: sourceSize,
        targetOffset: targetOffset,
        targetSize: Size(targetSize, targetSize),
        onCompleted: () {
          entry.remove();
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );
    overlay.insert(entry);
    return completer.future;
  }

  Widget _buildCtaButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (_selectedSub.id == null) return;
        await _runFlyToCartAnimation();
        if (!mounted) return;
        widget.onConfirm(_selectedSub.id!, _quantity);
      },
      child: Container(
        width: double.infinity,
        height: AppDims.size_40.h,
        decoration: BoxDecoration(
          color: AppColors.ci,
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              widget.actionLabel,
              style: context.textTheme.labelLarge?.copyWith(
                fontSize: 16.sp,
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: AppDims.size_8.w),
            Assets.icShop.icBagOutline.image(
              width: AppDims.size_16.w,
              height: AppDims.size_16.w,
              color: AppColors.white,
            ),
          ],
        ),
      ),
    );
  }
}

/// Overlay widget — แสดงรูปสินค้าลอยจาก [sourceOffset] (ขนาด [sourceSize])
/// ไปยัง [targetOffset] (ขนาด [targetSize]) แล้วเรียก [onCompleted]
///
/// ใช้ Tween รวม Position + Size + Opacity ให้ดูเป็นการ "ดูดเข้าตะกร้า"
class _FlyToCartImage extends StatefulWidget {
  const _FlyToCartImage({
    required this.imageUrl,
    required this.sourceOffset,
    required this.sourceSize,
    required this.targetOffset,
    required this.targetSize,
    required this.onCompleted,
  });

  final String imageUrl;
  final Offset sourceOffset;
  final Size sourceSize;
  final Offset targetOffset;
  final Size targetSize;
  final VoidCallback onCompleted;

  @override
  State<_FlyToCartImage> createState() => _FlyToCartImageState();
}

class _FlyToCartImageState extends State<_FlyToCartImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _t = CurvedAnimation(parent: _controller, curve: Curves.easeInQuad);
    _controller.forward().whenComplete(widget.onCompleted);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        final t = _t.value;
        final left =
            widget.sourceOffset.dx +
            (widget.targetOffset.dx - widget.sourceOffset.dx) * t;
        final top =
            widget.sourceOffset.dy +
            (widget.targetOffset.dy - widget.sourceOffset.dy) * t;
        final width =
            widget.sourceSize.width +
            (widget.targetSize.width - widget.sourceSize.width) * t;
        final height =
            widget.sourceSize.height +
            (widget.targetSize.height - widget.sourceSize.height) * t;
        // fade ออกช่วงท้าย (~70%)
        final opacity = (1.0 - (t - 0.7).clamp(0.0, 0.3) / 0.3).clamp(0.0, 1.0);
        return Positioned(
          left: left,
          top: top,
          width: width,
          height: height,
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bareBackground,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                padding: EdgeInsets.all(AppDims.size_4.w),
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.contain,
                  errorWidget: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
