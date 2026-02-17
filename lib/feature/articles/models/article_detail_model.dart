import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/data/remote/models/response/banner_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/banner_highlight_response.dart';

class ArticleDetailModel {
  ArticleDetailModel({
    this.id,
    this.name,
    this.type,
    this.target,
    this.category,
    this.image,
    this.title,
    this.subtitle,
    this.dateTime,
  });

  final int? id;

  final String? name;

  final String? type;

  final String? target;

  final CategoryData? category;

  final ContentLocalizeData? image;

  final ContentLocalizeData? title;

  final ContentLocalizeData? subtitle;

  final DateTime? dateTime;

  factory ArticleDetailModel.fromBannerData(BannerData data) {
    return ArticleDetailModel(
      id: data.id,
      name: data.name,
      type: data.type,
      target: data.target,
      category: data.category,
      image: data.image,
      title: data.title,
      subtitle: data.subtitle,
      dateTime: data.dateTime,
    );
  }

  factory ArticleDetailModel.fromBannerHighlightData(BannerHighlightData data) {
    return ArticleDetailModel(
      id: data.id,
      name: data.name,
      type: data.type,
      target: data.target,
      category: data.category,
      image: data.image,
      title: data.title,
      subtitle: data.subtitle,
      dateTime: data.dateTime,
    );
  }
}
