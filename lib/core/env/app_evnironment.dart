import 'package:browny_applications_new/core/data/remote/models/api_configs.dart';

abstract class AppEvnironment {
  AppEvnironment({
    required ApiConfigs apiConfigs,
  }) : _apiConfigs = apiConfigs;

  final ApiConfigs _apiConfigs;
  ApiConfigs get apiConfig => _apiConfigs;
}
