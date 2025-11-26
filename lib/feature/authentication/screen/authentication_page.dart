import 'package:browny_applications_new/core/res/colors/app_colors.dart';
import 'package:browny_applications_new/core/res/dims/app_dims.dart';
import 'package:browny_applications_new/core/res/icons/assets.gen.dart';
import 'package:browny_applications_new/core/res/strings/app_strings.dart';
import 'package:browny_applications_new/core/res/styles/app_text_style.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/widgets/app_container_radius.dart';
import 'package:browny_applications_new/core/widgets/app_overlays.dart';
import 'package:browny_applications_new/core/widgets/app_text.dart';
import 'package:browny_applications_new/feature/authentication/error/authen_exception.dart';
import 'package:browny_applications_new/feature/authentication/repository/customer_data_repo.dart';
import 'package:browny_applications_new/feature/authentication/viewmodel/authentication_viewmodel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AuthenticationPage extends StatelessWidget {
  const AuthenticationPage({
    super.key,
    required AuthenProcess authenProcess,
  }) : _authenProcess = authenProcess;

  static final pagePath = '/authentication_page';
  static final pageName = 'authentication';

  final AuthenProcess _authenProcess;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthenticationViewModel(
        context: context,
        authenProcess: _authenProcess,
        customerDataRepo: CustomerDataRepo(),
      ),
      child: _AuthenticationWidget(),
    );
  }
}

class _AuthenticationWidget extends StatefulWidget {
  const _AuthenticationWidget();

  @override
  State<_AuthenticationWidget> createState() => _AuthenticationWidgetState();
}

class _AuthenticationWidgetState extends State<_AuthenticationWidget> {
  late final AuthenticationViewModel _viewmodel;

  @override
  void initState() {
    super.initState();
    _viewmodel = context.read();
    _viewmodel.attachContext(context);
  }

