import 'package:browny_applications_new/core/res/colors/app_colors.dart';
import 'package:browny_applications_new/core/res/strings/app_strings.dart';
import 'package:browny_applications_new/core/widgets/app_overlays.dart';
import 'package:browny_applications_new/feature/profile/repository/profile_repo.dart';
import 'package:browny_applications_new/feature/profile/viewmodel/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static final pagePath = '/profile_page';
  static final pageName = 'profile_page';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ProfileViewModel(context: context, repo: ProfileRepo()),
      child: ProfileWidget(),
    );
  }
}

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late final ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ProfileViewModel>();
    _viewModel.attachContext(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            AppOverlays.showLoading(
              context,
              timeout: Duration(seconds: 3),
              onTimeout: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  SnackBar(content: Text('Time out')),
                );
              },
            );
            final result = await _viewModel.logout();
            if (result.isSuccess && context.mounted) {
              context.pop();
            }
            AppOverlays.hideLoading();
          },
          child: Text(context.wording.logout),
        ),
      ),
    );
  }
}
