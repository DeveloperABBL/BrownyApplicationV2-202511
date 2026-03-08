import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/core/data/remote/models/response/banner_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/banner_highlight_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';

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
    this.detail,
    this.dateTime,
    this.hasButton,
    this.buttonStatus,
    this.couponId,
  });

  final int? id;

  final String? name;

  final String? type;

  final String? target;

  final CategoryData? category;

  final ContentLocalizeData? image;

  final ContentLocalizeData? title;

  final ContentLocalizeData? subtitle;

  final ContentLocalizeData? detail;

  final DateTime? dateTime;

  final bool? hasButton;

  final String? buttonStatus;

  final int? couponId;

  bool get hasArticleButton => (hasButton ?? false) && buttonStatus != null;

  bool get isClaimable =>
      buttonStatus != null && buttonStatus!.toLowerCase() == 'claim now';

  bool get isClaimed =>
      buttonStatus != null && buttonStatus!.toLowerCase() == 'claimed';

  bool get isExpired =>
      buttonStatus != null && buttonStatus!.toLowerCase() == 'expired';

  bool get isFullyClaimed =>
      buttonStatus != null && buttonStatus!.toLowerCase() == 'fully claimed';

  String getArticleButtonDisplay(String locale) {
    if (isClaimed) {
      return ContentLocalizeData(
        en: 'Claimed',
        zh: '已领取',
        th: 'รับสิทธิ์แล้ว',
      ).getTextByLocale(locale);
    }

    if (isExpired) {
      return ContentLocalizeData(
        en: 'Expired',
        zh: '已过期',
        th: 'หมดเขต',
      ).getTextByLocale(locale);
    }

    if (isFullyClaimed) {
      return ContentLocalizeData(
        en: 'Fully Claimed',
        zh: '已领满',
        th: 'สิทธิ์เต็มแล้ว',
      ).getTextByLocale(locale);
    }

    return ContentLocalizeData(
      en: 'Claim Now',
      zh: '领取',
      th: 'รับสิทธิ์',
    ).getTextByLocale(locale);
  }

  ArticleDetailModel copyWith({
    int? id,
    String? name,
    String? type,
    String? target,
    CategoryData? category,
    ContentLocalizeData? image,
    ContentLocalizeData? title,
    ContentLocalizeData? subtitle,
    ContentLocalizeData? detail,
    DateTime? dateTime,
    bool? hasButton,
    String? buttonStatus,
    int? couponId,
  }) {
    return ArticleDetailModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      target: target ?? this.target,
      category: category ?? this.category,
      image: image ?? this.image,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      detail: detail ?? this.detail,
      dateTime: dateTime ?? this.dateTime,
      hasButton: hasButton ?? this.hasButton,
      buttonStatus: buttonStatus ?? this.buttonStatus,
      couponId: couponId ?? this.couponId,
    );
  }

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
      detail: data.detail,
      dateTime: data.dateTime,
      hasButton: data.hasButton,
      buttonStatus: data.buttonStatus,
      couponId: data.couponId,
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
      detail: data.detail,
      dateTime: data.dateTime,
      hasButton: data.hasButton,
      buttonStatus: data.buttonStatus,
      couponId: data.couponId,
    );
  }
}
