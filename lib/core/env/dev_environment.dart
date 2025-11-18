import 'package:browny_applications_new/core/data/remote/models/api_configs.dart';
import 'package:browny_applications_new/core/env/app_evnironment.dart';
import 'package:browny_applications_new/core/viewmodels/app_preferences.dart';
import 'package:browny_applications_new/core/widgets/app_router.dart';
import 'package:browny_applications_new/feature/home/screens/home_page.dart';
import 'package:browny_applications_new/feature/onboarding/screen/onboarding_page.dart';

class DevEnvironment extends AppEvnironment {
  DevEnvironment({
    ApiConfigs? apiConfigs,
    AppPreferences? appPreferences,
    AppRouter? appRouter,
  });

  @override
  Future<void> loadEnv() async {
    // สร้าง API Config call ไปที่ Enviroment DEV
    apiConfig = ApiConfigs(
      baseUrl: 'https://dev.abgroup.co.th/api',
      token: '8074cac22d628c5d71dbb635504e25a7fc04e05a5e4b327f30a20674bead82eb',
    );
    // สร้าง local storage
    appPreferences = AppPreferences();
    appRouter = AppRouter(
      // เช็คว่าเคยเปิด App และผ่านหน้า OnBoarding แล้วหรือยัง
      initialLocation: appPreferences.isFirstLaunch()
          // ถ้ายังไป
          ? OnBoardingPage.pagePath
          // ถ้าเคยแล้วไป
          : HomePage.pagePath,
    );
  }
}
