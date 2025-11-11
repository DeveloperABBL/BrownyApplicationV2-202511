import 'package:browny_applications_new/core/data/remote/models/api_configs.dart';
import 'package:browny_applications_new/core/env/app_evnironment.dart';

class DevEnvironment extends AppEvnironment {
  DevEnvironment()
    : super(
        apiConfigs: ApiConfigs(
          baseUrl: 'https://dev.abgroup.co.th/api',
          token:
              '8074cac22d628c5d71dbb635504e25a7fc04e05a5e4b327f30a20674bead82eb',
        ),
      );
}
