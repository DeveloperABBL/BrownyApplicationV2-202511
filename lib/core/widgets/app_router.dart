import 'package:browny_applications_new/core/providers/customer_provider.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/widgets/app_text.dart';
import 'package:browny_applications_new/feature/authentication/screen/biometric_page.dart';
import 'package:browny_applications_new/feature/authentication/screen/app_pin_page.dart';
import 'package:browny_applications_new/feature/authentication/viewmodel/authentication_viewmodel.dart';
import 'package:browny_applications_new/feature/authentication/viewmodel/pin_biometric_viewmodel.dart';
import 'package:browny_applications_new/feature/coin/screens/coin_page.dart';
import 'package:browny_applications_new/feature/map/screens/map_page.dart';
import 'package:browny_applications_new/feature/profile/screen/my_profile_and_preferences_page.dart';
import 'package:browny_applications_new/feature/transactions/screens/available_payment_method_page.dart';
import 'package:browny_applications_new/feature/transactions/screens/coupon_voucher_page.dart';
import 'package:browny_applications_new/feature/transactions/screens/coupon_voucher_selected_page.dart';
import 'package:browny_applications_new/feature/transactions/screens/purchase_coupon_voucher_page.dart';
import 'package:browny_applications_new/feature/transactions/screens/receipt_page.dart';
import 'package:browny_applications_new/feature/transactions/screens/transaction_selected_page.dart';
import 'package:browny_applications_new/feature/transactions/viewmodel/coupon_voucher_selected_viewmodel_delegate.dart';
import 'package:browny_applications_new/feature/transactions/viewmodel/purchase_coupon_viewmodel_delegate.dart';
import 'package:browny_applications_new/feature/home/screens/home_page.dart';
import 'package:browny_applications_new/feature/invit_friend/screen/invit_friend_page.dart';
import 'package:browny_applications_new/feature/onboarding/screen/onboarding_page.dart';
import 'package:browny_applications_new/feature/authentication/screen/authentication_page.dart';
import 'package:browny_applications_new/feature/profile/screen/profile_page.dart';
import 'package:browny_applications_new/feature/scaner/screen/scanner_page.dart';
import 'package:browny_applications_new/feature/transactions/viewmodel/transactions_viewmodel.dart';
import 'package:browny_applications_new/feature/wallet/screen/payment_sucess_page.dart';
import 'package:browny_applications_new/feature/wallet/screen/show_qr_promptpay_page.dart';
import 'package:browny_applications_new/feature/wallet/screen/wallet_page.dart';
import 'package:browny_applications_new/feature/wallet/viewmodel/wallet_viewmodel.dart';
import 'package:browny_applications_new/res/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
            isEditing = extra?[ProfilePage.kFirstSignup];
          } catch (ignore) {}
          return ProfilePage(isFirstSignup: isEditing);
        },
      ),
      GoRoute(
        path: MyProfileAndPreferencesPage.pagePath,
        name: MyProfileAndPreferencesPage.pageName,
        builder: (context, state) {
          return MyProfileAndPreferencesPage();
        },
      ),
      GoRoute(
        path: CreateAppPinPage.pagePath,
        name: CreateAppPinPage.pageName,
        builder: (context, state) {
          bool implementBackButton = false;
          bool isFirstSignup = false;
          PinBiometricPross process;
          try {
            final extra = state.extra as Map<String, dynamic>?;
            implementBackButton = extra?[CreateAppPinPage.kImplementBackButton];
            isFirstSignup = extra?[CreateAppPinPage.kFirstSignup];
          } catch (ignore) {}
          try {
            final extra = state.extra as Map<String, dynamic>?;
            // {String, Map<Type, PinBiometricPross>}
            process =
                extra?[CreateAppPinPage
                    .kPinBiometricProcess][PinBiometricPross];
          } catch (ignore) {
            return Scaffold(
              body: Center(
                child: AppText(
                  'PIN Page needs PinBiometricPross',
                  style: context.textTheme.labelLarge!.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            );
          }

          return CreateAppPinPage(
            implementBackButton: implementBackButton,
            isFirstSignup: isFirstSignup,
            process: process,
          );
        },
      ),
      GoRoute(
        path: BiometricPage.pagePath,
        name: BiometricPage.pageName,
        builder: (context, state) {
          bool isFirstSignup = false;
          try {
            final extra = state.extra as Map<String, dynamic>?;
            isFirstSignup = extra?[BiometricPage.kFirstSignup];
          } catch (_) {}
          return BiometricPage(
            isFirstSignup: isFirstSignup,
          );
        },
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
      GoRoute(
        path: InvitFriendPage.pagePath,
        name: InvitFriendPage.pageName,
        builder: (context, state) => const InvitFriendPage(),
      ),
      GoRoute(
        path: CoinPage.pagePath,
        name: CoinPage.pageName,
        builder: (context, state) => const CoinPage(),
      ),
      GoRoute(
        path: CouponVoucherPage.pagePath,
        name: CouponVoucherPage.pageName,
        builder: (context, state) {
          if (context.read<CustomerProvider>().current.isGuest) {
            return AuthenticationPage(
              authenProcess: AuthenProcess.login,
            );
          }
          return const CouponVoucherPage();
        },
      ),
      GoRoute(
        path: CouponVoucherSelected.pagePath,
        name: CouponVoucherSelected.pageName,
        builder: (context, state) {
          final viewModel =
              state.extra as CouponVoucherSelectedViewmodelDelegate;
          return CouponVoucherSelected(
            viewmodel: viewModel,
          );
        },
      ),
      GoRoute(
        path: PurchaseCouponVoucherPage.pagePath,
        name: PurchaseCouponVoucherPage.pageName,
        builder: (context, state) {
          final viewModel = state.extra as PurchaseCouponViewmodelDelegate;
          return PurchaseCouponVoucherPage(
            viewmodel: viewModel,
          );
        },
      ),
      GoRoute(
        path: TransactionSelectedPage.pagePath,
        name: TransactionSelectedPage.pageName,
        builder: (context, state) {
          final viewModel = state.extra as TransactionsViewmodel;
          return TransactionSelectedPage(
            viewmodel: viewModel,
          );
        },
      ),
      GoRoute(
        path: ReceiptPage.pagePath,
        name: ReceiptPage.pageName,
        builder: (context, state) {
          final viewModel = state.extra as TransactionsViewmodel;
          return ReceiptPage(
            viewmodel: viewModel,
          );
        },
      ),
      GoRoute(
        path: MapPage.pagePath,
        name: MapPage.pageName,
        builder: (context, state) {
          return MapPage();
        },
      ),
      GoRoute(
        path: AvailablePaymentMethodPage.pagePath,
        name: AvailablePaymentMethodPage.pageName,
        builder: (context, state) {
          final viewModel = state.extra as TransactionsViewmodel;
          return AvailablePaymentMethodPage(
            viewmodel: viewModel,
          );
        },
      ),
      GoRoute(
        path: TransactionAuthenPage.pagePath,
        name: TransactionAuthenPage.pageName,
        builder: (context, state) => TransactionAuthenPage(),
      ),
    ],
  );
}
