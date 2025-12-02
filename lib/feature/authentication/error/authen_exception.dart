import 'package:browny_applications_new/core/res/strings/app_strings.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:flutter/widgets.dart';

sealed class AuthenExceptions implements Exception {
  final String? message;

  AuthenExceptions([this.message]);

  String toUiMessage(BuildContext context) {
    return message.orEmpty;
  }
}

class UserNotFound extends AuthenExceptions {
  UserNotFound([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    return context.wording.userNotFound;
  }
}

class UserUnauthorized extends AuthenExceptions {
  UserUnauthorized([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    return context.wording.userUnauthorized;
  }
}

class UserDuplicated extends AuthenExceptions {
  UserDuplicated([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    return context.wording.userDuplicated;
  }
}
