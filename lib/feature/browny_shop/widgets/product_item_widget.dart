import 'package:browny_applications_new/core/const/app_constants.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/widgets/app_text.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:browny_applications_new/res/icons/assets.gen.dart';
import 'package:browny_applications_new/res/strings/app_strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Card สินค้า (Browny Shop) — map ตาม design `design/product_item.css`
///
/// Layout (top → bottom):
/// 1. Image (147:119) + favorite circle มุมขวาบน
/// 2. Badges row: [ลดราคา] [ส่งฟรี] [Browny Coin]
/// 3. Title (Mitr 12sp brown #593817, 2 lines)
/// 4. Coin pill (current) + strikethrough original coin price ด้านล่าง
/// 5. Money row: ราคาบาทปัจจุบัน | ราคาเดิม strike | -%
class ProductItemWidget extends StatelessWidget {
  const ProductItemWidget({
    super.key,
    this.imageUrl,
    required this.name,
    this.coinPrice,
    this.originalCoinPrice,
    this.moneyPrice,
    this.originalMoneyPrice,
    this.discountPercent,
    this.isFreeShipping = false,
    this.isOnSale = false,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
  });

  /// รูปสินค้าหลัก
  final String? imageUrl;

  /// ชื่อสินค้า (สำเร็จแล้วตาม locale)
  final String name;

  /// ราคา coin ปัจจุบัน — แสดงใน pill สีเขียวอ่อน (ci7)
  final String? coinPrice;

  /// ราคา coin เดิม (strikethrough) — null = ไม่แสดง
  final String? originalCoinPrice;

  /// ราคาเงิน (บาท) ปัจจุบัน — สีเขียว 14sp
  final String? moneyPrice;

  /// ราคาเดิมก่อนลด strikethrough — null = ไม่แสดง
  final String? originalMoneyPrice;

  /// เปอร์เซ็นต์ส่วนลด (เช่น 20 → "-20%") — null = ไม่แสดง
  final int? discountPercent;

  /// แสดง badge "ส่งฟรี"
  final bool isFreeShipping;

  /// แสดง badge "ลดราคา"
  final bool isOnSale;

