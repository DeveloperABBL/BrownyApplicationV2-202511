import 'package:browny_applications_new/core/data/cache/app_local_storage.dart';
import 'package:browny_applications_new/core/data/remote/app_client.dart';
import 'package:browny_applications_new/core/data/remote/models/api_configs.dart';
import 'package:browny_applications_new/core/data/remote/models/response/login_customer_response.dart';
import 'package:browny_applications_new/core/env/app_evnironment.dart';
import 'package:browny_applications_new/core/providers/customer_provider.dart';
import 'package:browny_applications_new/core/utils/social_auth_helper.dart';
import 'package:browny_applications_new/core/viewmodels/app_preferences.dart';
import 'package:browny_applications_new/core/widgets/app_router.dart';
import 'package:browny_applications_new/feature/authentication/repository/customer_data_repo.dart';
import 'package:browny_applications_new/feature/home/screens/home_page.dart';
import 'package:browny_applications_new/feature/onboarding/screen/onboarding_page.dart';
import 'package:browny_applications_new/models/user_model.dart';
import 'package:hive_ce/hive.dart';

class DevEnvironment extends AppEvnironment {
  DevEnvironment({
    ApiConfigs? apiConfigs,
    AppPreferences? appPreferences,
    AppRouter? appRouter,
  });

  @override
  Future<void> loadEnv() async {
    // 1. สร้าง API Config call ไปที่ Enviroment DEV
    apiConfig = ApiConfigs(
      // dev API
      baseUrl: 'https://dev.abgroup.co.th/api',
      // dev token
      token: '8074cac22d628c5d71dbb635504e25a7fc04e05a5e4b327f30a20674bead82eb',
    );

    // 2. Initialize AppLocalStorage
    await AppLocalStorage.instance().init();

    // 3. Initialize HTTP AppClient
    AppClient.init(
      apiConfig,
    );

    // LINE Channel ID : 2009026542
    SocialAuthHelper.initLineSDK('2009026542');

    // สร้าง local storage
    appPreferences = AppPreferences();
    var isFirstLaunch = appPreferences.isFirstLaunch();
    final customerDataRepo = CustomerDataRepo();

    // retrive ex-data
    if (isFirstLaunch) {
      // ดึงข้อมูล User จาก
      final authBox = await Hive.openBox<LoginCustomerData>('auth');
      try {
        if (authBox.keys.isNotEmpty && authBox.containsKey('values')) {
          final authData = authBox.get('values');

          if (authData != null) {
            customerDataRepo.saveLocalLoginCustomerData(authData);
            final profileResult = await customerDataRepo.fetchProfile(
              authData.customerId!,
            );
            if (profileResult.isSuccess) {
              final user = UserModel.fromCustomerProfileData(
                profileResult.data.data,
              );
              _current.newUser = user;
            }
          }
        }
      } on Exception catch (_) {}
      await authBox.close();
    } else {
      // อ่านจาก Local ที่อาจจะเคย login เอาไว้แล้วก่อน
      final profileLocal = await customerDataRepo.customerProfileData();
      if (profileLocal.isSuccess) {
        //  ถ้าเจอจะ fetch เอาข้อมูล Profile ใหม่
        final profileResult = await customerDataRepo.fetchProfile(
          profileLocal.data.id!,
        );
        if (profileResult.isSuccess) {
          final user = UserModel.fromCustomerProfileData(
            profileResult.data.data,
          );
          _current.newUser = user;
        }
      }
    }

    appRouter = AppRouter(
      // เช็คว่าเคยเปิด App และผ่านหน้า OnBoarding แล้วหรือยัง
      initialLocation: isFirstLaunch
          // ถ้ายังไป
          ? OnBoardingPage.pagePath
          // ถ้าเคยแล้วไป
          : HomePage.pagePath,
    );
  }

  final CustomerProvider _current = CustomerProvider();

  @override
  CustomerProvider get currentUser => _current;
}
