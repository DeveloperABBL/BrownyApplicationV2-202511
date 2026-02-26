import 'dart:async';

import 'package:browny_applications_new/core/core_index.dart';
import 'package:browny_applications_new/core/data/remote/models/response/customer_qr_response.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/feature/authentication/repository/customer_data_repo.dart';
import 'package:browny_applications_new/feature/transactions/repository/machine_transaction_repo.dart';
import 'package:browny_applications_new/feature/transactions/screens/machines/machine_transaction_page_2.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as handler;

class ScannerViewModel extends AppViewModel {
  ScannerViewModel({
    required super.context,
    required CustomerDataSourceMixin repo,
  }) : _repo = repo;

  final CustomerDataSourceMixin _repo;
  final MachineTransactionDataSourceMixin _machRepo = MachineRepo();

  // ========= valueNotifier, controller =========
  late final ValueNotifier<UiResult<CustomerQRResponse>> _qrNotifier =
      ValueNotifier(
        UiResult.loading(),
      );
  ValueListenable<UiResult<CustomerQRResponse>> get qrNotifier => _qrNotifier;

  // Mobile Scanner Controller
  late MobileScannerController cameraController;

  // Flash state
  final ValueNotifier<bool> isFlashOn = ValueNotifier<bool>(false);

  // Tab state (0 = Scan QR, 1 = Browny ID)
  final ValueNotifier<int> selectedTab = ValueNotifier<int>(0);

  // Scanning state
  bool _isScanning = true;

  // Image Picker
  final ImagePicker _imagePicker = ImagePicker();

  /// Initialize camera with permissions
  Future<void> initializeCamera({
    required VoidCallback onPermissionDenied,
  }) async {
    try {
      // Request camera permission
      final hasPermission = await PermissionHelper.hasCameraPermission();
      if (!hasPermission) {
        final status = await PermissionHelper.requestCameraPermission();
        if (status != handler.PermissionStatus.granted) {
          // Show error dialog or navigate back
          onPermissionDenied.call();
          return;
        }
      }
      await cameraController.start();
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  /// Toggle flash on/off
  Future<void> toggleFlash() async {
    try {
      unawaited(cameraController.toggleTorch());
      isFlashOn.value = !isFlashOn.value;
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  /// Pick image from gallery and analyze QR code
  Future<void> pickImageAndScan() async {
    try {
      // Stop scanning temporarily
      _isScanning = false;

      // Request photos permission
      final hasPermission = await PermissionHelper.hasStoragePermission(
        context,
      );
      if (!context.mounted) return;

      if (!hasPermission) {
        final status = await PermissionHelper.requestStoragePermission(context);
        if (status != handler.PermissionStatus.granted &&
            status != handler.PermissionStatus.limited) {
          _resumeFlagScanning();
          return;
        }
      }

      // Pick image
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        // Analyze image for QR code
        final result = await cameraController.analyzeImage(image.path);
        if (result == null || result.barcodes.isEmpty) {
          // No QR code found in image
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                // ไม่พบ QR Code ในรูปภาพ
                content: AppText(context.wording.qrCodeNotFoundInImage),
              ),
            );
          }
          _resumeFlagScanning();
        } else {
          // Detech
          if (context.mounted) {
            // คืน flag. ทันที เพื่อให้เข้าเงื่อนไขใน onQRCodeDetected
            _isScanning = true;
            onQRCodeDetected(result);
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText(context.wording.errorOccurred),
          ),
        );
        _resumeFlagScanning();
      }
    }
  }

  /// Handle QR code scan result
  void onQRCodeDetected(BarcodeCapture capture) async {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        // Stop scanning temporarily
        _isScanning = false;

        debugPrint('QR Code detected: ${barcode.rawValue}');

        // Navigate to next page or process the data
        if (barcode.rawValue.orEmpty.isEmpty) {
          AppOverlays.showBrownyDialog(
            context,
            title: context.wording.errorOccurred,
            message: context.wording.errorUi,
          );
          return;
        }

        // Show result
        if (context.mounted) {
          try {
            // จะได้เป็น URL มา เอามา parse เป็น URI ไว้เช็คเงื่อนไข
            final uri = Uri.parse(barcode.rawValue!);
            if (uri.pathSegments.isNotEmpty) {
              AppOverlays.showLoading(context);

              final machineResult = await _machRepo.fetchMachineDetail(
                uri.pathSegments.last,
              );
              if (!context.mounted) return;

              AppOverlays.hideLoading();
              if (machineResult.hasError || machineResult.isEmpty) {
                await AppOverlays.showBrownyDialog(
                  context,
                  title: context.wording.errorOccurred,
                  message: context.wording.errorUi,
                  onConfirm: () {
                    if (!context.mounted) return;
                    context.pop();
                    // Resume scanning after 2 seconds
                    _resumeFlagScanning();
                  },
                );
                return;
              }

              final machine = machineResult.data;

              if (machine.isBusy) {
                await AppOverlays.showBrownyDialog(
                  context,
                  // เครื่องกำลังทำงาน
                  title: context.wording.theMachineIsWorking,
                  // กรุณาลองเครื่องอื่น
                  message: context.wording.pleaseTryAnotherMachine,
                  onConfirm: () {
                    if (!context.mounted) return;
                    context.pop();
                    // Resume scanning after 2 seconds
                    _resumeFlagScanning();
                  },
                );
                return;
              }

              if (machine.isTimeOut) {
                await AppOverlays.showBrownyDialog(
                  context,
                  imageAsset: Assets.png.brownyMachineError1.path,
                  // เครื่องไม่สามารถใช้งานได้ในขณะนี้
                  title: context.wording.machineUnavailableAtTheMoment,
                  // กรุณาลองเครื่องอื่น
                  message: context.wording.pleaseTryAnotherMachine,
                  onConfirm: () {
                    if (!context.mounted) return;
                    context.pop();
                    // Resume scanning after 2 seconds
                    _resumeFlagScanning();
                  },
                );
                return;
              }

              MachineTransactionPage2.goReplacementPage(
                context,
                machineId: uri.pathSegments.last,
              );
              return;
            }
          } catch (_) {}

          // Failed all case
          AppOverlays.showBrownyDialog(
            context,
            title: context.wording.errorOccurred,
            message: context.wording.errorUi,
          );
        }

        // Resume scanning after 2 seconds
        _resumeFlagScanning();

        break;
      }
    }
  }

  /// Resume scanning after 2 seconds
  void _resumeFlagScanning() {
    Future.delayed(const Duration(seconds: 2), () {
      _isScanning = true;
    });
  }

  /// Change tab
  Future<void> onTabChanged(int index) async {
    selectedTab.value = index;
    if (index == 1) {
      await cameraController.pause();
    } else if (!cameraController.value.isRunning) {
      await cameraController.start();
    }
  }

  Future<void> fetchCustomerQRCode() async {
    final result = await _repo.fetchCustomerQR(
      currentCustomerProvider.current.id!,
    );

    if (result.isEmpty || result.hasError) {
      _qrNotifier.value = UiResult.empty();
      return;
    }

    _qrNotifier.value = UiResult.success(data: result.data);
  }

  @override
  void dispose() {
    _isScanning = false;
    _qrNotifier.dispose();
    // cameraController.dispose(); ไป dispose จาก Widget
    isFlashOn.dispose();
    selectedTab.dispose();
    super.dispose();
  }
}