  @override
  Widget build(BuildContext context) {
    // แสดงหน้าตามประเภทของกระบวนการยืนยันตัวตน (login, signup, forgot password)
    switch (_viewmodel.authenProcess) {
      case AuthenProcess.login:
        // แสดงหน้าเข้าสู่ระบบ
        return _LoginWidget(_viewmodel);

      case AuthenProcess.signup:
        // แสดงหน้าสมัครสมาชิก
        return _SignUpWidget(_viewmodel);

      case AuthenProcess.forgotPassword:
        // แสดงหน้าลืมรหัสผ่าน
        return _ForgotPasswordWidget(_viewmodel);

      case AuthenProcess.forgotPasswordPinning:
        // TODO: Handle this case.
        throw UnimplementedError();

      case AuthenProcess.forgotPasswordNewPassword:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}

/// Widget สำหรับหน้าสมัครสมาชิก (Sign Up)
///
/// - แสดงพื้นหลังแบบ Gradient
/// - แสดง Banner ด้านบนพร้อมปุ่มย้อนกลับ (ถ้ามี stack ให้ pop ได้)
/// - ส่วนเนื้อหาหลักประกอบด้วย:
///   - ข้อความโปรยและรายละเอียดการสมัครสมาชิก
///   - ฟอร์มกรอกอีเมล/เบอร์โทรศัพท์ และรหัสผ่าน พร้อมตรวจสอบความถูกต้อง
///   - Checkbox สำหรับยอมรับเงื่อนไขการใช้งาน
///   - ปุ่มสมัครสมาชิก (Sign Up) ที่จะเปิดใช้งานเมื่อข้อมูลถูกต้อง
///   - ตัวเลือกสมัครสมาชิกผ่าน Social Login (Facebook, Google, Apple, Line)
///
/// ใช้ร่วมกับ [AuthenticationViewModel] เพื่อจัดการสถานะและการตรวจสอบข้อมูลฟอร์ม
class _SignUpWidget extends StatelessWidget {
  const _SignUpWidget(this.viewmodel);

  @protected
  final AuthenticationViewModel viewmodel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constrainedBox) {
          return Stack(
            children: [
              // Page background gradient
              buildBackground(),

              // AppBar Banner & button back
              buildBanner(context),

              // คำโปรย / TextFormFiled / Social Login
              buildContent(constrainedBox, context),
            ],
          );
        },
      ),
    );
  }

  @protected
  Widget buildContent(BoxConstraints constrainedBox, BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AppContainerRadius(
        // 70% ของหน้าจอ
        height: constrainedBox.maxHeight * 0.70,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDims.size_24.w,
            vertical: AppDims.size_24.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text Title จะแสดงตาม process
                contentTitle(
                  context,
                  wording: context.wording.signUpTitle,
                ),
                // Text Description จะแสดงตาม process
                contentDescription(
                  context,
                  wording: context.wording.signUpDescription,
                ),
                AppDims.vericalPadding_24,

                // สร้าง Form สำหรับกรอกข้อมูล
                contentFormField(
                  context,
                  children: listOfFormAuth(context),
                ),
                AppDims.vericalPadding_10,

                // ปุ่ม summit จะแสดงและมี event ตาม AuthenProcess ที่แตกต่างกัน
                contentButtonSummit(context),
                AppDims.vericalPadding_12,

                // ปุ่มลืมรหัสผ่าน
                contentButtonForgotPassword(context),
                AppDims.vericalPadding_12,

                // Social Login ตัวแบ่งตาม design. เพื่อความสวยงาม
                contentSocialLoginSeparator(context),
                AppDims.vericalPadding_20,

                // Social Login Facebook, google, ...
                contentSocialLogin(),
                AppDims.vericalPadding_20,

                // RichText: ยังไม่มีบัญชีหรอ? สมัครเลย
                contentSignUpCheering(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// DONG 2025-11-18
  ///
  /// ใช้สำหรับสร้าง content ถ้าเป็น [AuthenProcess.login] จะแสดงปุ่ม ลืมรหัสผ่าน
  /// แต่ถ้าเป็น Process อื่น จะไม่แสดง
  @protected
  Widget contentButtonForgotPassword(BuildContext context) {
    return SizedBox();
  }

  /// DONG 2025-11-18
  ///
  /// ใช้สำหรับสร้าง content ถ้าเป็น [AuthenProcess.login] จะแสดงข้อความและปุ่มสำหรับ
  /// สมัครสมาชิกใหม่ กรณีที่ยังไม่เคยใช้งาน
  /// แต่ถ้าเป็น Process อื่น จะไม่แสดง
  @protected
  Widget contentSignUpCheering(BuildContext context) {
    return SizedBox();
  }

  @protected
  Widget contentSocialLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {},
          icon: Assets.png.icFacebook.image(
            width: AppDims.size_26.w,
            height: AppDims.size_26.h,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Assets.png.icGoogle.image(
            width: AppDims.size_26.w,
            height: AppDims.size_26.h,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Assets.png.icApple.image(
            width: AppDims.size_26.w,
            height: AppDims.size_26.h,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Assets.png.icLine.image(
            width: AppDims.size_26.w,
            height: AppDims.size_26.h,
          ),
        ),
      ],
    );
  }

  /// สร้าง Form สำหรับกรอกข้อมูล โดยรับ List ของ Widget (children) ที่จะนำมาแสดงใน Column
  /// ใช้ร่วมกับ viewmodel.formKey เพื่อจัดการการ validate ฟอร์ม
  @protected
  Form contentFormField(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Form(
      key: viewmodel.formKey,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: children,
        ),
      ),
    );
  }

  /// สร้าง List ของ Widget สำหรับใช้ในฟอร์มสมัครสมาชิก/เข้าสู่ระบบ
  /// ประกอบด้วยช่องกรอกอีเมล/เบอร์โทรศัพท์, ช่องกรอกรหัสผ่าน และ Checkbox ยอมรับข้อตกลง
  @protected
  List<Widget> listOfFormAuth(BuildContext context) => [
    // Username input
    textFormFieldEmailOrPhon(context),

    AppDims.vericalPadding_12,

    // Password input
    textFormFieldPasswordWithObscure(),

    // checkbox accept term of policy
    contentCheckboxTermOfPolicy(),
  ];

  /// สร้างช่องกรอกรหัสผ่าน พร้อมปุ่มกดเพื่อแสดง/ซ่อนรหัสผ่าน (Obscure)
  /// ใช้ ValueListenableBuilder เพื่อสลับสถานะการแสดงรหัสผ่าน
  @protected
  ValueListenableBuilder<bool> textFormFieldPasswordWithObscure() {
    return ValueListenableBuilder<bool>(
      valueListenable: viewmodel.isObscure,
      builder: (context, value, _) {
        return TextFormField(
          controller: viewmodel.passwordController,
          textInputAction: TextInputAction.done,
          obscureText: value,
          decoration: InputDecoration(
            hint: Text(
              context.wording.password,
              // ใช้ Default แต่เปลี่ยนสี Text
              style: DefaultTextStyle.of(context).style.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            prefixIcon: SizedBox.shrink(),
            suffixIcon: IconButton(
              onPressed: viewmodel.onObscureChange,
              icon: value
                  ? Assets.svg.icObscureOff.svg(
                      width: AppDims.size_16.w,
                      height: AppDims.size_16.h,
                    )
                  : Assets.svg.icObscureOn.svg(
                      width: AppDims.size_16.w,
                      height: AppDims.size_16.h,
                    ),
            ),
          ),
          validator: (value) => getValidatorPassword(context, value),
          onChanged: (value) {
            viewmodel.validatorPassword(value);
          },
        );
      },
    );
  }

  String? getValidatorPassword(
    BuildContext context,
    String? value,
  ) => viewmodel.validatorPassword(value);

  /// สร้างช่องกรอกอีเมลหรือเบอร์โทรศัพท์
  /// มีการ validate ข้อมูลและเปลี่ยนสีข้อความ hint
  @protected
  TextFormField textFormFieldEmailOrPhon(BuildContext context) {
    return TextFormField(
      controller: viewmodel.usernameController,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hint: AppText(
          context.wording.emailOrPhone,
          // ใช้ Default แต่เปลี่ยนสี Text
          style: DefaultTextStyle.of(context).style.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        prefixIcon: SizedBox.shrink(),
      ),
      autovalidateMode: AutovalidateMode.onUnfocus,
      validator: (value) => getValidatorEmailOrPhone(context, value),
      onChanged: (value) {
        viewmodel.validatorEmailOrPhone(value);
      },
    );
  }

  String? getValidatorEmailOrPhone(
    BuildContext context,
    String? value,
  ) => viewmodel.validatorEmailOrPhone(value);

  /// สร้างแถวที่มีเส้นคั่นแนวนอน ซ้าย-ขวา และข้อความ "สมัครด้วย..." ตรงกลาง
  /// ใช้สำหรับคั่นระหว่างฟอร์มสมัครสมาชิกกับปุ่ม Social Login
  ///
  /// [context] ใช้สำหรับดึงข้อความที่เหมาะสมตามภาษา
  @protected
  Widget contentSocialLoginSeparator(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.productStroke,
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              wordingAlternateAuthen(context),
              style: DefaultTextStyle.of(context).style.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.productStroke,
          ),
        ),
      ],
    );
  }

  /// DONG 2025-11-18
  /// สำหรับสร้าง Wording ขั้นการเข้าสู่ระบบด้วยวิธีอื่นๆ
  ///
  /// - [AuthenProcess.login] เข้าสู่ระบบด้วย
  /// - [AuthenProcess.signup] สมัครด้วย
  /// - [AuthenProcess.forgotPassword] จะไม่แสดง alternate authen
  @protected
  String wordingAlternateAuthen(
    BuildContext context,
  ) => context.wording.signUpWith;

  /// DONG 2025-11-18
  ///
  /// Button สำหรับ Summit Event ในแต่ละ [AuthenProcess]
  ///
  /// - [AuthenProcess.login] จะเป็น Event ของการ เข้าสู่ระบบ
  /// - [AuthenProcess.signup] จะเป็น Event ของการ สมัครสมาชิก
  /// - [AuthenProcess.forgotPassword] จะเป็น Event ของการ ลืมรหัสผ่าน
  @protected
  Widget contentButtonSummit(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: viewmodel.validatorTriggle,
      builder: (context, valid, _) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: valid ? viewmodel.onSignUp : null,
            child: Text(
              context.wording.signUp,
            ),
          ),
        );
      },
    );
  }

  /// Checkbox สำหรับยอมรับข้อตกลงและนโยบายความเป็นส่วนตัว
  /// ใช้ในหน้าสมัครสมาชิกเท่านั้น
  @protected
  Widget contentCheckboxTermOfPolicy() {
    return _CheckBoxTermOfPolicy(
      onChanged: viewmodel.checkboxTermOfPolicyChanged,
    );
  }

  /// สร้าง Title ของเนื้อหา (เช่น "สมัครสมาชิก" หรือ "เข้าสู่ระบบ")
  /// รับข้อความ [wording] เพื่อแสดงผล
  @protected
  Widget contentTitle(
    BuildContext context, {
    required String wording,
  }) {
    return Text(
      wording,
      style: context.textTheme.titleLarge,
    );
  }

  /// สร้าง Description อธิบายรายละเอียดใต้ Title
  /// รับข้อความ [wording] เพื่อแสดงผล
  @protected
  Widget contentDescription(
    BuildContext context, {
    required String wording,
  }) {
    return Text(
      wording,
      style: context.textTheme.bodyMedium!.copyWith(
        // ใช้ bodyMedium แต่เปลี่ยนสี Text
        color: AppColors.textSecondary,
      ),
    );
  }

  /// สร้าง Banner ด้านบนของหน้า พร้อมปุ่มย้อนกลับ (ถ้ามี stack ให้ pop ได้)
  /// และแสดงโลโก้ Browny
  @protected
  Widget buildBanner(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            context.canPop()
                // ถ้ามี stack ให้ pop ได้ จะมีปุ่มกลับ
                ? ElevatedButton.icon(
                    icon: Icon(Icons.arrow_back_ios_new),
                    onPressed: () {
                      // กดกลับออกจากหน้า
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
                    label: Text(context.wording.back),
                    style: AppElevatedButtonStyle.buttomBackStyle,
                  )
                // ไม่มี stack ให้ pop จะไม่มีปุ่มกลับ
                : SizedBox(),
            Center(
              child: Assets.png.brownyHorizaontal.image(
                width: 278.w,
                height: 122.h,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// สร้างพื้นหลังแบบ Gradient สำหรับหน้า Sign Up
  @protected
  Widget buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
    );
  }
}

/// Widget สำหรับหน้าเข้าสู่ระบบ (Login)
///
/// - สืบทอด (_extends_) มาจาก [_SignUpWidget] เพื่อใช้โครงสร้างและ UI หลักร่วมกัน
/// - ปรับเปลี่ยนเฉพาะส่วนที่แตกต่างจากหน้าสมัครสมาชิก เช่น:
///   - เปลี่ยนข้อความ Title/Description ให้เหมาะกับการเข้าสู่ระบบ
///   - เปลี่ยนข้อความของปุ่มและ Separator เป็นของ Login
///   - ไม่แสดง Checkbox สำหรับยอมรับข้อตกลง (contentCheckboxTermOfPolicy)
///   - ปุ่ม Summit จะเรียก Event สำหรับ Login
///
/// ความแตกต่างหลักจาก [_SignUpWidget]:
///   - [_SignUpWidget] จะมี Checkbox สำหรับยอมรับข้อตกลง, ปุ่มและข้อความสำหรับสมัครสมาชิก
///   - [_LoginWidget] จะไม่มี Checkbox, เปลี่ยนข้อความและ Event ให้เหมาะกับการ Login
class _LoginWidget extends _SignUpWidget {
  const _LoginWidget(super.viewmodel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constrainedBox) {
          return Stack(
            children: [
              // พื้นหลังแบบ Gradient (เหมือน SignUp)
              super.buildBackground(),

              // Banner และปุ่มย้อนกลับ (เหมือน SignUp)
              super.buildBanner(context),

              // เนื้อหาหลัก: Title, Description, Form, Social Login
              buildContent(constrainedBox, context),
            ],
          );
        },
      ),
    );
  }

  /// หน้า Login จะเช็คค่า value ว่างกับ Null
  ///
  /// [AuthenProcess.login]
  @override
  String? getValidatorEmailOrPhone(
    BuildContext context,
    String? value,
  ) {
    if (value == null || value.isEmpty) {
      return context.wording.pleaseEnterPassword;
    }
    return null;
  }

  /// หน้า Login จะเช็คค่า value ว่างกับ Null
  ///
  /// [AuthenProcess.login]
  @override
  String? getValidatorPassword(
    BuildContext context,
    String? value,
  ) {
    if (value == null || value.isEmpty) {
      return context.wording.pleaseEnterEmailOrPhone;
    }
    return null;
  }

  /// แสดงปุ่มสำหรับ ลืมรหัสผ่าน
  ///
  /// [AuthenProcess.login]
  @override
  Widget contentSignUpCheering(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: '${context.wording.dontHaveAccountYet} ',
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          children: [
            TextSpan(
              text: context.wording.signUpNow,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  context.pushNamed(
                    AuthenticationPage.pageName,
                    extra: {
                      AuthenProcess: AuthenProcess.signup,
                    },
                  );
                },
            ),
          ],
        ),
      ),
    );
  }

  /// แสดงปุ่มสำหรับ ลืมรหัสผ่าน
  ///
  /// [AuthenProcess.login]
  @override
  Widget contentButtonForgotPassword(BuildContext context) {
    return Center(
      child: TextButton(
        style: context.appTheme.textButtonTheme.style!.copyWith(
          foregroundColor: WidgetStatePropertyAll(
            AppColors.darkBrown,
          ),
          textStyle: WidgetStatePropertyAll(
            AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onPressed: () {},
        child: Text(
          context.wording.forgotPassword,
        ),
      ),
    );
  }

  /// เปลี่ยนข้อความ Separator เป็น "เข้าสู่ระบบด้วย..." (loginWith)
  /// ต่างจาก SignUp ที่ใช้ "สมัครด้วย..."
  ///
  /// [AuthenProcess.login]
  @override
  String wordingAlternateAuthen(BuildContext context) {
    return context.wording.loginWith;
  }

  /// เปลี่ยน Title เป็น "เข้าสู่ระบบ"
  ///
  /// [AuthenProcess.login]
  @override
  Widget contentTitle(
    BuildContext context, {
    required String wording,
  }) {
    return super.contentTitle(
      context,
      wording: context.wording.login,
    );
  }

  /// เปลี่ยน Description เป็นข้อความต้อนรับเข้าสู่ระบบ
  ///
  /// [AuthenProcess.login]
  @override
  Widget contentDescription(
    BuildContext context, {
    required String wording,
  }) {
    return super.contentDescription(
      context,
      wording: context.wording.loginWelcomeDescription,
    );
  }

  /// ไม่แสดง Checkbox สำหรับยอมรับข้อตกลง (ต่างจาก SignUp)
  ///
  /// [AuthenProcess.login]
  @override
  Widget contentCheckboxTermOfPolicy() {
    // หน้า login ไม่ต้องมี Checkbox สำหรับยอมรับเงื่อนไข
    // return ช่องว่างแทน
    return AppDims.vericalPadding_12;
  }

  /// ปุ่ม Summit สำหรับ Login (เปลี่ยนข้อความและ Event)
  /// ต่างจาก SignUp ที่จะเป็นปุ่มสมัครสมาชิก
  ///
  /// [AuthenProcess.login]
  @override
  Widget contentButtonSummit(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          AppOverlays.showLoading(context);
          final result = await viewmodel.onLogin();
          if (!context.mounted) return;

          if (result.hasError) {
            if (result.error is UserNotFound) {
              AppOverlays.showBrownyDialog(
                context,
                message: (result.error as UserNotFound).toUiMessage(context),
                imageAsset: Assets.png.brownyError1.path,
                confirmText: context.wording.tryAgain,
              );
            } else if (result.error is UserUnauthorized) {
              AppOverlays.showBrownyDialog(
                context,
                message: (result.error as UserUnauthorized).toUiMessage(
                  context,
                ),
                imageAsset: Assets.png.brownyError1.path,
                confirmText: context.wording.tryAgain,
              );
            } else {
              AppOverlays.showBrownyDialog(
                context,
                message: 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง',
                imageAsset: Assets.png.brownyError2.path,
                confirmText: context.wording.tryAgain,
              );
            }
          }

          if (result.isSuccess) {
            context.pop();
          }
          AppOverlays.hideLoading();
        },
        child: Text(
          context.wording.login,
        ),
      ),
    );
  }
}

