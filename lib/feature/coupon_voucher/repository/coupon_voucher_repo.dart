import 'package:browny_applications_new/feature/authentication/repository/customer_data_repo.dart';

mixin CouponVoucherDataSourceMixin on CustomerDataSourceMixin {}

class CouponVoucherRepo extends CustomerDataRepo
    with CouponVoucherDataSourceMixin {}