  /// สถานะ favorite
  final bool isFavorite;

  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  /// แสดง badge "Browny Coin" เมื่อมี coinPrice (สินค้าซื้อด้วย coin ได้)
  bool get _showCoinBadge => coinPrice != null && coinPrice!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(width: 1, color: AppColors.productStroke),
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.all(AppDims.size_8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            AppDims.vericalPadding_8,
            _buildBadgesRow(context),
            AppDims.vericalPadding_8,
            Expanded(child: _buildTitle(context)),
            AppDims.vericalPadding_8,
            _buildCoinSection(context),
            AppDims.vericalPadding_4,
            _buildMoneyRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 147 / 119,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Stack(
          children: [
            Positioned.fill(
              child: imageUrl == null || imageUrl!.isEmpty
                  ? Container(color: AppColors.ci3)
                  : CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.contain,
                      placeholder: (_, _) => Container(color: AppColors.ci3),
                      errorWidget: (_, _, _) => Container(color: AppColors.ci3),
                    ),
            ),
            Positioned(
              top: 5.h,
              right: 5.w,
              child: GestureDetector(
                onTap: onFavoriteTap,
                child:
                    (isFavorite
                            ? Assets.icShop.icFavActive
                            : Assets.icShop.icFavInactive)
                        .image(width: 21.w, height: 21.w, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesRow(BuildContext context) {
    final children = <Widget>[];

    if (isOnSale) {
      children.add(_saleBadge(context));
    }
    if (isFreeShipping) {
      children.add(
        _gradientBadge(
          context: context,
          text: context.wording.freeShipping,
          leadingIcon: Assets.icShop.icBox.image(
            width: 12.w,
            height: 12.w,
            fit: BoxFit.contain,
          ),
        ),
      );
    }
    if (_showCoinBadge) {
      children.add(
        _gradientBadge(
          context: context,
          text: 'Browny Coin',
          leadingIcon: Assets.png.brownyCoin.image(width: 12.w, height: 12.w),
        ),
      );
    }

    if (children.isEmpty) {
      return SizedBox(height: 18.h);
    }
    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) spaced.add(SizedBox(width: AppDims.size_4.w));
      spaced.add(children[i]);
    }
    // Horizontal scroll — ทุก Item scale เท่ากัน badge ที่เกินจะเลื่อนได้
    return SizedBox(
      height: 18.h,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: spaced,
        ),
      ),
    );
  }

  Widget _saleBadge(BuildContext context) {
    return Container(
      // height: 18.h,
      padding: EdgeInsets.symmetric(
        // vertical: AppDims.size_3.h,
        horizontal: AppDims.size_4.w,
      ),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(4.r),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icShop.icDiscount.image(width: AppDims.size_10.w),
          SizedBox(width: AppDims.size_2.w),
          AppText(
            context.wording.onSale,
            style: context.textTheme.labelSmall?.copyWith(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientBadge({
    required BuildContext context,
    required String text,
    required Widget leadingIcon,
  }) {
    return Container(
      height: 18.h,
      padding: EdgeInsets.symmetric(horizontal: AppDims.size_4.w),
      decoration: BoxDecoration(
        gradient: AppColors.claimCoinButtonGradient,
        borderRadius: BorderRadius.circular(4.r),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leadingIcon,
          SizedBox(width: AppDims.size_2.w),
          AppText(
            text,
            style: context.textTheme.labelSmall?.copyWith(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return AppText(
      name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: context.textTheme.labelSmall?.copyWith(
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildCoinSection(BuildContext context) {
    if (!_showCoinBadge) return const SizedBox.shrink();
    // Figma: gap 4, padding 5/5, border-radius 4 — coin pill (ซ้าย) + strike (ขวา)
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // coin pill (current)
        Container(
          padding: EdgeInsets.symmetric(
            vertical: AppDims.size_4.h,
            horizontal: AppDims.size_5.w,
          ),
          decoration: BoxDecoration(
            color: AppColors.ci7,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.png.brownyCoin.image(width: 12.w, height: 12.w),
              SizedBox(width: AppDims.size_4.w),
              AppText(
                formatCurrency(
                  string: coinPrice,
                  trailingSign: ' ${context.wording.coin}',
                ),
                style: context.textTheme.labelSmall?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // original coin price (strikethrough) — แสดงข้างๆ ด้านขวาของ pill
        if (originalCoinPrice != null && originalCoinPrice!.isNotEmpty) ...[
          SizedBox(width: AppDims.size_4.w),
          Expanded(
            child: AppText(
              formatCurrency(string: originalCoinPrice),
              style: context.textTheme.labelSmall?.copyWith(
                color: AppColors.gray500,
                fontSize: 10.sp,
                decoration: TextDecoration.lineThrough,
                decorationColor: AppColors.gray500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMoneyRow(BuildContext context) {
    if (moneyPrice == null || moneyPrice!.isEmpty) {
      return const SizedBox.shrink();
    }
    final items = [
      AppText(
        formatCurrency(
          string: moneyPrice,
          trailingSign: ' ${context.wording.baht}',
        ),
        style: context.textTheme.labelMedium?.copyWith(
          color: AppColors.primary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      if (originalMoneyPrice != null && originalMoneyPrice!.isNotEmpty)
        AppText(
          formatCurrency(string: originalMoneyPrice, leadingSign: '฿'),
          style: context.textTheme.labelSmall?.copyWith(
            color: AppColors.gray500,
            fontSize: 10.sp,
            decoration: TextDecoration.lineThrough,
            decorationColor: AppColors.gray500,
          ),
        ),
      if (discountPercent != null && discountPercent! > 0)
        AppText(
          '-$discountPercent%',
          style: context.textTheme.labelSmall?.copyWith(
            color: AppColors.gray500,
            fontSize: 10.sp,
          ),
        ),
    ];
    final spaced = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) spaced.add(SizedBox(width: AppDims.size_4.w));
      spaced.add(items[i]);
    }
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: spaced,
      ),
    );
  }
}
