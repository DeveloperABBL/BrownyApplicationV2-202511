import 'package:browny_applications_new/core/data/remote/models/api_configs.dart';
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
}
