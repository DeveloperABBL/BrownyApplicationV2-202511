import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/utils/share_helper.dart';
import 'package:browny_applications_new/feature/invit_friend/models/referral_reward_model.dart';
import 'package:browny_applications_new/feature/invit_friend/repository/invit_friend_repo.dart';
import 'package:browny_applications_new/feature/invit_friend/viewmodel/invit_friend_viewmodel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

class InvitFriendPage extends StatelessWidget {
  const InvitFriendPage({super.key});

  static final pagePath = '/invit_frien';
  static final pageName = 'InvitFriendPage';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InvitFriendViewModel(
        context: context,
        repo: InvitFriendRepo(),
      ),
      child: _InvitFriendWidget(),
    );
  }
}

class _InvitFriendWidget extends StatefulWidget {
  const _InvitFriendWidget();

  @override
  State<_InvitFriendWidget> createState() => __InvitFriendWidgetState();
}

class __InvitFriendWidgetState extends State<_InvitFriendWidget> {
  late InvitFriendViewModel _viewModel;
  @override
  void initState() {
    super.initState();
    _viewModel = context.read();
    _viewModel.attachContext(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      AppOverlays.showLoading(context);
      await _viewModel.fetchReferralRewardData();
      AppOverlays.hideLoading();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: ListView(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppBar(
              backgroundColor: AppColors.transparent,
              leading: BackButton(),
              title: AppText(
                'ชวนเพื่อนมาซักกับ Browny',
                style: context.textTheme.titleLarge!.copyWith(
                  fontSize: AppDims.size_18.sp,
                  color: AppColors.white,
                ),
              ),
            ),
            // Icon Title
            SafeArea(
              bottom: false,
              child: Assets.png.cardInvitTitle.image(),
            ),

            // Card แสดงรหัสชวนเพื่อน,​ ปุ่มแชร์ลิงก์
            Consumer<CustomerProvider>(
              builder: (context, value, child) {
                return Container(
                  padding: const EdgeInsets.all(12.0),
                  margin: EdgeInsets.only(
                    left: AppDims.size_65,
                    right: AppDims.size_65,
                    bottom: AppDims.size_16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: _buildSharingContent(context, value),
                );
              },
            ),
            AppDims.horizonPadding_16,

            AppContainerRadius(
              padding: EdgeInsets.all(AppDims.size_24),
              width: double.infinity,
              child: ValueListenableBuilder(
                valueListenable: _viewModel.referralRewardNotifier,
                builder: (context, result, child) {
                  if (!result.isSuccess) {
                    return SizedBox(
                      height: 200,
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        context.wording.inviteFriendsForCoupons,
                        style: context.textTheme.titleMedium,
                      ),
                      AppDims.vericalPadding_12,

                      // Step ชวนเพื่อนสะสม
                      SizedBox(
                        height: 50.h,
                        child: ListView.separated(
                          itemCount: result.data!.referralRewardData.length,
                          scrollDirection: Axis.horizontal,
                          separatorBuilder: (context, index) =>
                              AppDims.horizonPadding_12,

                          itemBuilder: (context, index) {
                            final data = result.data!.referralRewardData[index];
                            SvgGenImage icReferral;
                            // สะสมชวนเพื่อนแล้ว
                            if (data.active) {
                              if (data.isReward) {
                                // Icon ที่เป็น Reward
                                icReferral =
                                    Assets.svg.icInvitStateCouponActive;
                              } else {
                                // Icon ธรรมดา
                                icReferral = Assets.svg.icInvitStatePawActive;
                              }
                            } else {
                              // ยังไม่เคยสะสม หรือ ยังสะสมไม่ถึง
                              if (data.isReward) {
                                // Icon ที่เป็น Reward
                                icReferral =
                                    Assets.svg.icInvitStateCouponInactive;
                              } else {
                                // Icon ธรรมดา
                                icReferral = Assets.svg.icInvitStatePawInactive;
                              }
                            }

                            return icReferral.svg();
                          },
                        ),
                      ),

                      AppDims.vericalPadding_16,

                      AppText(
                        context.wording.rewardsTitle,
                        style: context.textTheme.titleMedium,
                      ),
                      AppDims.vericalPadding_12,

                      Column(
                        children: _buildRewards(context, result.data!),
                      ),
                      AppDims.vericalPadding_16,

                      AppText(
                        context.wording.termsAndConditions,
                        style: context.textTheme.titleMedium,
                      ),
                      Html(
                        data: result.data!.termsDisplay,
                        style: {
                          "body": Style(
                            fontSize: FontSize(
                              12.sp,
                            ),
                            color: AppColors.gray600,
                            padding: HtmlPaddings.zero,
                            textAlign: TextAlign.start,
                            margin: Margins.all(0),
                            fontWeight: FontWeight.w300,
                          ),
                        },
                        onLinkTap: (url, attributes, element) async {
                          if (url != null) {
                            // เปิด URL ในเบราว์เซอร์
                            final success = await LaunchHelper.openUrl(url);
                            if (!success && context.mounted) {
                              // แสดง error ถ้าเปิดไม่สำเร็จ
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: AppText(
                                    context.wording.somethingWrong,
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      AppDims.vericalPadding_16,
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BrownyBottomNav(
        currentIndex: 0,
        onTap: BrownyBottomNav.onTapAppDefault,
      ),
    );
  }

  Row _buildSharingContent(BuildContext context, CustomerProvider value) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                context.wording.referralCode,
                style: context.textTheme.labelMedium,
              ),
              AppDims.vericalPadding_8,

              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async {
                        // Copy ข้อความเข้า Clipboard
                        await Clipboard.setData(
                          ClipboardData(
                            text: value.current.phone.orEmpty,
                          ),
                        ).then((_) {
                          // Show a SnackBar to confirm the action
                          if (mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'คัดลอกแล้ว',
                                ),
                              ),
                            );
                          }
                        });
                      },
                      icon: Assets.svg.icCopy.svg(
                        width: 17.w,
                        height: 17.h,
                      ),
                      iconAlignment: IconAlignment.end,
                      style: context.appTheme.textButtonTheme.style!.copyWith(
                        alignment: Alignment.centerLeft,
                        minimumSize: WidgetStatePropertyAll(
                          Size.zero,
                        ),
                        padding: WidgetStatePropertyAll(
                          EdgeInsets.zero,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      // เบอร์โทรศัพท์
                      label: AppText(
                        value.current.phone.orEmpty.ifEmpty(
                          '               ',
                        ),
                        style: context.textTheme.headlineSmall!.copyWith(
                          fontSize: AppDims.size_16.sp,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await ShareHelper.shareText(
                        _viewModel.generateTextShare(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDims.primaryRadius,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDims.size_8,
                        vertical: AppDims.size_4,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Assets.svg.icShare.svg(
                      width: 12.w,
                      height: 12.w,
                      colorFilter: ColorFilter.mode(
                        AppColors.background,
                        BlendMode.srcIn,
                      ),
                    ),
                    iconAlignment: IconAlignment.end,
                    label: AppText(
                      context.wording.shareLink,
                      style: context.textTheme.labelSmall!.copyWith(
                        fontSize: AppDims.size_10.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRewards(BuildContext context, ReferralRewardModel result) {
    if (result.rewardDisplay.isEmpty) {
      return [
        Center(
          child: Assets.png.brownyError3.image(
            width: 100.w,
            height: 100.h,
          ),
        ),
        AppText(
          context.wording.noRewardsFound,
          style: context.textTheme.labelMedium,
        ),
      ];
    }

    return [
      ...result.rewardDisplay.map(
        (rewardData) => Container(
          // Disable
          foregroundDecoration: rewardData.active
              ? null
              : BoxDecoration(
                  color: Colors.grey,
                  backgroundBlendMode: BlendMode.saturation,
                ),
          height: 85.h,
          margin: EdgeInsets.only(bottom: AppDims.size_12),
          decoration: BoxDecoration(
            border: BoxBorder.all(
              width: 1,
              color: AppColors.primary,
            ),
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 100,
                height: 85.h,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: BoxBorder.fromLTRB(
                    right: BorderSide(
                      width: 1,
                      color: AppColors.primary,
                    ),
                  ),
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8.r),
                    topLeft: Radius.circular(8.r),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                      rewardData.imageDisplay,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
                // child: Icon(Icons.discount_rounded),
                // child: Assets.png.brownyCreatePin.image(),
              ),

              Expanded(
                child: Container(
                  padding: EdgeInsets.all(AppDims.size_8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        rewardData.typeDisplay,
                        style: context.textTheme.titleSmall,
                      ),
                      AppText(
                        rewardData.descriptionDisplay,
                        style: context.textTheme.labelSmall!.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Spacer(),

                      RichText(
                        text: TextSpan(
                          text: rewardData.expireDisplay,
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: AppDims.size_10.sp,
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(text: ' '),
                            TextSpan(
                              text: 'เงื่อนไข',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                fontSize: AppDims.size_10.sp,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }
}
