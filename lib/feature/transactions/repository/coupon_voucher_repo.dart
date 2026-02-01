import 'package:browny_applications_new/core/data/remote/models/request/coupon_list_request.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coupon_data_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coupon_detail_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coupon_package_list_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coupon_store_list_response.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';
import 'package:browny_applications_new/feature/authentication/repository/customer_data_repo.dart';

mixin CouponVoucherDataSourceMixin on CustomerDataSourceMixin {
  /// ฟังก์ชันดึงรายการคูปอง E-Voucher ของ customer ตาม [uuid]
  Future<RepoResult<CouponEVoucherResponse>> fetchCouponEVoucher(
    String uuid, {
    String? storeMachineId,
  });

  /// ฟังก์ชันดึงรายการคูปองส่วนลดของ customer ตาม [uuid]
  Future<RepoResult<CouponDiscountResponse>> fetchCouponDiscount(String uuid);

  /// ฟังก์ชันดึงรายการคูปองแลกซื้อของ customer ตาม [uuid]
  Future<RepoResult<CouponRedemptionResponse>> fetchCouponRedemption(
    String uuid,
  );

  /// ฟังก์ชันดึงรายการสาขาร้านค้าที่ใช้คูปองได้
  Future<RepoResult<CouponStoreListResponse>> fetchCouponStoreList();

  /// ฟังก์ชันดึงรายละเอียดคูปองตาม couponId
  ///
  /// [couponId] - รหัสคูปอง
  /// [request] - ข้อมูล latitude, longitude, customerId
  Future<RepoResult<CouponDetailResponse>> fetchCouponDetail(
    int couponId,
    CouponListRequest request,
  );

  /// ฟังก์ชันดึงรายการแพ็คเกจคูปอง
  ///
  /// [latitude] - ละติจูดของผู้ใช้
  /// [longitude] - ลองจิจูดของผู้ใช้
  /// [customerId] - รหัสลูกค้า
  Future<RepoResult<CouponPackageListResponse>> fetchCouponPackageList({
    String? latitude,
    String? longitude,
    String? customerId,
  });
}

class CouponVoucherRepo extends CustomerDataRepo
    with CouponVoucherDataSourceMixin {
  @override
  Future<RepoResult<CouponEVoucherResponse>> fetchCouponEVoucher(
    String uuid, {
    String? storeMachineId,
  }) async {
    try {
      final response = await requireRemote.fetchCouponEVoucher(
        uuid,
        storeMachineId,
      );
      return RepoResult.dependOn(response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<CouponDiscountResponse>> fetchCouponDiscount(
    String uuid,
  ) async {
    try {
      final response = await requireRemote.fetchCouponDiscount(uuid);
      return RepoResult.dependOn(response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<CouponRedemptionResponse>> fetchCouponRedemption(
    String uuid,
  ) async {
    try {
      final response = await requireRemote.fetchCouponRedemption(uuid);
      return RepoResult.dependOn(response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<CouponStoreListResponse>> fetchCouponStoreList() async {
    try {
      final response = await requireRemote.fetchCouponStoreList();
      return RepoResult.dependOn(response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<CouponDetailResponse>> fetchCouponDetail(
    int couponId,
    CouponListRequest request,
  ) async {
    try {
      final response = await requireRemote.fetchCouponDetail(
        couponId,
        request,
      );
      return RepoResult.dependOn(response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<CouponPackageListResponse>> fetchCouponPackageList({
    String? latitude,
    String? longitude,
    String? customerId,
  }) async {
    try {
      final request = CouponListRequest(
        latitude: latitude,
        longitude: longitude,
        customerId: customerId,
      );

      final response = await requireRemote.fetchCouponPackageList(request);

      if (response.data.data.orEmpty.isEmpty) {
        return RepoResult.empty();
      }

      return RepoResult.dependOn(response.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
