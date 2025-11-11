import 'package:browny_applications_new/core/viewmodels/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class AppViewModel extends ChangeNotifier {
  @protected
  BuildContext context;

  @protected
  late final AppPreferences appPreferences;

  AppViewModel({required this.context}) {
    appPreferences = context.read<AppPreferences>();
  }

  void attachContext(BuildContext newContext) {
    context = newContext;
  }
}
