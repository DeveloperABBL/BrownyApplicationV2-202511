import 'package:browny_applications_new/core/data/remote/models/content_localize_data.dart';
import 'package:browny_applications_new/res/strings/app_strings.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:flutter/widgets.dart';

sealed class AuthenExceptions implements Exception {
  final String? message;

  AuthenExceptions([this.message]);

  String toUiMessage(BuildContext context) {
    return message.orEmpty;
  }

  @override
  String toString() {
    return message ?? 'Exception';
  }
}

class Unprocessable extends AuthenExceptions {
  Unprocessable([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    return context.wording.errorUi;
  }

  @override
  String toString() {
    return super.message ?? 'Unprocessable';
  }
}

class UserNotFound extends AuthenExceptions {
  UserNotFound([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    return context.wording.userNotFound;
  }

  @override
  String toString() {
    return super.message ?? 'UserNotFound';
  }
}

class UserUnauthorized extends AuthenExceptions {
  UserUnauthorized([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    return super.message ?? context.wording.userUnauthorized;
  }

  @override
  String toString() {
    return super.message ?? 'UserUnauthorized';
  }
}

class UserDuplicated extends AuthenExceptions {
  UserDuplicated([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    return context.wording.userDuplicated;
  }

  @override
  String toString() {
    return super.message ?? 'UserDuplicated';
  }
}

class UserConsentTermOfPolicy extends AuthenExceptions {
  UserConsentTermOfPolicy([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    return context.wording.userDuplicated;
  }

  @override
  String toString() {
    return super.message ?? 'UserConsentTermOfPolicy';
  }
}

class OTPUnauthorized extends AuthenExceptions {
  OTPUnauthorized([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    return context.wording.otpUnauthorizedError;
  }

  @override
  String toString() {
    return super.message ?? 'OTPUnauthorized';
  }
}

class OTPExpired extends AuthenExceptions {
  OTPExpired([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    return context.wording.otpUnauthorizedError;
  }

  @override
  String toString() {
    return super.message ?? 'OTPExpired';
  }
}

class CollectCouponNotFound extends AuthenExceptions {
  CollectCouponNotFound([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    return ContentLocalizeData(
      en: 'Your coupon code is invalid',
      zh: '您的优惠券代码无效',
      th: 'รหัสคูปองของคุณไม่ถูกต้อง',
    ).getTextByLocale(context.languageCode);
  }

  @override
  String toString() {
    return super.message ?? 'Coupon Not Found';
  }
}

class CollectCouponCollected extends AuthenExceptions {
  CollectCouponCollected([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    return ContentLocalizeData(
      en: 'You have already collected this coupon',
      zh: '您已经领取了此优惠券',
      th: 'คุณได้รับคูปองนี้ไปแล้ว',
    ).getTextByLocale(context.languageCode);
  }

  @override
  String toString() {
    return super.message ?? 'Coupon Collected';
  }
}

class ChangePasswordInvalidOldPassword extends AuthenExceptions {
  ChangePasswordInvalidOldPassword([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    return ContentLocalizeData(
      en: 'Old password is incorrect',
      zh: '旧密码不正确',
      th: 'รหัสผ่านเดิมไม่ถูกต้อง',
    ).getTextByLocale(context.languageCode);
  }

  @override
  String toString() {
    return super.message ?? 'Invalid old password!';
  }
}

class ChangePasswordReused extends AuthenExceptions {
  ChangePasswordReused([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    return ContentLocalizeData(
      en: 'New password must not be the same as the old password',
      zh: '新密码不能与旧密码相同',
      th: 'รหัสผ่านใหม่ต้องไม่ซ้ำกับรหัสผ่านเดิม',
    ).getTextByLocale(context.languageCode);
  }

  @override
  String toString() {
    return super.message ?? 'Password re-used!';
  }
}
