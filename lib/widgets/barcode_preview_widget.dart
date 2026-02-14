import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';

/// A widget that displays a preview of the barcode based on the data and type
class BarcodePreviewWidget extends StatelessWidget {
  final String barcodeData;
  final String barcodeType;

  const BarcodePreviewWidget({super.key, required this.barcodeData, required this.barcodeType});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Hide preview if "Image Only" is selected (handled separately)
    if (barcodeType == 'IMAGE_ONLY') {
      return const SizedBox.shrink();
    }

    // If barcode data is empty, show a hint
    if (barcodeData.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.barcodePreview, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 100,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3), style: BorderStyle.solid),
            ),
            child: Center(
              child: Text(
                l10n.barcodePreviewHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.barcodePreview, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 100,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: _buildBarcodeWidget(context),
        ),
      ],
    );
  }

  Widget _buildBarcodeWidget(BuildContext context) {
    // Handle TEXT mode - just show the text
    if (barcodeType == 'TEXT') {
      return Center(
        child: SingleChildScrollView(
          child: Text(
            barcodeData,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.black),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Handle barcode generation
    try {
      return BarcodeWidget(
        barcode: _getBarcodeType(barcodeType),
        data: barcodeData,
        width: double.infinity,
        height: double.infinity,
        drawText: false,
        color: AppColors.black,
        backgroundColor: AppColors.white,
      );
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 4),
            Text(l10n.invalidBarcodeDataPreview, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
          ],
        ),
      );
    }
  }

  Barcode _getBarcodeType(String type) {
    switch (type) {
      case 'QR':
        return Barcode.qrCode();
      case 'CODE128':
        return Barcode.code128();
      case 'CODE39':
        return Barcode.code39();
      case 'CODE93':
        return Barcode.code93();
      case 'EAN13':
        return Barcode.ean13();
      case 'EAN8':
        return Barcode.ean8();
      case 'UPC_A':
        return Barcode.upcA();
      case 'UPC_E':
        return Barcode.upcE();
      case 'CODABAR':
        return Barcode.codabar();
      case 'ITF':
        return Barcode.itf();
      case 'PDF417':
        return Barcode.pdf417();
      case 'DATAMATRIX':
        return Barcode.dataMatrix();
      case 'AZTEC':
        return Barcode.aztec();
      default:
        return Barcode.qrCode();
    }
  }
}
