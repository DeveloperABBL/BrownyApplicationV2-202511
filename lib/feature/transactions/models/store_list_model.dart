import 'package:browny_applications_new/core/data/remote/models/response/coupon_store_list_response.dart';
import 'package:flutter/widgets.dart';

class StoreListModel extends CouponStoreData {
  StoreListModel({
    super.id,
    super.name,
  });

  factory StoreListModel.fromCouponData(CouponStoreData data) =>
      StoreListModel(id: data.id, name: data.name);

  String nameDisplay(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return name?.getByLocaleCode(locale) ?? '';
  }
}
