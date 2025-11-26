import 'package:flutter/widgets.dart';

sealed class AuthenExceptions implements Exception {
  final String? message;

  AuthenExceptions([this.message]);

  String toUiMessage(BuildContext context) {
    return '';
  }
}

class UserNotFound extends AuthenExceptions {
  UserNotFound([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    return 'ไม่พบบัญชีผู้ใช้ที่ตรงกับข้อมูลนี้';
  }
}

class UserUnauthorized extends AuthenExceptions {
  UserUnauthorized([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    return 'รหัสผ่านไม่ถูกต้อง';
  }
}
