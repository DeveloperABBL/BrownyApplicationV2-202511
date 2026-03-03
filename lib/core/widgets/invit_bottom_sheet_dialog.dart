import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/feature/home/viewmodel/home_page_viewmodel.dart';
import 'package:browny_applications_new/feature/invit_friend/screen/invit_friend_page.dart';
import 'package:browny_applications_new/feature/map/screens/map_page.dart';
import 'package:browny_applications_new/feature/scaner/screen/scanner_page.dart';
import 'package:browny_applications_new/feature/transactions/screens/coupons_evoucher/coupon_voucher_page.dart';

class InvitBottomSheetDialog extends StatelessWidget {
  const InvitBottomSheetDialog({
    super.key,
    required this.viewmodel,
  });

  final HomePageViewmodel viewmodel;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: CircleAvatar(
                backgroundColor: AppColors.background.withValues(
                  alpha: 0.5,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AppContainerRadius(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDims.size_24.r),
                topRight: Radius.circular(AppDims.size_24.r),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    AppDims.vericalPadding_16,
                    Assets.png.cardInvitFriend.image(fit: BoxFit.fill),

                    // AppDims.vericalPadding_16,
                    Padding(
                      padding: EdgeInsets.all(AppDims.size_16),
                      child: Column(
                        children: [
                          AppText(
                            'เชิญเพื่อนมาใช้ Browny\nสะสมแต้มแลกคูปอง!',
                            style: context.textTheme.titleLarge!.copyWith(
                              fontSize: AppDims.size_24,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          AppDims.vericalPadding_10,

                          AppText(
                            'เพียงแค่ส่งลิงก์ให้เพื่อน หรือให้เพื่อนกรอกเบอร์โทรศัพท์ของคุณ! ก็สะสมแต้ม และนำไปแลกคูปองได้อีกเพียบ',
                            style: context.textTheme.bodyMedium!.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          AppDims.vericalPadding_16,

                          ElevatedButton(
                            onPressed: () {
                              context.pop();
                              context
                                  .pushNamed<Map<Type, HomePageState>>(
                                    InvitFriendPage.pageName,
                                  )
                                  .then((bypass) {
                                    if (context.mounted && bypass != null) {
                                      switch (bypass.values.first) {
                                        case HomePageState.home:
                                          break;
                                        case HomePageState.couponVoucher:
                                          // context.pushNamed(
                                          //   CouponVoucherPage.pageName,
                                          // );
                                          CouponVoucherPage.goToPage(
                                            context,
                                          );
                                          break;
                                        case HomePageState.scan:
                                          // ไปหน้า Scan
                                          ScannerPage.goToPage(
                                            context,
                                          );
                                          break;
                                        case HomePageState.branches:
                                          context.pushNamed(
                                            MapPage.pageName,
                                          );
                                          break;
                                        case HomePageState.brownyShop:
                                          break;
                                      }
                                    }
                                  });
                            },
                            child: AppText(
                              'เชิญเพื่อนเลย',
                            ),
                          ),
                          AppDims.vericalPadding_8,
                          ElevatedButton(
                            onPressed: () => context.pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.ci3,
                              foregroundColor: AppColors.primary,
                            ),
                            child: AppText(
                              context.wording.acknowledge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<dynamic> showInvitBottomSheet(
    BuildContext context,
    HomePageViewmodel viewmodel,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: AppColors.transparent,
      useRootNavigator: true,
      builder: (dialogContext) {
        return InvitBottomSheetDialog(
          viewmodel: viewmodel,
        );
      },
    );
  }
}
