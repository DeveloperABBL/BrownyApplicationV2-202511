import 'package:browny_applications_new/core/data/remote/models/response/customer_profile_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/login_customer_response.dart';
import 'package:hive_ce/hive.dart';

/// Note: เมื่อมีการแก้ไข ให้ run command นี้ใน terminal ด้วย
///
/// dart run build_runner build --delete-conflicting-outputs
@GenerateAdapters([
  // ข้อมูล Customer ที่ Login
  AdapterSpec<LoginCustomerData>(),
  // ข้อมูล Customer Profile ที่ Login
  AdapterSpec<CustomerProfileData>(),
])
part 'app_hive_adapters.g.dart';
