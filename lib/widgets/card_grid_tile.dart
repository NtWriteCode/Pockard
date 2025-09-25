import 'dart:io';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../models/card_model.dart';
import '../constants/app_colors.dart';
import 'cover_image_widget.dart';

class CardGridTile extends StatelessWidget {
  final CardModel card;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool showName;

  const CardGridTile({
    super.key,
    required this.card,
    required this.onTap,
    this.onLongPress,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Don't override elevation - let theme handle it
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image/Barcode section (1:1 aspect ratio)
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.0, // Enforce square 1:1 ratio
                child: ClipRRect(
                  // If name is hidden, round all corners; otherwise only round top
                  borderRadius: showName 
                      ? const BorderRadius.vertical(top: Radius.circular(12))
                      : BorderRadius.circular(12),
                  child: _buildImageSection(context),
                ),
              ),
            ),
            
            // Card name section (conditionally shown)
            if (showName)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (card.isPinned)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.push_pin,
                            size: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      Flexible(
                        child: Text(
                          card.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    // Show cover image if available
    if (card.coverImagePath?.isNotEmpty == true) {
      final file = File(card.coverImagePath!);
      if (file.existsSync()) {
        return _buildImageWidget(context, card.coverImagePath!);
      }
    }
    
    // Show barcode/QR code if no cover image
    if (card.barcodeData?.isNotEmpty == true) {
      return _buildBarcodeSection(context);
    }
    
    // Fallback to default placeholder
    return _buildDefaultPlaceholder(context);
  }

  Widget _buildBarcodeSection(BuildContext context) {
    return Container(
      color: AppColors.white, // Always white background for barcode visibility
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Reduced padding for grid
          child: BarcodeWidget(
            barcode: _getBarcodeType(card.barcodeType ?? 'QR'),
            data: card.barcodeData ?? '',
            width: double.infinity,
            height: double.infinity,
            drawText: false,
            color: AppColors.black, // Always black barcode for contrast
            backgroundColor: AppColors.white, // Always white background
            errorBuilder: (context, error) => _buildDefaultPlaceholder(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Icon(
        Icons.credit_card,
        size: 32,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
      ),
    );
  }

  Barcode _getBarcodeType(String type) {
    switch (type.toLowerCase()) {
      case 'qr':
      case 'qrcode':
        return Barcode.qrCode();
      case 'code128':
        return Barcode.code128();
      case 'code39':
        return Barcode.code39();
      case 'code93':
        return Barcode.code93();
      case 'ean13':
        return Barcode.ean13();
      case 'ean8':
        return Barcode.ean8();
      case 'upc_a':
        return Barcode.upcA();
      case 'upc_e':
        return Barcode.upcE();
      case 'codabar':
        return Barcode.codabar();
      case 'itf':
        return Barcode.itf();
      case 'pdf417':
        return Barcode.pdf417();
      case 'datamatrix':
        return Barcode.dataMatrix();
      case 'aztec':
        return Barcode.aztec();
      default:
        return Barcode.qrCode();
    }
  }

  Widget _buildImageWidget(BuildContext context, String imagePath) {
    return CoverImageWidget(
      imagePath: imagePath,
      fit: BoxFit.cover,
      borderRadius: 12,
      errorBuilder: (context) => _buildBarcodeSection(context),
    );
  }
}
