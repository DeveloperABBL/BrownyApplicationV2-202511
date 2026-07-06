import 'package:browny_applications_new/core/env/app_evnironment.dart';
import 'package:browny_applications_new/core/env/dev_environment.dart';
import 'package:browny_applications_new/core/utils/crashlytics_helper.dart';
import 'package:browny_applications_new/core/utils/notification_helper.dart';
import 'package:browny_applications_new/feature/browny_shop/providers/browny_shop_cart_count_store.dart';
import 'package:browny_applications_new/feature/browny_shop/providers/browny_shop_favorite_store.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:browny_applications_new/res/strings/app_localizations.dart';
import 'package:browny_applications_new/res/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // if (PlatformUtils.isWeb) {
  // usePathUrlStrategy();
  // }

  WidgetsFlutterBinding.ensureInitialized();

  // ==================== Firebase Setup ====================
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Crashlytics
  await CrashlyticsHelper.initialize(
    enableInDebugMode: false, // เปิดเป็น true ถ้าต้องการ test ใน debug mode
  );

  // Initialize AppEnvironment (สร้างครั้งเดียว)
  final appEnvironment = DevEnvironment();
  await appEnvironment.loadEnv();

  // Initialize Notifications
  await NotificationHelper.initialize(onTokenRefresh: (token) {});

  // Setup notification tap handler
  NotificationHelper.onNotificationTap((message) {
    debugPrint('📲 User tapped notification with data: ${message.data}');
    // TODO: Handle navigation based on message.data
    // Example:
    // final screen = message.data['screen'];
    // if (screen != null) {
    //   navigatorKey.currentState?.pushNamed(screen);
    // }
  });

  runApp(BrownyApp(appEnvironment: appEnvironment));
}

class BrownyApp extends StatelessWidget {
  const BrownyApp({
    super.key,
    required this.appEnvironment,
  });

  final AppEvnironment appEnvironment;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // top model
        ChangeNotifierProvider.value(value: appEnvironment.currentUser),
        ChangeNotifierProvider.value(value: appEnvironment),
        // store กลางสถานะสินค้าโปรด Browny Shop (sync ทุกหน้า)
        ChangeNotifierProvider(create: (_) => BrownyShopFavoriteStore()),
        // store กลางจำนวนรายการในตะกร้า Browny Shop (badge ไอคอนถุง)
        ChangeNotifierProvider(create: (_) => BrownyShopCartCountStore()),
      ],
      child: Consumer<AppEvnironment>(
        builder: (context, envNotifier, child) {
          final env = envNotifier;

          return LayoutBuilder(
            builder: (context, boxCons) {
              return ScreenUtilInit(
                // From Team design screen sizing
                designSize: const Size(375, 812),
                // minTextAdapt: true,
                enableScaleText: () => true,
                splitScreenMode: true,
                enableScaleWH: () => boxCons.maxWidth < 600,
                // fontSizeResolver: FontSizeResolvers.radius,
                builder: (_, _) {
                  return MaterialApp.router(
                    debugShowCheckedModeBanner: false,
                    title: 'Browny',

                    // ============================================================
                    // Localization (th, en, zh)
                    // ============================================================
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    locale: env.appPreferences.getLocalLanguage(),
                    // Fallback เป็นภาษาไทยถ้าไม่เจอ locale ที่ต้องการ
                    localeResolutionCallback: (locale, supportedLocales) {
                      // ตรวจสอบว่า locale ที่ระบุรองรับหรือไม่
                      if (locale != null) {
                        for (final supportedLocale in supportedLocales) {
                          if (supportedLocale.languageCode ==
                              locale.languageCode) {
                            return supportedLocale;
                          }
                        }
                      }
                      // ถ้าไม่เจอให้ใช้ไทยเป็นค่าเริ่มต้น
                      return const Locale('th');
                    },

                    // ============================================================
                    // Theme
                    // ============================================================
                    theme: AppTheme.lightTheme,

                    // ============================================================
                    // Routing (go_router)
                    // ============================================================
                    routerConfig: env.appRouter.router,

                    builder: (context, widget) => Container(
                      color: AppColors.black,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 560, // ความกว้างประมาณ iPhone 17 Pro Max
                            maxHeight: 956,
                          ),
                          child: widget,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
