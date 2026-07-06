import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/feature/browny_shop/providers/browny_shop_cart_count_store.dart';

/// ครอบไอคอนถุงตะกร้า แล้ววาง badge จำนวนรายการมุมขวาบน
///
/// อ่านจำนวนจาก [BrownyShopCartCountStore] — ว่าง = ไม่แสดง, เกิน 99 = "99+"
class CartCountBadge extends StatelessWidget {
  const CartCountBadge({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<BrownyShopCartCountStore>(
      builder: (context, store, _) {
        final text = store.badgeText;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            if (text != null)
              Positioned(
                right: -AppDims.size_6.w,
                top: -AppDims.size_6.h,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDims.size_4.w,
                    vertical: 1.h,
                  ),
                  constraints: BoxConstraints(minWidth: AppDims.size_16.w),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(999.r),
                    border: Border.all(color: AppColors.white, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: AppText(
                    text,
                    textAlign: TextAlign.center,
                    style: context.textTheme.labelSmall?.copyWith(
                      fontSize: 10.sp,
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
