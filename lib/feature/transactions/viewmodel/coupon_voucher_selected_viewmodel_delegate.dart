import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/transactions/models/customer_coupon_model.dart';

mixin CouponVoucherSelectedViewmodelDelegate
    implements AppViewModelDelegateMixin {
  /// ข้อมูล E-Voucher ของ Customer ที่เลือกเข้ามา
  CustomerCouponModel? _customerCouponModelDelegate;
  CustomerCouponModel? get customerCouponModelDelegate =>
      _customerCouponModelDelegate;

  set setCustomerCouponSelectedDelegate(CustomerCouponModel selected) {
    _customerCouponModelDelegate = selected;
  }

  @override
  void disposeDelegate() {
    _customerCouponModelDelegate = null;
  }
}
