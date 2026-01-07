import 'package:browny_applications_new/core/data/remote/models/response/request_otp_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/verify_otp_response.dart';

class RequestOTPModel extends OTPData {
  RequestOTPModel({
    super.refCode,
    super.username,
    super.expiredIn,
  });

  @override
  String get refCode => super.refCode ?? '';
}

class VerifyOTPModel extends VerifyOTPResponse {}