/// Widget สำหรับหน้าลืมรหัสผ่าน (Forgot Password)
///
/// - สืบทอด (_extends_) มาจาก [_SignUpWidget] เพื่อใช้โครงสร้างและ UI หลักร่วมกัน
/// - ปรับเปลี่ยนเฉพาะส่วนที่แตกต่างจากหน้าสมัครสมาชิก เช่น:
///   - เปลี่ยนข้อความ Title/Description ให้เหมาะกับการลืมรหัสผ่าน
///   - เปลี่ยนข้อความของปุ่มเป็น "ถัดไป" (Next)
///   - ไม่แสดง Checkbox สำหรับยอมรับข้อตกลง (contentCheckboxTermOfPolicy)
///   - ไม่แสดง Social Login และ Separator
///   - ฟอร์มจะมีเฉพาะช่องกรอกอีเมล/เบอร์โทรศัพท์เท่านั้น
///
/// ความแตกต่างหลักจาก [_SignUpWidget]:
///   - [_SignUpWidget] จะมี Checkbox สำหรับยอมรับข้อตกลง, ปุ่มและข้อความสำหรับสมัครสมาชิก, Social Login
///   - [_ForgotPasswordWidget] จะไม่มี Checkbox, ไม่มี Social Login, ไม่มี Separator, เปลี่ยนข้อความและ Event ให้เหมาะกับการลืมรหัสผ่าน
class _ForgotPasswordWidget extends _SignUpWidget {
  const _ForgotPasswordWidget(super.viewmodel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constrainedBox) {
          return Stack(
            children: [
              // พื้นหลังแบบ Gradient (เหมือน SignUp)
              super.buildBackground(),

              // Banner และปุ่มย้อนกลับ (เหมือน SignUp)
              super.buildBanner(context),

              // เนื้อหาหลัก: Title, Description, Form (ไม่มี Social Login)
              buildContent(constrainedBox, context),
            ],
          );
        },
      ),
    );
  }

  /// ปุ่ม Summit สำหรับ Forgot Password (เปลี่ยนข้อความและ Event)
  /// ต่างจาก SignUp ที่จะเป็นปุ่มสมัครสมาชิก และ Login ที่จะเป็นปุ่มเข้าสู่ระบบ
  ///
  /// [AuthenProcess.forgotPassword]
  @override
  Widget contentButtonSummit(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: viewmodel.onSignUp,
        child: Text(
          context.wording.next,
        ),
      ),
    );
  }

  /// ไม่แสดง Social Login (ต่างจาก SignUp)
  ///
  /// [AuthenProcess.forgotPassword]
  @override
  Widget contentSocialLogin() => SizedBox();

  /// ไม่แสดง Separator ระหว่างฟอร์มกับ Social Login (ต่างจาก SignUp)
  ///
  /// [AuthenProcess.forgotPassword]
  @override
  Widget contentSocialLoginSeparator(BuildContext context) => SizedBox();

  /// ฟอร์มจะมีเฉพาะช่องกรอกอีเมล/เบอร์โทรศัพท์เท่านั้น (ต่างจาก SignUp ที่มีช่องรหัสผ่านและ Checkbox)
  ///
  /// [AuthenProcess.forgotPassword]
  @override
  List<Widget> listOfFormAuth(BuildContext context) => [
    // ช่องกรอกอีเมลหรือเบอร์โทรศัพท์
    textFormFieldEmailOrPhon(context),
    AppDims.vericalPadding_12,
  ];

  /// ไม่แสดง Checkbox สำหรับยอมรับข้อตกลง (ต่างจาก SignUp)
  ///
  /// [AuthenProcess.forgotPassword]
  @override
  Widget contentCheckboxTermOfPolicy() {
    // หน้า forgot password ไม่ต้องมี Checkbox สำหรับยอมรับเงื่อนไข
    // return ช่องว่างแทน
    return AppDims.vericalPadding_12;
  }

  /// เปลี่ยน Title เป็น "ลืมรหัสผ่านใช่ไหม"
  ///
  /// [AuthenProcess.forgotPassword]
  @override
  Widget contentTitle(
    BuildContext context, {
    required String wording,
  }) {
    return super.contentTitle(
      context,
      wording: context.wording.forgotYourPassword,
    );
  }

  /// เปลี่ยน Description เป็นข้อความอธิบายการลืมรหัสผ่าน
  ///
  /// [AuthenProcess.forgotPassword]
  @override
  Widget contentDescription(
    BuildContext context, {
    required String wording,
  }) {
    return super.contentDescription(
      context,
      wording: context.wording.forgotPasswordDescription,
    );
  }
}

