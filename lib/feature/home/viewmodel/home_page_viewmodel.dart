import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/home/models/banner_model.dart';
import 'package:browny_applications_new/feature/home/repository/home_repo.dart';

class HomePageViewmodel extends AppViewModel {
  HomePageViewmodel({
    required super.context,
    required HomeDataSourceMixin repo,
  }) : _repo = repo;

  HomeDataSourceMixin _repo;

  Future<UiResult<List<BannerModel>>> fetchBanners() async {
    await Future.delayed(Duration(seconds: 2));
    return UiResult.empty();
  }
}
