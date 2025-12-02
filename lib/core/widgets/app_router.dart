import 'package:browny_applications_new/feature/authentication/viewmodel/authentication_viewmodel.dart';
import 'package:browny_applications_new/feature/home/screens/home_page.dart';
import 'package:browny_applications_new/feature/onboarding/screen/onboarding_page.dart';
import 'package:browny_applications_new/feature/authentication/screen/authentication_page.dart';
import 'package:browny_applications_new/feature/profile/screen/profile_page.dart';
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
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}
