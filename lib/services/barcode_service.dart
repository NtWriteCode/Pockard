import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';

class BarcodeResult {
  final String data;
  final String type;

  BarcodeResult({required this.data, required this.type});
}

class BarcodeService {
  static final BarcodeService _instance = BarcodeService._internal();
  factory BarcodeService() => _instance;
  BarcodeService._internal();

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    }

    final result = await Permission.camera.request();
    return result.isGranted;
  }

  Future<BarcodeResult?> scanFromCamera(BuildContext context) async {
    if (!await requestCameraPermission()) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cameraPermissionRequired), backgroundColor: Theme.of(context).colorScheme.error));
      }
      return null;
    }

    if (context.mounted) {
      return Navigator.push<BarcodeResult>(context, MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()));
    }
    return null;
  }

  Future<BarcodeResult?> scanFromImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return null;

      // Use mobile_scanner's built-in analyzeImage method
      final MobileScannerController controller = MobileScannerController();
      final BarcodeCapture? capture = await controller.analyzeImage(image.path);
      await controller.dispose();

      if (capture != null && capture.barcodes.isNotEmpty) {
        final barcode = capture.barcodes.first;
        if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
          return BarcodeResult(data: barcode.rawValue!, type: getBarcodeFormatName(barcode.format));
        }
      }

      // No barcode found in image
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.noBarcodeFoundInImage), backgroundColor: Theme.of(context).colorScheme.surface));
      }
      return null;
    } catch (e) {
      debugPrint('Error scanning image: $e');
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorScanningImage(e.toString())), backgroundColor: Theme.of(context).colorScheme.error));
      }
      return null;
    }
  }

  String getBarcodeFormatName(BarcodeFormat format) {
    final formatName = format.toString().split('.').last.toUpperCase();

    // Map mobile_scanner format names to our standard names
    switch (formatName) {
      case 'QRCODE':
        return 'QR';
      case 'CODE_128':
        return 'CODE128';
      case 'CODE_39':
        return 'CODE39';
      case 'CODE_93':
        return 'CODE93';
      case 'EAN_13':
        return 'EAN13';
      case 'EAN_8':
        return 'EAN8';
      case 'UPC_A':
        return 'UPC_A';
      case 'UPC_E':
        return 'UPC_E';
      case 'DATA_MATRIX':
        return 'DATAMATRIX';
      case 'PDF_417':
        return 'PDF417';
      default:
        return formatName;
    }
  }

  // Deprecated - kept for backward compatibility
  String getBarcodeTypeName(BarcodeType type) {
    return type.toString().split('.').last.toUpperCase();
  }
}

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanned = false;

  Future<void> _scanFromGallery() async {
    final result = await BarcodeService().scanFromImage(context);
    if (result != null && mounted) {
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.scanBarcode),
        backgroundColor: Colors.black.withValues(alpha: 0.7),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => controller.toggleTorch(),
            icon: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, state, child) {
                if (state.torchState == TorchState.off) {
                  return const Icon(Icons.flash_off);
                } else {
                  return const Icon(Icons.flash_on);
                }
              },
            ),
          ),
          IconButton(
            onPressed: () => controller.switchCamera(),
            icon: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, state, child) {
                return const Icon(Icons.camera_rear);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _scanFromGallery, icon: const Icon(Icons.photo_library), label: Text(l10n.scanFromImage)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          // Full screen camera preview
          Positioned.fill(
            child: MobileScanner(
              controller: controller,
              fit: BoxFit.cover,
              onDetect: (BarcodeCapture capture) {
                if (isScanned) return;

                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final barcode = barcodes.first;
                  if (barcode.rawValue != null) {
                    setState(() {
                      isScanned = true;
                    });

                    Navigator.of(context).pop(BarcodeResult(data: barcode.rawValue!, type: BarcodeService().getBarcodeFormatName(barcode.format)));
                  }
                }
              },
            ),
          ),
          // Minimal center focus indicator
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Corner indicators
                  Positioned(
                    top: -1,
                    left: -1,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                          left: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                        ),
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                          right: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                        ),
                        borderRadius: const BorderRadius.only(topRight: Radius.circular(12)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -1,
                    left: -1,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                          left: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                        ),
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -1,
                    right: -1,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                          right: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                        ),
                        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Minimal instructions
          Positioned(
            bottom: 160,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  l10n.centerCodeInFrame,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
