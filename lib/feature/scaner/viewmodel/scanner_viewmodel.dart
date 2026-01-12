import 'package:browny_applications_new/core/data/remote/models/response/customer_qr_response.dart';
import 'package:browny_applications_new/core/utils/ui_result.dart';
import 'package:browny_applications_new/core/viewmodels/app_viewmodel.dart';
import 'package:browny_applications_new/core/utils/permission_helper.dart';
import 'package:browny_applications_new/feature/authentication/repository/customer_data_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as handler;

class ScannerViewModel extends AppViewModel {
  ScannerViewModel({
    required super.context,
    required CustomerDataSourceMixin repo,
  }) : _repo = repo;

  final CustomerDataSourceMixin _repo;

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
  final ValueNotifier<bool> isScanning = ValueNotifier<bool>(true);

  // Image Picker
  final ImagePicker _imagePicker = ImagePicker();

  /// Initialize camera with permissions
  Future<void> initializeCamera() async {
    try {
      // Request camera permission
      final hasPermission = await PermissionHelper.hasCameraPermission();
      if (!hasPermission) {
        final status = await PermissionHelper.requestCameraPermission();
        if (status != handler.PermissionStatus.granted) {
          // Show error dialog or navigate back
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
      await cameraController.toggleTorch();
      isFlashOn.value = !isFlashOn.value;
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  /// Pick image from gallery and analyze QR code
  Future<void> pickImageAndScan() async {
    try {
      // Request photos permission
      final hasPermission = await PermissionHelper.hasStoragePermission(
        context,
      );
      if (!hasPermission) {
        final status = await PermissionHelper.requestStoragePermission(context);
        if (status != handler.PermissionStatus.granted &&
            status != handler.PermissionStatus.limited) {
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
              const SnackBar(
                content: Text('ไม่พบ QR Code ในรูปภาพ'),
              ),
            );
          }
        } else {
          // Detech
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('detect'),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
          ),
        );
      }
    }
  }

  /// Handle QR code scan result
  void onQRCodeDetected(BarcodeCapture capture) {
    if (!isScanning.value) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        // Stop scanning temporarily
        isScanning.value = false;

        debugPrint('QR Code detected: ${barcode.rawValue}');

        // TODO: Handle the scanned QR code data
        // Navigate to next page or process the data

        // Show result
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Scanned: ${barcode.rawValue}'),
            ),
          );
        }

        // Resume scanning after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          isScanning.value = true;
        });

        break;
      }
    }
  }

  /// Change tab
  void onTabChanged(int index) {
    selectedTab.value = index;
  }

  Future<void> fetchCustomerQRCode() async {
    final result = await _repo.fetchCustomerQR(
      currentCustomerProvider.current.id!,
    );

    if (result.isEmpty || result.hasError) {
      _qrNotifier.value = UiResult.empty();
    }

    _qrNotifier.value = UiResult.success(data: result.data);
  }

  @override
  void dispose() {
    _qrNotifier.dispose();
    cameraController.dispose();
    isFlashOn.dispose();
    selectedTab.dispose();
    isScanning.dispose();
    super.dispose();
  }
}
