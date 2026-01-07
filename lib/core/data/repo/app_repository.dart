import 'package:browny_applications_new/core/data/cache/app_local_storage.dart';
import 'package:browny_applications_new/core/data/cache/app_local_secure_storage.dart';
import 'package:browny_applications_new/core/data/remote/app_client.dart';

abstract class AppRepository {
  final AppClient _appClient;
  final AppLocalStorage _localStorage;
  final AppLocalSecureStorage _secureStorage;

  AppRepository({
    AppClient? appClient,
    AppLocalStorage? localStorage,
    AppLocalSecureStorage? secureStorage,
  }) : _appClient = appClient ?? AppClient.instance(),
       _localStorage = localStorage ?? AppLocalStorage.instance(),
       _secureStorage = secureStorage ?? AppLocalSecureStorage.instance();

  AppClient get requireRemote => _appClient;
  AppLocalStorage get requireLocalStorage => _localStorage;
  AppLocalSecureStorage get requireSecureStorage => _secureStorage;
}
