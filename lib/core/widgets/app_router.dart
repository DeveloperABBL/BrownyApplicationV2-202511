import 'package:browny_applications_new/feature/home/screens/home_page.dart';
import 'package:browny_applications_new/feature/onboarding/screen/onboarding_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final GoRouter router = GoRouter(
    initialLocation: OnBoardingPage.pagePath,
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
    ],
  );
}
