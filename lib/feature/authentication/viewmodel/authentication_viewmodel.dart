import 'package:browny_applications_new/core/data/remote/models/response/customer_profile_response.dart';
import 'package:browny_applications_new/core/data/remote/models/response/login_customer_response.dart';
import 'package:browny_applications_new/core/providers/customer_provider.dart';
import 'package:browny_applications_new/core/res/strings/app_strings.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/authentication/models/login_model.dart';
import 'package:browny_applications_new/feature/authentication/repository/customer_data_repo.dart';
import 'package:browny_applications_new/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum SignUpRequiredState {
  valideEmalOrPhone,
  // passwordHasUppercase,
  passwordHasLowercase,
  passwordHasDigit,
  acceptTermOfPolicy,
}

enum AuthenProcess {
  login,
  signup,
  forgotPassword,
  forgotPasswordPinning,
  forgotPasswordNewPassword,
}

class AuthenticationViewModel extends AppViewModelObscureHandler {
  AuthenticationViewModel({
    required super.context,
    required this.authenProcess,
    required this.customerDataRepo,
  });

  final CustomerDataSoureMixin customerDataRepo;

  final AuthenProcess authenProcess;

  final GlobalKey<FormState> formKey = GlobalKey();
  late final TextEditingController usernameController = TextEditingController();
  late final TextEditingController passwordController = TextEditingController();
  final Set<SignUpRequiredState> _validations = SignUpRequiredState.values
      .toSet();
  late final ValueNotifier<bool> _validatorTriggle = ValueNotifier(false);
  ValueNotifier<bool> get validatorTriggle => _validatorTriggle;

  String? validatorEmailOrPhone(String? value) {
    _validations.add(SignUpRequiredState.valideEmalOrPhone);
    // ตรวจสอบว่าค่าที่รับเข้ามาเป็นค่าว่างหรือไม่
    if (value == null || value.trim().isEmpty) {
      return context.wording.pleaseEnterEmailOrPhone;
    }

    // สร้างรูปแบบ (regex) สำหรับตรวจสอบอีเมล
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    // สร้างรูปแบบ (regex) สำหรับตรวจสอบเบอร์โทรศัพท์ของประเทศไทย (10 หลัก ขึ้นต้นด้วย 0)
    final phoneRegex = RegExp(r'^0\d{9}$');

    if (value.contains('@') && !emailRegex.hasMatch(value)) {
      return context.wording.pleaseEnterValidEmail;
    }

    if (value.startsWith('0') && !phoneRegex.hasMatch(value)) {
      return context.wording.pleaseEnterValidPhoneNumber;
    }

    // ถ้าไม่ตรงกับรูปแบบอีเมลและไม่ตรงกับรูปแบบเบอร์โทร
    if (!emailRegex.hasMatch(value) && !phoneRegex.hasMatch(value)) {
      return context.wording.pleaseEnterValidEmailOrPhone;
    }

    _validations.removeWhere(
      (e) => e == SignUpRequiredState.valideEmalOrPhone,
    );
    _onValidatorTriggle();
    return null; // ข้อมูลถูกต้อง ไม่ต้องแจ้งเตือน
  }

  String? validatorPassword(String? value) {
    // ตรวจสอบว่าค่าที่รับเข้ามาเป็นค่าว่างหรือไม่
    if (value == null || value.trim().isEmpty) {
      return context.wording.pleaseEnterPassword;
    }

    if (value.length < 8) {
      return context.wording.passwordMustBeAtLeast8Characters;
    }
    // final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasCharectorcase = value.contains(RegExp(r'[a-zA-Z]'));
    final hasDigit = value.contains(RegExp(r'\d'));

    _validations.addAll({
      // SignUpRequiredState.passwordHasUppercase,
      SignUpRequiredState.passwordHasLowercase,
      SignUpRequiredState.passwordHasDigit,
    });
    _onValidatorTriggle();

    StringBuffer stringBuffer = StringBuffer();

    // if (!hasUppercase) {
    //   stringBuffer.write(
    //     '- ${context.wording.passwordMustContainUppercase}',
    //   );
    // } else {
    //   _validations.removeWhere(
    //     (e) => e == SignUpRequiredState.passwordHasUppercase,
    //   );
    // }
    if (!hasCharectorcase) {
      stringBuffer
        ..writeln()
        ..write('- ${context.wording.passwordMustContainLowercase}');
    } else {
      _validations.removeWhere(
        (e) => e == SignUpRequiredState.passwordHasLowercase,
      );
    }
    if (!hasDigit) {
      stringBuffer
        ..writeln()
        ..write('- ${context.wording.passwordMustContainNumber}');
    } else {
      _validations.removeWhere(
        (e) => e == SignUpRequiredState.passwordHasDigit,
      );
    }
    if (!hasCharectorcase || !hasDigit) {
      return stringBuffer.toString();
    }
    _onValidatorTriggle();
    return null;
  }

  void checkboxTermOfPolicyChanged(bool? value) {
    if (value == null || !value) {
      _validations.add(SignUpRequiredState.acceptTermOfPolicy);
      _onValidatorTriggle();
      return;
    }
    _validations.removeWhere(
      (e) => e == SignUpRequiredState.acceptTermOfPolicy,
    );
    _onValidatorTriggle();
  }

  void _onValidatorTriggle() {
    _validatorTriggle.value = _validations.isEmpty;
  }

  void onSignUp() {
    if (formKey.currentState?.validate() == true && _validations.isEmpty) {}
  }

  Future<UiResult<LoginCustomerData>> onLogin() async {
    if (formKey.currentState?.validate() == true) {
      final loginResult = await customerDataRepo.login(
        username: usernameController.text,
        password: passwordController.text,
      );

      if (loginResult.isEmpty) {
        return UiResult.empty(error: loginResult.error);
      }

      if (loginResult.hasError) {
        return UiResult.error(error: loginResult.error);
      }

      if (!context.mounted) return UiResult.empty();

      final profileResult = await customerDataRepo.fetchProfile('');
      context
          .read<CustomerProvider>()
          .newUser = UserModel.fromCustomerProfileData(
        profileResult.data.data,
      );

      return UiResult.success(
        data: loginResult.data.data!,
      );
    }
    return UiResult.empty();
  }

  @override
  void dispose() {
    _validatorTriggle.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
