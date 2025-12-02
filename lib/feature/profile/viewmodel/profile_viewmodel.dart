import 'dart:async';

import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/profile/repository/profile_repo.dart';
import 'package:browny_applications_new/models/user_model.dart';

class ProfileViewModel extends AppViewModel {
  ProfileViewModel({
    required super.context,
    required this.repo,
  });

  final ProfileRepo repo;

  FutureOr<UiResult<UserModel>> logout() async {
    final logoutResult = await repo.logout();

    if (!context.mounted) return UiResult.empty();

    if (logoutResult.isSuccess) {
      return UiResult.success(
        data: currentCustomerProvider.logout(),
      );
    }

    return UiResult.error(error: logoutResult.error);
  }
}
