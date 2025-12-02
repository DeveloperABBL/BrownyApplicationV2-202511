import 'dart:async';

import 'package:browny_applications_new/core/data/remote/models/request/customer_credential.dart';
import 'package:browny_applications_new/core/data/remote/models/response/login_customer_response.dart';
import 'package:browny_applications_new/core/res/strings/app_strings.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/authentication/repository/customer_data_repo.dart';
import 'package:browny_applications_new/models/user_model.dart';
import 'package:flutter/material.dart';

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
  signupPinning,
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

  // =========== OTP Timer ===========
  Timer? _otpTimer;
  final ValueNotifier<int> _remainingSeconds = ValueNotifier(60);
  final ValueNotifier<bool> _canResendOtp = ValueNotifier(false);

  ValueNotifier<int> get remainingSeconds => _remainingSeconds;
  ValueNotifier<bool> get canResendOtp => _canResendOtp;

  // =========== getter ===========
  /// Getter สำหรับแสดงชื่อผู้ใช้แบบปิดบัง (obscure)
  /// - กรณีเป็น email: แสดงครึ่งแรกของ local part แล้วปิดบังที่เหลือด้วย ***
  /// - กรณีเป็นเบอร์โทร: แสดง 6 หลักแรก แล้วปิดบังที่เหลือด้วย ***
  String get usernameObscure {
    // ตัดช่องว่างหน้า-หลังของข้อความ
    final text = usernameController.text.trim();

    // ถ้าข้อความว่างเปล่า ให้คืนค่าเป็นข้อความว่าง
    if (text.isEmpty) {
      return '';
    }

    // ตรวจสอบว่าเป็น email (มีเครื่องหมาย @)
    if (text.contains('@')) {
      // แยกส่วน local part และ domain part ด้วยเครื่องหมาย @
      final parts = text.split('@');
      if (parts.length == 2) {
        final localPart = parts[0]; // ส่วนหน้า @ (เช่น username)
        final domainPart = parts[1]; // ส่วนหลัง @ (เช่น gmail.com)

        // ถ้า local part มีความยาวมากกว่า 3 ตัวอักษร
        // แสดงครึ่งแรกของ local part แล้วปิดบังที่เหลือด้วย ***
        if (localPart.length > 3) {
          final visiblePart = localPart.substring(0, localPart.length ~/ 2);
          return '$visiblePart***@$domainPart';
        }
        // ถ้า local part มีความยาวน้อยกว่าหรือเท่ากับ 3 ตัวอักษร
        // แสดง local part ทั้งหมด แล้วปิดบังด้วย ***
        return '$localPart***@$domainPart';
      }
    }

    // ตรวจสอบว่าเป็นเบอร์โทรศัพท์ของไทย (10 หลัก ขึ้นต้นด้วย 0)
    final phoneRegex = RegExp(r'^0\d{9}$');
    if (phoneRegex.hasMatch(text)) {
      // แสดง 6 หลักแรก แล้วปิดบังที่เหลือด้วย ***
      return '${text.substring(0, 6)}***';
    }

    // ถ้าไม่ใช่ทั้ง email และเบอร์โทร ให้คืนค่าข้อความต้นฉบับ
    return text;
  }

  // =========== validation ===========

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

  // =========== event login, logout, regist ===========

  Future<UiResult<void>> onSignUp() async {
    if (formKey.currentState?.validate() == true && _validations.isEmpty) {
      // ถ้าเป็นจังหวะกรอก username, password validate แล้วข้อมูลถูกต้องตามเงื่อนไข
      // จะ return success ออกไปเพื่อให้ไป AuthenProcess.signupPinning ต่อ
      if (authenProcess == AuthenProcess.signup) {
        return UiResult.success(data: null);
      }

      final response = await customerDataRepo.register(
        CustomerCredential(
          username: usernameController.text,
          password: passwordController.text,
        ),
      );

      if (response.isEmpty) {
        // เกิด Error จากการ call API register เช่น
        // - user ซ้ำ
        // - insert เข้า Database ไม่ได้
        return UiResult.empty(error: response.error);
      }

      if (response.hasError) {
        // Error อื่นๆ ที่ไม่ได้ handle เอาไว้
        return UiResult.error(error: response.error);
      }
      // ลงทะเบียนสำเร็จ
      return UiResult.success(data: null);
    }

    return UiResult.empty();
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

      final profileResult = await customerDataRepo.fetchProfile(
        loginResult.data.data!.customerId!,
      );

      if (!context.mounted) return UiResult.empty();

      // เปลี่ยนข้อมูล User เป็นที่ Login เข้ามา
      currentCustomerProvider.newUser = UserModel.fromCustomerProfileData(
        profileResult.data.data,
      );

      return UiResult.success(
        data: loginResult.data.data!,
      );
    }
    return UiResult.empty();
  }

  // =========== OTP Timer Methods ===========

  void startOtpTimer() {
    _remainingSeconds.value = 60;
    _canResendOtp.value = false;

    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds.value > 0) {
        _remainingSeconds.value--;
      } else {
        _canResendOtp.value = true;
        timer.cancel();
      }
    });
  }

  void resendOtp() {
    // TODO: เรียก API เพื่อส่ง OTP ใหม่
    print('Resending OTP...');
    startOtpTimer();
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _validatorTriggle.dispose();
    _remainingSeconds.dispose();
    _canResendOtp.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
