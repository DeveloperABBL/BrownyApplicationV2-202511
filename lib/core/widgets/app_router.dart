import 'package:browny_applications_new/feature/authentication/screen/biometric_page.dart';
import 'package:browny_applications_new/feature/authentication/screen/create_app_pin_page.dart';
import 'package:browny_applications_new/feature/authentication/viewmodel/authentication_viewmodel.dart';
import 'package:browny_applications_new/feature/home/screens/home_page.dart';
import 'package:browny_applications_new/feature/onboarding/screen/onboarding_page.dart';
import 'package:browny_applications_new/feature/authentication/screen/authentication_page.dart';
import 'package:browny_applications_new/feature/profile/screen/profile_page.dart';
import 'package:browny_applications_new/feature/scaner/screen/scanner_page.dart';
import 'package:browny_applications_new/feature/wallet/screen/payment_sucess_page.dart';
import 'package:browny_applications_new/feature/wallet/screen/show_qr_promptpay_page.dart';
import 'package:browny_applications_new/feature/wallet/screen/wallet_page.dart';
import 'package:browny_applications_new/feature/wallet/viewmodel/wallet_viewmodel.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter({
    required this.initialLocation,
  });

  final String initialLocation;

  late final GoRouter router = GoRouter(
    initialLocation: initialLocation,
    // initialLocation: RegistrationPage.pagePath,
    debugLogDiagnostics: true, // Enable debug logs
    routes: [
      GoRoute(
        path: OnBoardingPage.pagePath,
        name: OnBoardingPage.pageName,
        builder: (context, state) => const OnBoardingPage(),
      ),
      GoRoute(
        path: HomePage.pagePath,
        name: HomePage.pageName,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AuthenticationPage.pagePath,
        name: AuthenticationPage.pageName,
        builder: (context, state) {
          final extra = state.extra as Map<Type, dynamic>?;
          final authenProcess = extra?[AuthenProcess];
          return AuthenticationPage(authenProcess: authenProcess);
        },
      ),
      GoRoute(
        path: ProfilePage.pagePath,
        name: ProfilePage.pageName,
        builder: (context, state) {
          bool isEditing = false;
          try {
            final extra = state.extra as Map<String, dynamic>?;
            isEditing = extra?[ProfilePage.kEditing];
          } catch (ignore) {}
          return ProfilePage(isFirstSignup: isEditing);
        },
      ),
      GoRoute(
        path: CreateAppPinPage.pagePath,
        name: CreateAppPinPage.pageName,
        builder: (context, state) => const CreateAppPinPage(),
      ),
      GoRoute(
        path: BiometricPage.pagePath,
        name: BiometricPage.pageName,
        builder: (context, state) => const BiometricPage(),
      ),
      GoRoute(
        path: WalletPage.pagePath,
        name: WalletPage.pageName,
        builder: (context, state) => const WalletPage(),
      ),
      GoRoute(
        path: ShowQRPromptpayPage.pagePath,
        name: ShowQRPromptpayPage.pageName,
        builder: (context, state) {
          final viewModel = state.extra as WalletViewModel;
          return ShowQRPromptpayPage(viewModel: viewModel);
        },
      ),
      GoRoute(
        path: PaymentSuccessPage.pagePath,
        name: PaymentSuccessPage.pageName,
        builder: (context, state) {
          final viewModel = state.extra as WalletViewModel;
          return PaymentSuccessPage(
            viewmodel: viewModel,
          );
        },
      ),
      GoRoute(
        path: ScannerPage.pagePath,
        name: ScannerPage.pageName,
        builder: (context, state) => const ScannerPage(),
      ),
    ],
  );
}
