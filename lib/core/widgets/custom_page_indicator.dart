import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CustomPageIndicator extends StatelessWidget {
  final PageController controller;
  final int count;
  final double dotWidth;
  final double dotHeight;
  final double activeDotWidth;

  const CustomPageIndicator({
    super.key,
    required this.controller,
    required this.count,
    this.dotWidth = 10.0,
    this.dotHeight = 10.0,
    this.activeDotWidth = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return SmoothPageIndicator(
      controller: controller,
      count: count,
      effect: ExpandingDotsEffect(
        dotWidth: dotWidth,
        dotHeight: dotHeight,
        activeDotColor: AppColors.primary,
        dotColor: AppColors.gray400,
        expansionFactor: activeDotWidth / dotWidth,
        spacing: 8.0,
        radius: dotHeight / 2,
      ),
    );
  }
}
