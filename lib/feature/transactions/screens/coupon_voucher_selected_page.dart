import 'package:browny_applications_new/feature/transactions/viewmodel/coupon_voucher_selected_viewmodel_delegate.dart';
import 'package:flutter/widgets.dart';

class CouponVoucherSelected extends StatefulWidget {
  const CouponVoucherSelected({
    super.key,
    required CouponVoucherSelectedViewmodelDelegate viewmodel,
  }) : _viewmodel = viewmodel;

  final CouponVoucherSelectedViewmodelDelegate _viewmodel;

  static final pagePath = '/CouponVoucherSelected';
  static final pageName = 'CouponVoucherSelected';

  @override
  State<CouponVoucherSelected> createState() => _CouponVoucherSelectedState();
}

class _CouponVoucherSelectedState extends State<CouponVoucherSelected> {
  @override
  void dispose() {
    widget._viewmodel.disposeDelegate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}
