import 'package:browny_applications_new/core/data/remote/models/response/banner_highlight_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/banner_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:flutter/material.dart';

class BannerModel extends BannerData {
  BannerModel({
    super.id,
    super.name,
    super.type,
    super.image,
    super.title,
    super.subtitle,
    super.category,
    super.dateTime,
  });

  factory BannerModel.fromBannerResponse(BannerData response) {
    return BannerModel(
      id: response.id,
      name: response.name,
      type: response.type,
      image: response.image,
      title: response.title,
      subtitle: response.subtitle,
      category: response.category,
      dateTime: response.dateTime,
    );
  }

  String imageDisplay(BuildContext context) {
    String code = Localizations.localeOf(context).languageCode;
    return super.image?.getByLocaleCode(code) ?? '';
  }

  String titleDisplay(BuildContext context) {
    String code = Localizations.localeOf(context).languageCode;
    return super.title?.getByLocaleCode(code) ?? '';
  }

  String subtitleDisplay(BuildContext context) {
    String code = Localizations.localeOf(context).languageCode;
    return super.subtitle?.getByLocaleCode(code) ?? '';
  }

  @override
  int get id => super.id ?? -1;

  @override
  String get name => super.name.orEmpty;

  @override
  String get type => super.type.orEmpty;
}

class BannerHighLightModel extends BannerHighlightData {
  BannerHighLightModel({
    super.id,
    super.name,
    super.type,
    super.image,
    super.title,
    super.subtitle,
    super.dateTime,
    super.category,
    super.target,
  });

  factory BannerHighLightModel.fromBannerResponse(
    BannerHighlightData response,
  ) {
    return BannerHighLightModel(
      id: response.id,
      name: response.name,
      type: response.type,
      image: response.image,
      title: response.title,
      subtitle: response.subtitle,
      dateTime: response.dateTime,
      category: response.category,
      target: response.target,
    );
  }

  String imageDisplay(BuildContext context) {
    String code = Localizations.localeOf(context).languageCode;
    return super.image?.getByLocaleCode(code) ?? '';
  }

  String titleDisplay(BuildContext context) {
    String code = Localizations.localeOf(context).languageCode;
    return super.title?.getByLocaleCode(code) ?? '';
  }

  String subtitleDisplay(BuildContext context) {
    String code = Localizations.localeOf(context).languageCode;
    return super.subtitle?.getByLocaleCode(code) ?? '';
  }

  @override
  int get id => super.id ?? -1;

  @override
  String get name => super.name.orEmpty;

  @override
  String get type => super.type.orEmpty;
}
