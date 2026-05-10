import 'package:browny_applications_new/core/core_index.dart';

/// Placeholder ของ section "Flash Deals" — ยังไม่มี API
///
/// Layout ตาม Figma node 22:5165 / Frame 2087326929
/// - height 159, rounded 8
/// - แสดงเป็นกล่องเปล่า ๆ พร้อม label "Flash Deals" รอ design/asset
class FlashDealsSection extends StatelessWidget {
  const FlashDealsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 159.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.productStroke),
        borderRadius: BorderRadius.circular(AppDims.size_8.r),
      ),
      alignment: Alignment.center,
      child: AppText(
        context.wording.flashDeals,
        style: context.textTheme.labelLarge?.copyWith(
          color: AppColors.gray500,
        ),
      ),
    );
  }
}
