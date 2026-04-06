import 'package:browny_applications_new/core/env/app_evnironment.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/dims/app_dims.dart';
import 'package:browny_applications_new/res/icons/assets.gen.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// LocaleToggleWidget - Widget สำหรับเปลี่ยนภาษา
///
/// ประกอบด้วย 3 ภาษา:
/// - ไทย (th)
/// - English (en)
/// - 中文 (zh)
class LocaleToggleWidget extends StatelessWidget {
  const LocaleToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppEvnironment>(
      builder: (context, env, child) {
        final currentLocale = env.appPreferences.getLanguage();

        return Container(
          constraints: BoxConstraints(maxWidth: 250.w),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.border,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(AppDims.size_24.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageButton(
                context: context,
                env: env,
                localeCode: 'th',
                flagAsset: Assets.svg.icFlagTh,
                label: 'ไทย',
                isSelected: currentLocale == 'th',
              ),
              SizedBox(width: 8.w),
              _buildLanguageButton(
                context: context,
                env: env,
                localeCode: 'en',
                flagAsset: Assets.svg.icFlagEn,
                label: 'Eng',
                isSelected: currentLocale == 'en',
              ),
              SizedBox(width: 8.w),
              _buildLanguageButton(
                context: context,
                env: env,
                localeCode: 'zh',
                flagAsset: Assets.svg.icFlagZh,
                label: '中文',
                isSelected: currentLocale == 'zh',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageButton({
    required BuildContext context,
    required AppEvnironment env,
    required String localeCode,
    required SvgGenImage flagAsset,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        env.onLocaleChange(localeCode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: AppDims.size_12.w,
          vertical: AppDims.size_8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDims.size_20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            flagAsset.svg(
              width: AppDims.size_20.w,
              height: AppDims.size_20.h,
            ),
            SizedBox(width: AppDims.size_4.w),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
              style: context.textTheme.bodySmall!.copyWith(
                fontSize: AppDims.size_12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
