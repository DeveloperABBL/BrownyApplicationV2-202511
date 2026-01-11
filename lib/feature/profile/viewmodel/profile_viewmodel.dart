import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:browny_applications_new/core/data/remote/models/request/update_profile_request.dart';
import 'package:browny_applications_new/res/strings/app_strings.dart';
import 'package:browny_applications_new/core/utils/app_extensions.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/profile/repository/profile_repo.dart';
import 'package:browny_applications_new/models/avatar_data.dart';
import 'package:browny_applications_new/models/user_model.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileViewModel extends AppViewModelFormFieldValidation {
  ProfileViewModel({
    required super.context,
    required this.repo,
  });

  final ProfileRepo repo;

  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController dateOfBirth = TextEditingController();
  late final CarouselSliderController carouselController =
      CarouselSliderController();

  late final UnmodifiableListView<UnmodifiableMapView<String, String>> genders =
      UnmodifiableListView(
        repo.genders.mapIndex((index, e) {
          switch (index) {
            case 1:
              // เพศชาย
              return UnmodifiableMapView({
                e: context.wording.male,
              });
            case 2:
              // เพศหญิง
              return UnmodifiableMapView({
                e: context.wording.female,
              });
            default:
              // ไม่ระบุ
              return UnmodifiableMapView({
                e: context.wording.genderNotSpecified,
              });
          }
        }),
      );

  late final ValueNotifier<int> _currentSliderIndexNotifier = ValueNotifier(0);
  ValueListenable<int> get currentSliderIndexNotifier =>
      _currentSliderIndexNotifier;
  int get currentAvatarIndex => _currentSliderIndexNotifier.value;
  set updateIndex(int value) {
    _currentSliderIndexNotifier.value = value;
  }

  final ValueNotifier<UiResult<UserModel>> _profileDataNotifier = ValueNotifier(
    UiResult.loading(),
  );
  ValueListenable<UiResult<UserModel>> get profileData => _profileDataNotifier;

  // Image Picker
  final ImagePicker _imagePicker = ImagePicker();

  /// หา index ของ avatar ท้ ตรงกับ imageUrl จาก avatarDataList
  /// จะข้าม picked image เพราะเป็น file ไม่ใช่ URL
  int _findAvatarIndex(String imageUrl, List<AvatarData> avatarDataList) {
    if (imageUrl.isEmpty || avatarDataList.isEmpty) return 0;

    // หาใน avatarDataList ที่ URL ตรงกับ imageUrl
    final index = avatarDataList.indexWhere(
      (avatar) => avatar.isFromUrl && avatar.url == imageUrl,
    );

    return index != -1 ? index : 0;
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        // Set/Replace picked image ใน avatarDataList (จะอยู่ที่ index 0 เสมอ)
        final updatedUser = _profileDataNotifier.value.data!.setPickedAvatar(
          image,
        );
        _profileDataNotifier.value = UiResult.success(data: updatedUser);
        scheduleMicrotask(() {
          // Reset index ไปที่ 0 เพื่อแสดงรูปที่ pick มาใหม่
          carouselController.animateToPage(
            0,
            duration: Duration(milliseconds: 1_000),
            curve: Curves.easeOut,
          );
        });
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      rethrow;
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );
      if (image != null) {
        // Set/Replace picked image ใน avatarDataList (จะอยู่ที่ index 0 เสมอ)
        final updatedUser = _profileDataNotifier.value.data!.setPickedAvatar(
          image,
        );
        _profileDataNotifier.value = UiResult.success(data: updatedUser);
        scheduleMicrotask(() {
          // Reset index ไปที่ 0 เพื่อแสดงรูปที่ pick มาใหม่
          carouselController.animateToPage(
            0,
            duration: Duration(milliseconds: 1_000),
            curve: Curves.easeOut,
          );
        });
      }
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      rethrow;
    }
  }

  Future<void> fetchProfileData() async {
    final profileResult = await repo.fetchProfile('');
    if (profileResult.isEmpty) {
      if (profileResult.hasError) {
        _profileDataNotifier.value = UiResult.empty(
          error: profileResult.error,
        );
      } else {
        _profileDataNotifier.value = UiResult.empty();
      }
      return;
    }

    if (profileResult.hasError) {
      _profileDataNotifier.value = UiResult.error(error: profileResult.error);
      return;
    }

    final userModel = UserModel.fromCustomerProfileData(
      profileResult.data.data,
    );
    // fetch กลับเก็บค่าใหม่ที่ provider ด้วย
    currentCustomerProvider.newUser = userModel;

    // หา index ของรูป profile ที่เลือกไว้ (จาก avatarDataList)
    final currentImageUrl = _profileDataNotifier.value.data == null
        ? userModel.image.orEmpty
        : _profileDataNotifier.value.data!.image.orEmpty;

    final mFindIndexAvatar = _findAvatarIndex(
      currentImageUrl,
      userModel.avatarDataList,
    );

    // update Avatar index เพื่อให้แสดงรูปที่เลือกไว้
    updateIndex = mFindIndexAvatar;
    // updaet Email ที่ fetch มา
    emailController.text = userModel.email.orEmpty;
    // updaet name ที่ fetch มา
    nameController.text = userModel.name.orEmpty;
    // update Gender ที่ fetch มา
    genderController.text = userModel.gender.ifNullOrEmpty(
      genders.first.keys.first,
    );
    // update Birthday ที่ fetch มา
    try {
      dateOfBirth.text = DateTime.parse(
        userModel.birthday.orEmpty,
      ).formatForShow();
    } on Exception catch (e) {
      dateOfBirth.text = '';
    }

    _profileDataNotifier.value = UiResult.success(
      data: userModel,
    );
  }

  void onPhoneUpdate(String phone) {
    _profileDataNotifier.value = UiResult.success(
      data: _profileDataNotifier.value.data!.copyWith(
        phone: phone,
      ),
    );
  }

  void onBirthDayUpdate(DateTime pickedDate) {
    // เอาเข้า format สำหรับแสดงหน้า UI
    String formattedDateShow = pickedDate.formatForShow();
    dateOfBirth.text = formattedDateShow;

    // เอาเข้า format สำหรับส่งกลับหลังบ้านผ่าน API
    String formattedDateForSend = pickedDate.formatForAPI();
    _profileDataNotifier.value = UiResult.success(
      data: _profileDataNotifier.value.data!.copyWith(
        birthday: formattedDateForSend,
      ),
    );
  }

  /// DONG 2026-01-06
  ///
  /// บันทึกข้อมูล Profile
  /// เมื่อ success จะ update ข้อมูลใน LocalStorage และ CustomerProvider
  Future<UiResult<UserModel>> onSaveProfile() async {
    if (formKey.currentState?.validate() != true) {
      return UiResult.empty();
    }

    final currentUser = _profileDataNotifier.value.data;
    if (currentUser == null) {
      return UiResult.error(
        error: Exception('No user data available'),
      );
    }

    // ดึงข้อมูลรูปจาก index ปัจจุบันที่เลือกอยู่
    AvatarData avatarData = currentUser.avatarDataList[currentAvatarIndex];

    // - ถ้าเป็น index = 0 มีโอกาสที่จะเป็นการเพิ่มรูปใหม่
    // - ถ้าเป็น isFromPicker จะแสดงว่าเลือกรูปหรือถ่ายใหม่มา
    String? profileImage64Update =
        (currentAvatarIndex == 0 && avatarData.isFromPicker)
        // เอารูปมาแปลงเป็น Base64 ก่อนจะส่ง
        ? base64Encode(File(avatarData.path).readAsBytesSync())
        : null;

    // - ถ้า profileImage64Update = null มีโอกาสที่จะเลือกรูปที่มีให้
    // - ถ้า currentAvatarIndex != 0 แสดงว่าเลือกรูปที่มีให้และไม่ใช่ที่ default จะการ fetch
    String? profileImageUrlUpdate =
        (profileImage64Update == null && currentAvatarIndex != 0)
        // ส่ง path url กลับไป
        ? avatarData.path
        : null;

    // สร้าง request body
    final request = UpdateProfileRequest(
      id: currentUser.id ?? '',
      name: nameController.text.trim().isEmpty
          ? null
          : nameController.text.trim(),
      gender: genderController.text.trim().isEmpty
          ? null
          : genderController.text.trim(),
      birthdate: currentUser.birthday?.trim().isEmpty == true
          ? null
          : currentUser.birthday,
      profileImageBase64: profileImage64Update,
      profileImageUrl: profileImageUrlUpdate,
      email: emailController.text,
      phone: phoneController.text,
    );

    try {
      final result = await repo.updateProfile(request);

      if (result.isSuccess && result.data.success) {
        final fetchProfileResult = await repo.fetchProfile(
          result.data.data.id!,
        );
        if (fetchProfileResult.isEmpty && fetchProfileResult.hasError) {
          return UiResult.empty(error: fetchProfileResult.error);
        }
        if (fetchProfileResult.hasError) {
          return UiResult.error(error: fetchProfileResult.error);
        }

        // สร้าง UserModel จาก response
        final updatedUser = UserModel.fromCustomerProfileData(
          fetchProfileResult.data.data,
        );

        // Update CustomerProvider
        currentCustomerProvider.newUser = updatedUser;

        // Update ViewModel state
        _profileDataNotifier.value = UiResult.success(data: updatedUser);

        return UiResult.success(data: updatedUser);
      }

      return UiResult.error(
        error: Exception(result.error.toString()),
      );
    } catch (e) {
      return UiResult.error(error: Exception(e.toString()));
    }
  }

  FutureOr<UiResult<UserModel>> logout() async {
    final logoutResult = await repo.logout();

    if (!context.mounted) return UiResult.empty();

    if (logoutResult.isSuccess) {
      return UiResult.success(
        data: currentCustomerProvider.logout(),
      );
    }

    return UiResult.error(error: logoutResult.error);
  }

  // ============ dispose ============
  @override
  void dispose() {
    _currentSliderIndexNotifier.dispose();
    _profileDataNotifier.dispose();
    phoneController.dispose();
    emailController.dispose();
    nameController.dispose();
    genderController.dispose();
    dateOfBirth.dispose();
    super.dispose();
  }
}
