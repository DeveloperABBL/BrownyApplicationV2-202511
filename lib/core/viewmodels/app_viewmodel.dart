import 'package:browny_applications_new/core/env/app_evnironment.dart';
import 'package:browny_applications_new/core/providers/customer_provider.dart';
import 'package:browny_applications_new/core/viewmodels/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class AppViewModel extends ChangeNotifier {
  @protected
  BuildContext context;

  @protected
  late final AppPreferences appPreferences;

  AppViewModel({required this.context}) {
    appPreferences = context.read<AppEvnironment>().appPreferences;
  }

  CustomerProvider get currentCustomerProvider =>
      context.read<CustomerProvider>();

  void attachContext(BuildContext newContext) {
    context = newContext;
  }
}

class AppViewModelObscureHandler extends AppViewModel {
  AppViewModelObscureHandler({required super.context});

  final ValueNotifier<bool> _isObscure = ValueNotifier(true);
  ValueNotifier<bool> get isObscure => _isObscure;
  void onObscureChange() {
    _isObscure.value = !_isObscure.value;
  }

  @override
  void dispose() {
    _isObscure.dispose();
    super.dispose();
  }
}
