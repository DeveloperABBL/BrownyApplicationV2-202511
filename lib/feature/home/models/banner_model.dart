import 'package:browny_applications_new/core/data/remote/models/response/banner_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';

class BannerModel extends BannerResponse {
  BannerModel({
    required super.id,
    required super.name,
    required super.type,
    required this.imageDisplay,
    required this.titleDisplay,
    required this.subtitleDisplay,
  });

  final String imageDisplay;
  final String titleDisplay;
  final String subtitleDisplay;

  @override
  int get id => super.id ?? -1;

  @override
  String get name => super.name.orEmpty;

  @override
  String get type => super.type.orEmpty;
}
