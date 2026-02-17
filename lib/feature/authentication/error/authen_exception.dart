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
    return context.wording.userUnauthorized;
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
