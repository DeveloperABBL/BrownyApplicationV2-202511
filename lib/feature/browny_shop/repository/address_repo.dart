import 'package:browny_applications_new/core/data/remote/models/request/address_request.dart';
import 'package:browny_applications_new/core/data/remote/models/response/address_response.dart';
import 'package:browny_applications_new/core/data/repo/app_repository.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';

/// Mixin Interface สำหรับ Repository ของที่อยู่จัดส่งลูกค้า
mixin AddressDataSourceMixin {
  /// API fetch รายการที่อยู่จัดส่งทั้งหมดของลูกค้า
  Future<RepoResult<List<AddressData>>> fetchAddresses({
    required String customerId,
  });

  /// API เพิ่มที่อยู่จัดส่งใหม่
  Future<RepoResult<AddressData>> createAddress({
    required String customerId,
    required AddressRequest body,
  });

  /// API แก้ไขที่อยู่จัดส่ง
  Future<RepoResult<AddressData>> updateAddress({
    required int addressId,
    required AddressRequest body,
  });

  /// API ลบที่อยู่จัดส่ง — คืน true ถ้าสำเร็จ
  Future<RepoResult<bool>> deleteAddress({required int addressId});

  /// API ตั้งที่อยู่จัดส่งเป็นค่าเริ่มต้น — คืน true ถ้าสำเร็จ
  Future<RepoResult<bool>> setDefaultAddress({required int addressId});
}

/// Repository สำหรับที่อยู่จัดส่งของลูกค้า
class AddressRepo extends AppRepository with AddressDataSourceMixin {
  @override
  Future<RepoResult<List<AddressData>>> fetchAddresses({
    required String customerId,
  }) async {
    try {
      final response = await requireRemote.fetchAddresses(customerId);
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.dependOn(response.data.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<AddressData>> createAddress({
    required String customerId,
    required AddressRequest body,
  }) async {
    try {
      final response = await requireRemote.createAddress(customerId, body);
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.dependOn(response.data.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<AddressData>> updateAddress({
    required int addressId,
    required AddressRequest body,
  }) async {
    try {
      final response = await requireRemote.updateAddress(addressId, body);
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.dependOn(response.data.data);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<bool>> deleteAddress({required int addressId}) async {
    try {
      final response = await requireRemote.deleteAddress(addressId);
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data.isResponseSuccess);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<bool>> setDefaultAddress({required int addressId}) async {
    try {
      final response = await requireRemote.setDefaultAddress(addressId);
      if (!response.isSuccessful) {
        return RepoResult.empty();
      }
      return RepoResult.success(data: response.data.isResponseSuccess);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }
}
