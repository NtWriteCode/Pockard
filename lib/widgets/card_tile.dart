import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../models/card_model.dart';
import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import 'cover_image_widget.dart';

class CardTile extends StatelessWidget {
  final CardModel card;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const CardTile({
    super.key,
    required this.card,
    required this.onTap,
    this.onLongPress,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Cover image or placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: card.coverImagePath != null
                      ? _buildImageWidget(context, card.coverImagePath!)
                      : _buildPlaceholder(context),
                ),
              ),
              const SizedBox(width: 16),
              
              // Card details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            card.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (card.isPinned)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.push_pin,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Tags
                    if (card.tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: card.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    fontSize: 10,
                                  ),
                            ),
                          );
                        }).toList(),
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Usage and date info
                    Row(
                      children: [
                        Icon(
                          Icons.visibility,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${card.usageCount} ${AppLocalizations.of(context)!.uses}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(card.updateDate, context),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    // If card has barcode data, show the barcode/QR code
    if (card.barcodeData?.isNotEmpty == true) {
      return Container(
        color: AppColors.white,
        padding: const EdgeInsets.all(4),
        child: BarcodeWidget(
          barcode: _getBarcodeType(card.barcodeType ?? ''),
          data: card.barcodeData ?? '',
          width: 60,
          height: 60,
          drawText: false,
          color: AppColors.black,
          backgroundColor: AppColors.white,
          errorBuilder: (context, error) => _buildDefaultPlaceholder(context),
        ),
      );
    }
    
    return _buildDefaultPlaceholder(context);
  }

  Widget _buildDefaultPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.credit_card,
        size: 30,
        color: Theme.of(context).colorScheme.onSurface,
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
        return Barcode.qrCode(); // Default to QR code
    }
  }

  String _formatDate(DateTime date, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return l10n.justNow;
        }
        return l10n.minutesAgo(difference.inMinutes);
      }
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }

  Widget _buildImageWidget(BuildContext context, String imagePath) {
    return CoverImageWidget(
      imagePath: imagePath,
      fit: BoxFit.cover,
      borderRadius: 8,
      errorBuilder: (context) => _buildPlaceholder(context),
    );
  }
}
