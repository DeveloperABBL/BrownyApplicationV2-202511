import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/res/strings/app_strings.dart';
import 'package:flutter/material.dart';

sealed class WalletException implements Exception {
  final String? message;

  WalletException([this.message]);

  String toUiMessage(BuildContext context) {
    return message.orEmpty;
  }
}

class Unprocessable extends WalletException {
  Unprocessable([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    return context.wording.errorUi;
  }
}

class PenddingException extends WalletException {
  PenddingException([super.message]);

  @override
  String toUiMessage(BuildContext context) {
    return '';
  }
}
