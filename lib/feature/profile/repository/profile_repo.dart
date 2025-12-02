import 'dart:async';

import 'package:browny_applications_new/core/const/app_constants.dart';
import 'package:browny_applications_new/core/data/remote/models/response/customer_profile_response.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';
import 'package:browny_applications_new/feature/authentication/repository/customer_data_repo.dart';

mixin ProfileDataSourceMixin {
  FutureOr<RepoResult<CustomerProfileData>> logout();
}

class ProfileRepo extends CustomerDataRepo with ProfileDataSourceMixin {
  @override
  FutureOr<RepoResult<CustomerProfileData>> logout() async {
    requireLocalStorage.delete(kCustomerProfile);

    final logoutResult = requireLocalStorage.read<CustomerProfileData>(
      kCustomerProfile,
      defaultValue: null,
    );

    if (logoutResult == null) {
      return RepoResult.success(data: CustomerProfileData());
    }

    return RepoResult.error(
      error: Exception(
        'Cannot Logout Profile ${logoutResult.id}',
      ),
    );
  }
}
