import 'package:browny_applications_new/feature/authentication/repository/pin_biometric_repository.dart';
import 'package:flutter/material.dart';

/// ViewModel สำหรับจัดการ PIN
/// - สร้าง PIN ใหม่
/// - ตรวจสอบ PIN
/// - จัดการ State ของหน้า Create PIN
class PinBiometricViewModel extends ChangeNotifier {
  final PinBioMetricRepository _repository;

  PinBiometricViewModel({
    required PinBioMetricRepository repository,
  }) : _repository = repository;

  // ========== State Variables ==========

  /// PIN ที่ผู้ใช้กรอก (ขั้นตอนที่ 1)
  String _pin = '';
  String get pin => _pin;

  /// PIN ที่ผู้ใช้กรอกซ้ำเพื่อยืนยัน (ขั้นตอนที่ 2)
  String _confirmPin = '';
  String get confirmPin => _confirmPin;

  /// สถานะการทำงาน
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// ข้อผิดพลาด (ถ้ามี)
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// ขั้นตอนการสร้าง PIN
  /// - 1: กรอก PIN ครั้งแรก
  /// - 2: ยืนยัน PIN อีกครั้ง
  int _step = 1;
  int get step => _step;

  // ========== Constants ==========

  static const int pinLength = 6;

  // ========== Methods ==========

  /// เพิ่มตัวเลขเข้า PIN
  void addDigit(String digit) {
    if (_step == 1) {
      // ขั้นตอนที่ 1: กรอก PIN
      if (_pin.length < pinLength) {
        _pin += digit;
        _errorMessage = null;
        notifyListeners();

        // ถ้ากรอกครบ 6 หลัก → ไปขั้นตอนที่ 2
        if (_pin.length == pinLength) {
          _goToConfirmStep();
        }
      }
    } else {
      // ขั้นตอนที่ 2: ยืนยัน PIN
      if (_confirmPin.length < pinLength) {
        _confirmPin += digit;
        _errorMessage = null;
        notifyListeners();

        // ถ้ากรอกครบ 6 หลัก → ตรวจสอบความตรงกัน
        if (_confirmPin.length == pinLength) {
          _validateAndSavePin();
        }
      }
    }
  }

  /// ลบตัวเลขสุดท้าย
  void removeDigit() {
    if (_step == 1) {
      if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMessage = null;
        notifyListeners();
      }
    } else {
      if (_confirmPin.isNotEmpty) {
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        _errorMessage = null;
        notifyListeners();
      }
    }
  }

  /// ไปขั้นตอนยืนยัน PIN
  void _goToConfirmStep() {
    Future.delayed(Duration(milliseconds: 300), () {
      _step = 2;
      _confirmPin = '';
      _errorMessage = null;
      notifyListeners();
    });
  }

  /// ตรวจสอบความตรงกันและบันทึก PIN
  Future<void> _validateAndSavePin() async {
    if (_pin != _confirmPin) {
      // PIN ไม่ตรงกัน → กลับไปขั้นตอนที่ 1
      await Future.delayed(Duration(milliseconds: 300));
      _errorMessage = 'PIN ไม่ตรงกัน กรุณาลองใหม่';
      _step = 1;
      _pin = '';
      _confirmPin = '';
      notifyListeners();
      return;
    }

    // PIN ตรงกัน → บันทึก
    await _savePinToRepository();
  }

  /// บันทึก PIN ลง Repository
  Future<bool> _savePinToRepository() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.savePin(_pin);

      _isLoading = false;

      if (result.isSuccess) {
        // บันทึกสำเร็จ
        notifyListeners();
        return true;
      } else {
        // บันทึกไม่สำเร็จ
        _errorMessage = result.error.toString();
        _step = 1;
        _pin = '';
        _confirmPin = '';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      _step = 1;
      _pin = '';
      _confirmPin = '';
      notifyListeners();
      return false;
    }
  }

  /// ตรวจสอบ PIN
  /// - ใช้เมื่อผู้ใช้กรอก PIN เพื่อเข้าแอป
  Future<bool> verifyPin(String pin) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.verifyPin(pin);

      _isLoading = false;

      if (result.isSuccess && result.data == true) {
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'PIN ไม่ถูกต้อง';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// ตรวจสอบว่ามี PIN หรือยัง
  Future<bool> hasPin() async {
    try {
      final result = await _repository.hasPin();
      if (result.isSuccess) {
        return result.data;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Reset state (กลับไปขั้นตอนที่ 1)
  void reset() {
    _step = 1;
    _pin = '';
    _confirmPin = '';
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// เปิดใช้งาน Biometric
  Future<bool> setBiometricEnabled(bool enabled) async {
    try {
      final result = await _repository.setBiometricEnabled(enabled);
      if (result.isSuccess) {
        return result.data;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// ตรวจสอบว่าเปิดใช้งาน Biometric หรือไม่
  Future<bool> isBiometricEnabled() async {
    try {
      final result = await _repository.isBiometricEnabled();
      if (result.isSuccess) {
        return result.data;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
