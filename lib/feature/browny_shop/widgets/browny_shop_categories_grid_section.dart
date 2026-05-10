import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/products_response.dart';
import 'package:browny_applications_new/feature/browny_shop/widgets/product_item_widget.dart';
import 'package:flutter/foundation.dart';

/// Shared section ของ Browny Shop: title "หมวดหมู่" + chips + grid 2-col
///
/// ใช้ทั้งใน home_page (Browny Shop section) และ BrownyShopPage
/// - gradient background + rounded top 24
/// - รับ listenable ของ products และ selected category
/// - callback เมื่อ user กดเลือก chip
class BrownyShopCategoriesGridSection extends StatelessWidget {
  const BrownyShopCategoriesGridSection({
    super.key,
    required this.productsListenable,
    required this.selectedCategoryListenable,
    required this.onCategorySelected,
    this.showShowMore = false,
    this.onShowMoreTap,
    this.onProductTap,
    this.onProductFavoriteTap,
    this.topBoxDecoration,
  });

  final ValueListenable<UiResult<List<ProductData>>> productsListenable;
  final ValueListenable<String> selectedCategoryListenable;
  final ValueChanged<String> onCategorySelected;

  /// แสดงปุ่ม "ดูเพิ่มเติม" ใต้ grid (ใช้ที่หน้า home; หน้า list page ปิดไว้)
  final bool showShowMore;
  final VoidCallback? onShowMoreTap;

  final ValueChanged<ProductData>? onProductTap;
  final ValueChanged<ProductData>? onProductFavoriteTap;

  final BoxDecoration? topBoxDecoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration:
          topBoxDecoration ??
          BoxDecoration(
            gradient: AppColors.brownyShopCategoryWrapperGradient,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
      padding: EdgeInsets.symmetric(horizontal: AppDims.size_16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppDims.vericalPadding_16,
          AppText(
            context.wording.categories,
            style: context.textTheme.labelLarge!,
          ),
          AppDims.vericalPadding_16,
          _buildChips(context),
          AppDims.vericalPadding_16,
          _buildGrid(context),
        ],
      ),
    );
  }

  Widget _buildChips(BuildContext context) {
    final chips = <_ShopChip>[
      _ShopChip(value: 'all', label: context.wording.all),
      _ShopChip(value: 'popular', label: context.wording.popular),
      _ShopChip(value: 'browny_sale', label: context.wording.brownySale),
      _ShopChip(value: 'browny_doll', label: context.wording.brownyDoll),
      _ShopChip(value: 'housework', label: context.wording.housework),
    ];

    return SizedBox(
      height: AppDims.size_24.h,
      child: ValueListenableBuilder<String>(
        valueListenable: selectedCategoryListenable,
        builder: (context, selected, _) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: chips.length,
            separatorBuilder: (_, _) => SizedBox(width: AppDims.size_8.w),
            itemBuilder: (context, index) {
              final chip = chips[index];
              final isActive = chip.value == selected;
              return GestureDetector(
                onTap: () => onCategorySelected(chip.value),
                child: Container(
                  height: AppDims.size_24.h,
                  padding: EdgeInsets.symmetric(horizontal: AppDims.size_8.w),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.transparent,
                    border: Border.all(
                      color: isActive ? AppColors.primary : AppColors.gray400,
                    ),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  alignment: Alignment.center,
                  child: AppText(
                    chip.label,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: isActive ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: productsListenable,
      builder: (context, result, _) {
        if (result.isLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppDims.size_24.h),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (result.hasError) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppDims.size_24.h),
            child: Center(child: AppText(context.wording.errorUi)),
          );
        }
        final products = result.data ?? <ProductData>[];
        if (products.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppDims.size_24.h),
            child: Center(child: AppText(context.wording.dataNotFound)),
          );
        }
        final locale = context.languageCode;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppDims.size_16.w,
                mainAxisSpacing: AppDims.size_16.h,
                childAspectRatio: 0.62,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                final firstSub = (p.productSubs?.isNotEmpty ?? false)
                    ? p.productSubs!.first
                    : null;
                return ProductItemWidget(
                  imageUrl: firstSub?.imageUrl ?? p.mainImageUrl,
                  name: p.getNameDisplay(locale),
                  coinPrice: firstSub?.coinPrice,
                  moneyPrice: firstSub?.moneyPrice,
                  isFreeShipping: p.isFreeShipping ?? false,
                  isFavorite: p.favoriteStatus ?? false,
                  onTap: () => onProductTap?.call(p),
                  onFavoriteTap: () => onProductFavoriteTap?.call(p),
                );
              },
            ),
            if (showShowMore) ...[
              AppDims.vericalPadding_16,
              _buildShowMoreButton(context),
            ],
          ],
        );
      },
    );
  }

  Widget _buildShowMoreButton(BuildContext context) {
    return GestureDetector(
      onTap: onShowMoreTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppDims.size_8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              context.wording.viewMore,
              style: context.textTheme.labelLarge!.copyWith(
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: AppDims.size_4.w),
            Icon(
              Icons.arrow_forward_ios,
              size: AppDims.size_12.w,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip data สำหรับ category filter
class _ShopChip {
  const _ShopChip({required this.value, required this.label});
  final String value;
  final String label;
}
