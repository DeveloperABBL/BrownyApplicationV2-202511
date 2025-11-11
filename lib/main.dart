import 'package:browny_applications_new/core/data/cache/app_local_storage.dart';
import 'package:browny_applications_new/core/data/remote/app_client.dart';
import 'package:browny_applications_new/core/env/app_evnironment.dart';
import 'package:browny_applications_new/core/env/dev_environment.dart';
import 'package:browny_applications_new/core/res/strings/app_localizations.dart';
import 'package:browny_applications_new/core/res/theme/app_theme.dart';
import 'package:browny_applications_new/core/viewmodels/app_preferences.dart';
import 'package:browny_applications_new/core/widgets/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

void main() async {
  // if (PlatformUtils.isWeb) {
  // usePathUrlStrategy();
  // }
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize HTTP AppClient
  AppEvnironment env = DevEnvironment();
  AppClient.init(env.apiConfig);

  // // Initialize AppLocalStorage
  final localStorage = AppLocalStorage.instance();
  await localStorage.init();

  runApp(
    BrownyApp(
      appRouter: AppRouter(),
    ),
  );
}

class BrownyApp extends StatelessWidget {
  const BrownyApp({
    super.key,
    required this.appRouter,
  });
  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppPreferences()),
      ],
      child: Consumer<AppPreferences>(
        builder: (context, provider, _) {
          return ScreenUtilInit(
            // From Team design screen sizing
            designSize: const Size(375, 812),
            builder: (_, _) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'Browny',

                // Localize th, en, zh
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: provider.getLocalLanguage(),
                theme: AppTheme.lightTheme,

                // rounting
                routerConfig: appRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}
