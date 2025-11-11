import 'package:browny_applications_new/core/res/colors/app_colors.dart';
import 'package:browny_applications_new/core/res/dims/app_dims.dart';
import 'package:browny_applications_new/core/res/icons/assets.gen.dart';
import 'package:browny_applications_new/core/res/strings/app_strings.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/widgets/app_container_radius.dart';
import 'package:browny_applications_new/core/widgets/custom_page_indicator.dart';
import 'package:browny_applications_new/feature/home/screens/home_page.dart';
import 'package:browny_applications_new/feature/onboarding/models/introduction_model.dart';
import 'package:browny_applications_new/feature/onboarding/repository/onboard_repo.dart';
import 'package:browny_applications_new/feature/onboarding/viewmodel/onboarding_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

  static final pagePath = '/';
  static final pageName = 'onboarding';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OnboardingViewmodel(
        context: context,
        onboardDataSource: OnboardRepo(),
      ),
      child: OnboardingWdiget(),
    );
  }
}

class OnboardingWdiget extends StatefulWidget {
  const OnboardingWdiget({super.key});

  @override
  State<OnboardingWdiget> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWdiget> {
  OnboardingViewmodel get _viewmodel => context.read<OnboardingViewmodel>();

  @override
  void initState() {
    super.initState();
    _viewmodel.attachContext(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewmodel.fetchIntroductions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Stack(
            children: [
              // background
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),

              // onBackground Container สีขาว
              Align(
                alignment: Alignment.bottomCenter,
                child: AppContainerRadius(
                  height: boxConstraints.maxWidth,
                ),
              ),

              // PageView Content OnBoarding
              Selector<OnboardingViewmodel, UiResult<List<IntroductionModel>>>(
                selector: (context, provider) => provider.content,
                builder: (context, content, child) {
                  if (content.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (content.hasError) {
                    return Center(child: Text(context.wording.somethingWrong));
                  }

                  return PageView(
                    controller: _viewmodel.pageController,
                    onPageChanged: _viewmodel.onPageChange,
                    children: content.requireData
                        .map((e) => _OnboardingContent(data: e))
                        .toList(),
                  );
                },
              ),

              // Indicator PageView Content OnBoarding
              Selector<OnboardingViewmodel, UiResult<List<IntroductionModel>>>(
                selector: (context, provider) => provider.content,
                builder: (context, content, child) {
                  if (!content.isSuccess) {
                    return SizedBox();
                  }

                  return Positioned(
                    top: boxConstraints.maxWidth + 88.h,
                    child: SizedBox(
                      width: boxConstraints.maxWidth,
                      child: Center(
                        child: CustomPageIndicator(
                          controller: _viewmodel.pageController,
                          count: _viewmodel.contentSize,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Bottom Button skip, next
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDims.size_24.w,
                    vertical: AppDims.size_28.w,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Selector<OnboardingViewmodel, bool>(
                        selector: (_, provider) => provider.isLastPage,
                        builder: (_, isLastPage, _) {
                          return !isLastPage
                              // ถ้าไม่ใช่หน้าสุดท้าย จะแสดงปุ่ม ข้าม
                              ? GestureDetector(
                                  onTap: () => context.go(HomePage.pagePath),
                                  child: Text(
                                    context.wording.skip,
                                    style: context.textTheme.titleLarge!
                                        .copyWith(
                                          fontSize: 16.sp,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w400,
                                        ),
                                  ),
                                )
                              : SizedBox();
                        },
                      ),

                      // ปุ่ม next page
                      IconButton(
                        onPressed: _viewmodel.nextPage,
                        icon: Assets.svg.arrowRight.svg(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  const _OnboardingContent({
    required this.data,
  });

  final IntroductionModel data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.symmetric(
                  vertical: AppDims.size_48.h,
                  horizontal: AppDims.size_20.w,
                ),
                child: Image.network(
                  data.imageUrl,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),

            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDims.size_32.w,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: AlignmentGeometry.topLeft,
                      child: data.icon,
                    ),
                    AppDims.vericalPadding_8,
                    Html(
                      data: data.titleDisplay,
                      style: {
                        "body": Style(
                          fontSize: FontSize(
                            context.appTheme.textTheme.titleLarge!.fontSize!,
                          ),
                          padding: HtmlPaddings.zero,
                          textAlign: TextAlign.start,
                          margin: Margins.all(0),
                          fontWeight: FontWeight.w600,
                        ),
                      },
                    ),
                    AppDims.vericalPadding_8,
                    Html(
                      data: data.suptitleDisplay,
                      style: {
                        "body": Style(
                          fontSize: FontSize(
                            context.appTheme.textTheme.bodyMedium!.fontSize!,
                          ),
                          padding: HtmlPaddings.zero,
                          textAlign: TextAlign.start,
                          margin: Margins.all(0),
                          fontWeight: context
                              .appTheme
                              .textTheme
                              .bodyMedium!
                              .fontWeight!,
                        ),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
