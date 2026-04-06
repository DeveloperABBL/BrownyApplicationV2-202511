import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/customer_notification_response.dart';
import 'package:browny_applications_new/feature/home/repository/home_repo.dart';
import 'package:browny_applications_new/feature/home/viewmodel/app_notification_viewmodel.dart';

class AppNotificationsPage extends StatelessWidget {
  const AppNotificationsPage({super.key});

  static final pagePath = '/notifications_page';
  static final pageName = 'notifications_page';

  /// util function route to pageName
  static Future<T?> goToPage<T>(BuildContext context) async {
    return await context.pushNamed(AppNotificationsPage.pageName);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppNotificationViewmodel(
        context: context,
        repo: HomeRepo(),
      ),
      child: _AppNotificationContent(),
    );
  }
}

class _AppNotificationContent extends StatefulWidget {
  const _AppNotificationContent();

  @override
  State<_AppNotificationContent> createState() =>
      __AppNotificationContentState();
}

class __AppNotificationContentState extends State<_AppNotificationContent> {
  late AppNotificationViewmodel _viewmodel;

  @override
  void initState() {
    super.initState();
    _viewmodel = context.read<AppNotificationViewmodel>();

    // เรียก API fetch customer notifications
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewmodel.fetchCustomerNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText(
          context.wording.notifications,
          style: context.appBarTextThemeWhite.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        leading: BackButton(
          color: AppColors.darkBrown,
        ),
      ),
      body: ValueListenableBuilder<UiResult<CustomerNotificationResponse>>(
        valueListenable: _viewmodel.customerNotificationsNotifier,
        builder: (context, result, _) {
          // Loading state
          if (result.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (result.hasError) {
            return Center(
              child: AppText(
                context.wording.errorUi,
                style: context.textTheme.labelMedium,
              ),
            );
          }

          // Empty state
          if (result.isEmpty ||
              result.data?.data == null ||
              result.data!.data!.isEmpty) {
            return Center(
              child: AppText(
                // ไม่มีการแจ้งเตือน
                context.wording.noNotifications,
                style: context.textTheme.labelMedium,
              ),
            );
          }

          // Success state - แสดงรายการ notifications
          final notifications = result.data!.data!;
          return Column(
            children: [
              AppDims.vericalPadding_16,
              AppToggleWidget(
                data: [
                  // ทั้งหมด
                  AppToggleData(
                    lable: context.wording.all,
                    value: 0,
                  ),
                  // ซักอบ
                  AppToggleData(
                    lable: context.wording.services,
                    value: 1,
                  ),
                  // การสั่งซื้อ
                  AppToggleData(
                    lable: context.wording.orderPlacement,
                    value: 2,
                    enable: false,
                  ),
                ],
                onChange: (index) {},
              ),
              AppDims.vericalPadding_16,
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _viewmodel.fetchCustomerNotifications();
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      final locale = Localizations.localeOf(
                        context,
                      ).languageCode;

                      return _NotificationItem(
                        notification: notification,
                        locale: locale,
                      );
                    },
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

/// Widget สำหรับแสดง notification แต่ละรายการ
class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.notification,
    required this.locale,
  });

  final CustomerNotificationItem notification;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          if (notification.icon != null)
            Container(
              width: AppDims.size_75.w,
              height: AppDims.size_75.h,
              padding: EdgeInsets.symmetric(
                vertical: AppDims.size_5.h,
                horizontal: AppDims.size_12.w,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: AppColors.border,
                // image: DecorationImage(
                //   image: NetworkImage(
                //     'https://dev.abgroup.co.th/storage/galleries/s3nbAR7QLSPpZ9aSTWSyGV9nXQZy6JhsPgVvaJKL.png',
                //     // notification.icon!,
                //   ),
                // ),
              ),
              child: Image.network(
                notification.icon!,
                width: AppDims.size_50.w,

                errorBuilder: (_, _, _) => SizedBox(),
              ),
            ),
          AppDims.horizonPadding_8,
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                if (notification.title != null)
                  AppText(
                    notification.title!.getByLocaleCode(locale) ?? '',
                    style: context.textTheme.labelLarge?.copyWith(),
                    maxLines: 2,
                  ),

                // Spacing
                if (notification.title != null && notification.message != null)
                  SizedBox(height: 4.h),

                // Message
                if (notification.message != null)
                  AppText(
                    notification.message!.getByLocaleCode(locale) ?? '',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 3,
                  ),

                // Created date
                if (notification.createdAt != null) ...[
                  SizedBox(height: 8.h),
                  AppText(
                    notification.createAtDisplay(context.languageCode),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          AppDims.horizonPadding_16,

          Assets.svg.arrowDown.svg(
            width: AppDims.size_26.w,
          ),
        ],
      ),
    );
  }
}
