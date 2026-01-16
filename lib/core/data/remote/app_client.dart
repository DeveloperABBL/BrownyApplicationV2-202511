import 'package:browny_applications_new/core/data/remote/models/request/request_otp.dart';
import 'package:browny_applications_new/core/data/remote/models/request/topup_request.dart';
import 'package:browny_applications_new/core/data/remote/models/request/update_profile_request.dart';
import 'package:browny_applications_new/core/data/remote/models/request/verify_otp.dart';
import 'package:browny_applications_new/core/data/remote/models/response/banner_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/base_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coin_claim_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/coin_claimed_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/customer_profile_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/customer_qr_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/introductions_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/referral_reward_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/request_otp_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/topup_request_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/verify_otp_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/wallet_receipt_response.dart';
import 'package:dio/dio.dart';
import 'package:browny_applications_new/core/data/remote/models/api_configs.dart';
import 'package:browny_applications_new/core/data/remote/models/request/customer_credential.dart';
import 'package:browny_applications_new/core/data/remote/models/response/login_customer_response.dart';
import 'package:retrofit/retrofit.dart';

part 'app_client.g.dart';

/// Note: เมื่อมีการแก้ไข ให้ run command นี้ใน terminal ด้วย
///
/// dart run build_runner build --delete-conflicting-outputs
@RestApi()
abstract class AppClient {
  static final _AppClient _instance = _AppClient(
    Dio(
      BaseOptions(
        contentType: 'application/json; charset=utf-8',
        connectTimeout: const Duration(minutes: 1),
        sendTimeout: const Duration(minutes: 1),
        receiveTimeout: const Duration(minutes: 1),
      ),
    ),
  );

  factory AppClient.instance() => _instance;

  factory AppClient.init(ApiConfigs config) {
    return _instance
      ..baseUrl = config.baseUrl
      .._dio.options.headers.putIfAbsent(
        'Authorization',
        () => 'Bearer ${config.token}',
      );
  }

  /// DONG 2026-01-15
  ///
  /// API ส่งไป claim coin
  @POST('/coin/claim')
  Future<HttpResponse<CoinClaimedResponse>> coinClaiming(
    @Body() Map<String, dynamic> body,
  );

  /// DONG 2026-01-15
  ///
  /// API fetch coin claim data ตาม customer_id
  @GET('/coin')
  Future<HttpResponse<CoinClaimResponse>> getCoinClaimData(
    @Query('customer_id') String customerId,
  );

  /// DONG 2026-01-13
  ///
  /// API fetch referral rewards ตาม customer_id
  @GET('/referral/rewards')
  Future<HttpResponse<ReferralRewardResponse>> fetchReferralReward(
    @Body() Map<String, dynamic> body,
  );

  /// DONG 2026-01-11
  ///
  /// API fetch QRCode ของ customer ตาม [uuid]
  @GET('/customer/{uuid}/qrcode')
  Future<HttpResponse<CustomerQRResponse>> fetchCustomerQRCode(
    @Path('uuid') String uuid,
  );

  /// DONG 2026-01-10
  ///
  /// สำหรับเช็คข้อมูล Receipt ตาม [paymentRef]
  @GET('/wallet/receipt/{payment_ref}')
  Future<HttpResponse<WalletReceiptResponse>> walletReceipt(
    @Path('payment_ref') String paymentRef,
  );

  /// DONG 2026-01-10
  ///
  /// สำหรับเช็ค Status ที่ [topupRequest]
  @GET('/wallet/payment/status/{payment_ref}')
  Future<HttpResponse<TopupRequestResponse>> checkWalletStatusPayment(
    @Path('payment_ref') String paymentRef,
  );

  /// DONG 2026-01-10
  ///
  /// สำหรับสร้าง request เติมเงิน
  @POST('/wallet/topup-request')
  Future<HttpResponse<TopupRequestResponse>> topupRequest(
    @Body() TopupRequest body,
  );

  @POST('/referrals')
  Future<HttpResponse<BaseResponse?>> saveReferral(
    @Body() CustomerCredential body,
  );

  /// DONG 2025-12-05
  ///
  /// API สำหรับ verify OTP ที่กรอกเข้ามา
  @POST('/customer/verify-otp')
  Future<HttpResponse<VerifyOTPResponse?>> verifyOTP(
    @Body() VerifyOTP body,
  );

  /// DONG 2025-12-05
  ///
  /// API ส่ง OTP ไปที่ User
  @POST('/customer/request-otp')
  Future<HttpResponse<RequestOTPResponse?>> requestOtp(
    @Body() RequestOTP body,
  );

  /// DONG 2025-12-05
  ///
  /// API สำหรับเช็ค [CustomerCredential.username] ว่ามีในระบบแล้วหรือยัง
  ///
  /// ---
  /// **NOTE** ใช้ model [LoginCustomerResponse] รับ Response แต่จะไม่ได้ข้อมูลอะไรกลับมา
  /// เพราะจะเอาแค่ [LoginCustomerResponse.success] เท่านั้น
  @POST('/customer/check-username')
  Future<HttpResponse<LoginCustomerResponse?>> checkUsername(
    @Body() CustomerCredential body,
  );

  /// DONG 2025-12-05
  ///
  /// fetch ข้อมูล เงินคงเหลือ, coin คงเหลือของ User
  @GET('/customer/{uuid}/credit')
  Future<HttpResponse<CustomerProfileData>> fetchCustomerCredit(
    @Path('uuid') String uuid,
  );

  /// DONG 2026-01-06
  ///
  /// API อัพเดทข้อมูล Profile ของ User
  @PUT('/customer/update-profile')
  Future<HttpResponse<CustomerProfileResponse?>> updateProfile(
    @Body() UpdateProfileRequest body,
  );

  /// DONG 2025-11-24
  ///
  /// API fech profile ของ User ที่ login เข้ามาใช้งาน
  @POST('/customer/profile')
  Future<HttpResponse<CustomerProfileResponse?>> fetchCustomerProfile(
    @Body() Map<String, dynamic> body,
  );

  /// DONG 2025-11-17
  ///
  /// API register new customer
  @POST('/customer/register')
  Future<HttpResponse<LoginCustomerResponse?>> register(
    @Body() CustomerCredential credential,
  );

  /// DONG 2025-11-10
  ///
  /// API Login Customer
  ///
  /// ***param*** : [CustomerCredential] กำหนดข้อมูลในการเข้าใช้งานระบบ
  @POST('/customer/login')
  Future<HttpResponse<LoginCustomerResponse?>> login(
    @Body() CustomerCredential credential,
  );

  /// DONG 2025-11-13
  ///
  /// API Fetch รูป Banners
  @GET('/banners')
  Future<HttpResponse<BannerResponse?>> fetchBanners();

  /// DONG 2025-11-10
  ///
  /// API fetch Content OnBoarding
  @GET('/introductions')
  Future<HttpResponse<List<IntroductionsResponse>?>> fetchIntroductions();
}
