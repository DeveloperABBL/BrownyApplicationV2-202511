import 'dart:async';

import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/flash_sales_response.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';

/// Section "Flash Deals" — แสดง campaign แรกที่ active
///
/// Layout (Figma node 56:15191):
/// - กล่อง gradient ส้ม→เขียว rounded 8, padding 8
/// - Row บน: paw icon + "Browny Fla⚡h" + countdown (HH:MM:SS) + ดูทั้งหมด
/// - Row ล่าง: รายการสินค้า horizontal scroll (กล่อง 75x125 พร้อม badge ส่วนลด)
class FlashDealsSection extends StatelessWidget {
  const FlashDealsSection({
    super.key,
    required this.flashSalesListenable,
    this.onSeeAllTap,
    this.onProductTap,
  });

  final ValueListenable<UiResult<List<FlashSaleData>>> flashSalesListenable;
  final VoidCallback? onSeeAllTap;
  final ValueChanged<FlashSaleProductData>? onProductTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: flashSalesListenable,
      builder: (context, result, _) {
        if (result.isLoading || result.hasError || result.isEmpty) {
          return const SizedBox.shrink();
        }
        final sales = result.data ?? <FlashSaleData>[];
        final active = sales.firstWhere(
          (s) => s.isActive,
          orElse: () => sales.first,
        );
        final products = active.products ?? <FlashSaleProductData>[];
        if (products.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            AppDims.vericalPadding_24,
            Container(
              padding: EdgeInsets.all(AppDims.size_8.w),
              decoration: BoxDecoration(
                gradient: AppColors.flashSaleSectionGradient,
                borderRadius: BorderRadius.circular(AppDims.size_8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FlashDealsHeader(
                    endAt: active.endAt,
                    onSeeAllTap: onSeeAllTap,
                  ),
                  SizedBox(height: AppDims.size_16.h),
                  _FlashDealsProductRow(
                    products: products,
                    onProductTap: onProductTap,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Row บน: paw + logo + "Fla⚡h" text + countdown + ดูทั้งหมด
class _FlashDealsHeader extends StatelessWidget {
  const _FlashDealsHeader({required this.endAt, this.onSeeAllTap});

  final String? endAt;
  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildPawSquare(),
              SizedBox(width: AppDims.size_8.w),
              _buildLogoWithFlash(context),
              SizedBox(width: AppDims.size_8.w),
              _CountdownTimer(endAt: endAt),
            ],
          ),
        ),
        GestureDetector(
          onTap: onSeeAllTap,
          child: AppText(
            context.wording.seeAll,
            style: context.textTheme.labelSmall?.copyWith(
              color: AppColors.ci,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPawSquare() {
    return Container(
      width: 25.w,
      height: 25.w,
      decoration: BoxDecoration(
        gradient: AppColors.flashSalePawSquareGradient,
        borderRadius: BorderRadius.circular(4.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF5E221).withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Assets.icShop.bronwyShopPaw.image(width: 17.w, height: 15.w),
    );
  }

  Widget _buildLogoWithFlash(BuildContext context) {
    // logo "Browny" + "Fla⚡h" — แทรก flash icon ระหว่าง "Fla" และ "h"
    return Assets.icShop.bronwyShopFlashSales.image(height: 25.h);
  }
}

/// Countdown ตามเวลา endAt — อัพเดททุก 1 วินาที
/// แสดง HH:MM:SS ในกล่อง gradient 3 ช่อง
class _CountdownTimer extends StatefulWidget {
  const _CountdownTimer({required this.endAt});

  final String? endAt;

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateRemaining();
    });
  }

  void _updateRemaining() {
    final end = DateTime.tryParse(widget.endAt ?? '');
    if (end == null) {
      setState(() => _remaining = Duration.zero);
      return;
    }
    final diff = end.difference(DateTime.now());
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _pad2(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final hh = _pad2(_remaining.inHours);
    final mm = _pad2(_remaining.inMinutes.remainder(60));
    final ss = _pad2(_remaining.inSeconds.remainder(60));
    return Row(
      children: [
        _timeBox(context, hh),
        _separator(context),
        _timeBox(context, mm),
        _separator(context),
        _timeBox(context, ss),
      ],
    );
  }

  Widget _timeBox(BuildContext context, String text) {
    return Container(
      padding: EdgeInsets.all(AppDims.size_2.w),
      decoration: BoxDecoration(
        gradient: AppColors.flashSaleTimerGradient,
        borderRadius: BorderRadius.circular(2.r),
      ),
      child: AppText(
        text,
        style: context.textTheme.labelSmall?.copyWith(
          color: AppColors.darkBrown,
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Widget _separator(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDims.size_2.w),
      child: AppText(
        ':',
        style: context.textTheme.labelSmall?.copyWith(
          color: AppColors.darkBrown,
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}

/// Row สินค้า — horizontal scroll, แต่ละกล่อง 75w x 125h
class _FlashDealsProductRow extends StatelessWidget {
  const _FlashDealsProductRow({
    required this.products,
    this.onProductTap,
  });

  final List<FlashSaleProductData> products;
  final ValueChanged<FlashSaleProductData>? onProductTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 125.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: products.length,
        separatorBuilder: (_, _) => SizedBox(width: AppDims.size_8.w),
        itemBuilder: (context, index) {
          return _FlashDealCard(
            product: products[index],
            onTap: () => onProductTap?.call(products[index]),
          );
        },
      ),
    );
  }
}

class _FlashDealCard extends StatelessWidget {
  const _FlashDealCard({required this.product, this.onTap});

  final FlashSaleProductData product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final firstSub = (product.productSubs?.isNotEmpty ?? false)
        ? product.productSubs!.first
        : null;
    final imageUrl = product.mainImageUrl ?? firstSub?.imageUrl;
    final originalPrice = firstSub?.originalMoneyPrice;
    final salePrice = firstSub?.moneyPrice;
    final discountPercent = firstSub?.moneyDiscountPercent;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 75.w,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              spacing: AppDims.size_4.h,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildImage(imageUrl),
                SizedBox(height: AppDims.size_4.h),
                if (originalPrice != null)
                  _buildOriginalPrice(context, originalPrice),
                if (salePrice != null) _buildSalePrice(context, salePrice),
              ],
            ),
            if (discountPercent != null && discountPercent > 0)
              Positioned(
                top: -8,
                left: 41.w,
                child: _DiscountBadge(percent: discountPercent),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? imageUrl) {
    return Container(
      width: 75.w,
      height: 75.w,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? const SizedBox.shrink()
          : CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              errorWidget: (_, _, _) => const SizedBox.shrink(),
            ),
    );
  }

  Widget _buildOriginalPrice(BuildContext context, num price) {
    return AppText(
      formatCurrency(value: price, leadingSign: '฿'),
      style: context.textTheme.labelSmall?.copyWith(
        color: AppColors.error,
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.lineThrough,
        decorationColor: AppColors.error,
      ),
    );
  }

  Widget _buildSalePrice(BuildContext context, num price) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppDims.size_4.w),
      decoration: BoxDecoration(
        gradient: AppColors.flashSalePriceGradient,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: AppText(
        formatCurrency(value: price, leadingSign: '฿'),
        style: context.textTheme.labelSmall?.copyWith(
          color: AppColors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Badge "-XX%" สีแดง พร้อมไอคอน flash
class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percent});

  final num percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14.h,
      padding: EdgeInsets.symmetric(horizontal: AppDims.size_4.w),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icShop.icFlash.svg(
            width: 6.w,
            height: 8.h,
            colorFilter: const ColorFilter.mode(
              AppColors.white,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: AppDims.size_2.w),
          AppText(
            '-${percent.toStringAsFixed(0)}%',
            style: context.textTheme.labelSmall?.copyWith(
              color: AppColors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
