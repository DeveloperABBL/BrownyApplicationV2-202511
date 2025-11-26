import 'dart:async';

import 'package:browny_applications_new/core/const/app_constants.dart';
import 'package:browny_applications_new/core/data/remote/models/request/customer_credential.dart';
import 'package:browny_applications_new/core/data/remote/models/response/customer_profile_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/login_customer_response.dart';
import 'package:browny_applications_new/core/data/repo/app_repository.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/repo_result.dart';
import 'package:browny_applications_new/feature/authentication/error/authen_exception.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

/// มิกซ์อินสำหรับจัดการข้อมูลการเข้าสู่ระบบ
mixin CustomerDataSoureMixin {
  FutureOr<RepoResult<CustomerProfileData>> customerProfileData();

  /// ฟังก์ชันดึง coin และ wallet ตาม [id] ของ user ที่ login เข้ามา
  Future<RepoResult<CustomerProfileData>> fetchCustomerCredit(String id);

  /// ฟังก์ชันดึง Profile จาก [id] ที่ส่งเข้ามา
  /// [id] จะได้จากการ [login] สำเร็จเท่านั้น
  Future<RepoResult<CustomerProfileResponse>> fetchProfile(String id);

  /// ฟังก์ชันเข้าสู่ระบบ รับ username และ password
  /// [username] - ชื่อผู้ใช้ที่ต้องการเข้าสู่ระบบ ใช้สำหรับระบุตัวตนของผู้ใช้
  /// [password] - รหัสผ่านของผู้ใช้ ใช้สำหรับตรวจสอบความถูกต้องในการเข้าสู่ระบบ
  /// คืนค่าเป็น Future ของ RepoResult ที่มี LoginCustomerResponse
  Future<RepoResult<LoginCustomerResponse>> login({
    required String username, // ชื่อผู้ใช้ที่ต้องการเข้าสู่ระบบ
    required String password, // รหัสผ่านของผู้ใช้
  });
}

/// คลาสสำหรับจัดการรีโพซิทอรีการเข้าสู่ระบบ
class CustomerDataRepo extends AppRepository with CustomerDataSoureMixin {
  @override
  FutureOr<RepoResult<CustomerProfileData>> customerProfileData() {
    try {
      final readResult = requireLocalStorage.read<CustomerProfileData>(
        kCustomerProfile,
      );

      return RepoResult.dependOn(readResult);
    } on Exception catch (e) {
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<CustomerProfileData>> fetchCustomerCredit(String id) async {
    try {
      final creditDataResponse = await requireRemote.fetchCustomerCredit(id);
      // จะสนใจแค่ดึงได้หรือไม่
      return RepoResult.dependOn(creditDataResponse.data);
    } on DioException catch (dioEx) {
      // ถ้าดึงไม่ได้เพราะ id ไม่ถูกจะได้ code 500
      return RepoResult.empty(error: dioEx);
    } on Exception catch (e) {
      // error อื่นๆ
      return RepoResult.error(error: e);
    }
  }

  @override
  Future<RepoResult<CustomerProfileResponse>> fetchProfile(String id) async {
    try {
      final response = await requireRemote.fetchCustomerProfile(
        {'id': id},
      );
      if (response.isSuccessful) {
        var profile = response.data!.data;

        try {
          // ถ้า fetch profile ได้ จะ fetch coin มาด้วย
          final creditData = await fetchCustomerCredit(id);

          if (creditData.isSuccess) {
            profile = profile.copyWith(
              creditBalance: creditData.data.creditBalance,
              brownyCoin: creditData.data.brownyCoin,
            );
          }
        } finally {
          saveLocalProfile(profile);
        }
      }

      // คืนค่าตามข้อมูลที่ได้รับจาก response
      return RepoResult.dependOn(response.data);
    } on DioException catch (dioEx) {
      // ถ้าไม่พบผู้ใช้
      if (dioEx.response!.isNotFound) {
        return RepoResult.empty(
          error: UserNotFound(),
        );
      }

      // ถ้าผู้ใช้ไม่ได้รับอนุญาต
      if (dioEx.response!.isUnauthorized) {
        return RepoResult.empty(
          error: UserUnauthorized(),
        );
      }
      // เพิ่ม return สำหรับกรณีอื่น ๆ ของ DioException
      return RepoResult.error(error: dioEx);
    } on Exception catch (e) {
      // คืนค่าข้อผิดพลาดอื่น ๆ
      return RepoResult.error(
        error: e,
      );
    }
  }

  /// ฟังก์ชันเข้าสู่ระบบ
  /// [username] - ชื่อผู้ใช้ที่ต้องการเข้าสู่ระบบ ใช้สำหรับระบุตัวตนของผู้ใช้
  /// [password] - รหัสผ่านของผู้ใช้ ใช้สำหรับตรวจสอบความถูกต้องในการเข้าสู่ระบบ
  /// คืนค่าเป็น Future ของ RepoResult ที่มี LoginCustomerResponse
  @override
  Future<RepoResult<LoginCustomerResponse>> login({
    required String username, // ชื่อผู้ใช้ที่ต้องการเข้าสู่ระบบ
    required String password, // รหัสผ่านของผู้ใช้
  }) async {
    try {
      // เรียกใช้งาน remote เพื่อเข้าสู่ระบบด้วยข้อมูลผู้ใช้
      final response = await requireRemote.login(
        CustomerCredential(username: username, password: password),
      );

      // ถ้าเข้าสู่ระบบสำเร็จ
      if (response.isSuccessful) {
        // ถ้า login ด้วย username, password ผ่าน จะ fetch profile มาเก็บไว้
        final fetchProfileResult = await fetchProfile(
          // ใช้ customer id จากการ login
          response.data!.data!.customerId!,
        );

        if (fetchProfileResult.isSuccess) {
          // เขียนข้อมูลผู้ใช้ลง local storage เฉพาะ login, fetch profile ผ่านเท่านั้น
          saveLocalLoginCustomerData(response.data!.data!);

          // คืนค่าความสำเร็จพร้อมข้อมูล
          return RepoResult.success(data: response.data!);
        }
      }

      // คืนค่าตามข้อมูลที่ได้รับจาก response
      return RepoResult.dependOn(response.data);
    } catch (e) {
      // กรณีเกิดข้อผิดพลาดจาก DioException
      if (e is DioException) {
        // ถ้าไม่พบผู้ใช้
        if (e.response!.isNotFound) {
          return RepoResult.empty(
            error: UserNotFound(),
          );
        }

        // ถ้าผู้ใช้ไม่ได้รับอนุญาต
        if (e.response!.isUnauthorized) {
          return RepoResult.empty(
            error: UserUnauthorized(),
          );
        }
      }
      // คืนค่าข้อผิดพลาดอื่น ๆ
      return RepoResult.error(
        error: Exception('Unknown error occurred'),
      );
    }
  }

  void saveLocalLoginCustomerData(LoginCustomerData data) {
    requireLocalStorage.write<LoginCustomerData>(
      key: kCustomerData,
      value: data,
    );
  }

  void saveLocalProfile(CustomerProfileData data) {
    requireLocalStorage.write(
      key: kCustomerProfile,
      value: data,
    );
  }
}
