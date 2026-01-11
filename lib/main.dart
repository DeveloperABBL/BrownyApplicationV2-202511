import 'package:browny_applications_new/core/env/app_evnironment.dart';
import 'package:browny_applications_new/core/env/dev_environment.dart';
import 'package:browny_applications_new/res/strings/app_localizations.dart';
import 'package:browny_applications_new/res/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // if (PlatformUtils.isWeb) {
  // usePathUrlStrategy();
  // }
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AppEnvironment (สร้างครั้งเดียว)
  final appEnvironment = DevEnvironment();
  await appEnvironment.loadEnv();

  await initializeDateFormatting('th_TH', null);
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
      ],
      child: Consumer<AppEvnironment>(
        builder: (context, envNotifier, child) {
          final env = envNotifier;

          return ScreenUtilInit(
            // From Team design screen sizing
            designSize: const Size(375, 812),
            // minTextAdapt: true,
            splitScreenMode: true,
            builder: (_, _) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'Browny',

                // ============================================================
                // Localization (th, en, zh)
                // ============================================================
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: env.appPreferences.getLocalLanguage(),
                // Fallback เป็นภาษาไทยถ้าไม่เจอ locale ที่ต้องการ
                localeResolutionCallback: (locale, supportedLocales) {
                  // ตรวจสอบว่า locale ที่ระบุรองรับหรือไม่
                  if (locale != null) {
                    for (final supportedLocale in supportedLocales) {
                      if (supportedLocale.languageCode == locale.languageCode) {
                        return supportedLocale;
                      }
                    }
                  }
                  // ถ้าไม่เจอให้ใช้อังกฤษเป็นค่าเริ่มต้น
                  return const Locale('en');
                },

                // ============================================================
                // Theme
                // ============================================================
                theme: AppTheme.lightTheme,

                // ============================================================
                // Routing (go_router)
                // ============================================================
                routerConfig: env.appRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}