/// Widget นี้เป็น Checkbox สำหรับให้ผู้ใช้ยอมรับข้อตกลงและนโยบายความเป็นส่วนตัว
/// โดยจะแสดงข้อความพร้อมลิงก์ไปยัง "ข้อกำหนดการใช้งานและนโยบายความเป็นส่วนตัว"
/// เมื่อผู้ใช้กดที่ Checkbox จะเรียก callback ที่ส่งค่าการเปลี่ยนแปลง (onChanged)
/// และเมื่อกดที่ข้อความลิงก์จะแสดง SnackBar แจ้งเตือน
/// เหมาะสำหรับใช้ในหน้าลงทะเบียนหรือเข้าสู่ระบบ เพื่อให้ผู้ใช้ยืนยันการยอมรับข้อตกลง
class _CheckBoxTermOfPolicy extends StatefulWidget {
  const _CheckBoxTermOfPolicy({
    required this.onChanged,
  });

  final ValueChanged<bool?> onChanged;
  @override
  State<_CheckBoxTermOfPolicy> createState() => _CheckBoxTermOfPolicyState();
}

class _CheckBoxTermOfPolicyState extends State<_CheckBoxTermOfPolicy> {
  bool _value = false;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: _value,
      titleAlignment: ListTileTitleAlignment.top,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.symmetric(
        vertical: AppDims.size_8.h,
      ),
      onChanged: (_) {
        setState(() {
          _value = !_value;
          widget.onChanged.call(_value);
        });
      },
      title: RichText(
        text: TextSpan(
          text: '${context.wording.iHaveAccepted} ',
          style: context.textTheme.bodySmall!.copyWith(
            color: AppColors.textSecondary,
          ),
          children: [
            TextSpan(
              text: context.wording.termsOfUseAndPrivacyPolicy,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content: Text('tap'),
                    ),
                  );
                },
              style: context.textTheme.bodySmall!.copyWith(
                decoration: TextDecoration.underline,
                color: AppColors.primary,
              ),
            ),
            TextSpan(
              text: ' ${context.wording.ofBrowny24hrWashAndDry}',
              style: context.textTheme.bodySmall!.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
