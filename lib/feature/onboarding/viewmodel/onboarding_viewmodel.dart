import 'dart:async';

import 'package:browny_applications_new/core/data/remote/models/response/introductions_response.dart';
import 'package:browny_applications_new/res/icons/assets.gen.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/home/screens/home_page.dart';
import 'package:browny_applications_new/feature/onboarding/models/introduction_model.dart';
import 'package:browny_applications_new/feature/onboarding/repository/onboard_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class OnboardingViewmodel extends AppViewModel {
  OnboardingViewmodel({
    required super.context,
    required this.onboardDataSource,
  });

  /// Data source สำหรับเข้าถึงข้อมูลที่จะใช้ในหน้า [OnBoardingPage]
  final OnboardDataSource onboardDataSource;

  UiResult<List<IntroductionModel>> _content = UiResult.loading();
  UiResult<List<IntroductionModel>> get content => _content;
  int get contentSize => (_content.data?.length ?? 0) - 1;

  final PageController _pageController = PageController();
  // ValueListenableProvider li =
  bool isLastPage = false;
  PageController get pageController => _pageController;
  Future<void> nextPage() async {
    if (!isLastPage) {
      await _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      return;
    }

    goToHomePage();
  }

  /// DONG 2025-11-12
  ///
  /// สั่งไปหน้า [HomePage] และ flag isFirstLaunch ด้วย
  void goToHomePage() {
    // flage ว่าผ่านหน้า Onboarding มาแล้ว
    appPreferences.flagFirstLaunch();
    context.go(HomePage.pagePath);
  }

  void onPageChange(int value) {
    isLastPage = value == contentSize;
    notifyListeners();
  }

  @override
  void dispose() {
    // clear memory
    _content.data?.clear();
    _pageController.dispose();
    super.dispose();
  }

  /// DONG 2025-11-12
  ///
  /// fetch Content Introductions ครั้งแรกที่เข้าใช้งาน Application
  Future<void> fetchIntroductions() async {
    if (!_content.isLoading) {
      _content = UiResult.loading();
    }
    notifyListeners();

    List<IntroductionsResponse>? response;

    try {
      response = await onboardDataSource.fetchIntroductions();
    } on Exception catch (e) {
      _content = UiResult.error(
        error: Exception(
          '''
Unknown error occurred step : fetchIntroductions.
Exceptions : ${e.toString()}
''',
        ),
      );
      notifyListeners();
      return;
    }

    if (response == null || response.isEmpty) {
      _content = UiResult.empty();
      notifyListeners();
    }

    final icons = [
      Assets.svg.icOnboardFirst.svg(),
      Assets.svg.icOnboardSecond.svg(),
      Assets.svg.icOnboardThird.svg(),
    ];
    _content = UiResult.success(
      data: response
          .mapIndex(
            (index, e) => IntroductionModel(
              imageUrl: e.imageUrl,
              titleDisplay: e.title!.getTextByLocale(
                appPreferences.getLanguage(),
              ),
              suptitleDisplay: e.subtitle!.getTextByLocale(
                appPreferences.getLanguage(),
              ),
              icon: icons[index],
            ),
          )
          .toList(),
    );
    notifyListeners();
  }
}
