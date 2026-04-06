import 'dart:ui';

import 'package:browny_applications_new/core/data/cache/app_local_storage.dart';

class AppPreferences {
  AppPreferences({
    AppLocalStoreMixin? appLocalStorage,
  }) : _appLocalStorage = AppLocalStorage.instance();

  static const String _keyIsFirstLaunch = 'ISFIRSTRUN';
  static const String _keyLanguage = 'language';

  final AppLocalStorage _appLocalStorage;

  bool isFirstLaunch() => _appLocalStorage.read<bool>(
    _keyIsFirstLaunch,
    defaultValue: true,
  )!;
  void flagFirstLaunch() => _appLocalStorage.write(
    key: _keyIsFirstLaunch,
    value: false,
  );
  void reFlagFirstLaunch() => _appLocalStorage.write(
    key: _keyIsFirstLaunch,
    value: true,
  );

  /// Get language code (th, en, etc.)
  String getLanguage() {
    return _appLocalStorage.read(
      _keyLanguage,
      defaultValue: PlatformDispatcher.instance.locale.languageCode,
    )!;
  }

  Locale getLocalLanguage() {
    final languageCode = _appLocalStorage.read(
      _keyLanguage,
      defaultValue: PlatformDispatcher.instance.locale.languageCode,
    )!;
    return Locale.fromSubtags(languageCode: languageCode);
  }

  /// Set language code
  void setLanguage(String languageCode) {
    _appLocalStorage.write(key: _keyLanguage, value: languageCode);
  }
}
