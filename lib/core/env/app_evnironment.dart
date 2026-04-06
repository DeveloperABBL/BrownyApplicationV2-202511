import 'package:browny_applications_new/core/data/remote/models/api_configs.dart';
import 'package:browny_applications_new/core/providers/customer_provider.dart';
import 'package:browny_applications_new/core/viewmodels/app_preferences.dart';
import 'package:browny_applications_new/core/widgets/app_router.dart';
import 'package:flutter/material.dart';

abstract class AppEvnironment extends ChangeNotifier {
  AppEvnironment({
    ApiConfigs? apiConfigs,
    AppPreferences? appPreferences,
    AppRouter? appRouter,
  }) : _apiConfigs = apiConfigs,
       _appPreferences = appPreferences,
       _appRouter = appRouter;

  ApiConfigs? _apiConfigs;
  @protected
  set apiConfig(ApiConfigs config) => _apiConfigs = config;
  ApiConfigs get apiConfig => _apiConfigs!;

  AppPreferences? _appPreferences;
  @protected
  set appPreferences(AppPreferences prefs) => _appPreferences = prefs;
  AppPreferences get appPreferences => _appPreferences!;

  AppRouter? _appRouter;
  @protected
  set appRouter(AppRouter router) => _appRouter = router;
  AppRouter get appRouter => _appRouter!;

  Future<void> loadEnv();

  CustomerProvider get currentUser;

  /// Laravel APP_KEY สำหรับ decrypt PIN ciphertext
  ///
  /// **Security Note:**
  /// - แต่ละ environment ควรมี APP_KEY ต่างกัน (dev/staging/prod)
  /// - ไม่ควร commit APP_KEY ลง git
  /// - ควรใช้ environment variables หรือ secure build configs
  String get laravelAppKey;

  void onLocaleChange(String localeCode) {
    appPreferences.setLanguage(localeCode);
    notifyListeners();
  }
}
