import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_service.dart';
import '../screens/image_generator_screen.dart';
import '../screens/logo_search_screen.dart';
import '../l10n/app_localizations.dart';
import 'global_image_picker.dart';

/// A self-contained widget for IMAGE_ONLY barcode mode.
///
/// Displays the current barcode image (or cover image fallback), and provides
/// picker options (camera, gallery, AI generate, logo search, global images)
/// via a bottom sheet.
class BarcodeImageUploadSection extends StatelessWidget {
  /// The dedicated barcode image path, if one has been set.
  final String? barcodeImagePath;

  /// The cover image path, used as a fallback display when no dedicated
  /// barcode image is set.
  final String? coverImagePath;

  /// Called when the barcode image changes. Pass the new path, or null to
  /// remove the dedicated barcode image.
  final ValueChanged<String?> onBarcodeImageChanged;

  const BarcodeImageUploadSection({
    super.key,
    this.barcodeImagePath,
    this.coverImagePath,
    required this.onBarcodeImageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayImagePath = barcodeImagePath ?? coverImagePath;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.barcodePreview,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showPickerOptions(context),
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: displayImagePath != null
                  ? Colors.transparent
                  : Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
              ),
            ),
            child: displayImagePath != null
                ? _buildImageStack(context, displayImagePath, l10n)
                : _buildPlaceholder(context, l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildImageStack(
    BuildContext context,
    String displayImagePath,
    AppLocalizations l10n,
  ) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(displayImagePath),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
        if (barcodeImagePath != null)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.selectBarcodeImage,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (barcodeImagePath != null)
          Positioned(
            bottom: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => onBarcodeImageChanged(null),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tapToUploadBarcodeImage,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          if (coverImagePath != null) ...[
            const SizedBox(height: 8),
            Text(
              '(Cover image will be used)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Picker options
  // ---------------------------------------------------------------------------

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext dialogContext) {
        final dialogL10n = AppLocalizations.of(dialogContext)!;
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(dialogL10n.camera),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _pickAndEditImage(context, true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(dialogL10n.gallery),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _pickAndEditImage(context, false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: Text(dialogL10n.generateImage),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _generateImage(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: Text(dialogL10n.searchLogo),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _searchLogo(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cloud),
                title: Text(dialogL10n.globalImages),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _pickGlobalImage(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndEditImage(BuildContext context, bool fromCamera) async {
    try {
      final imageService = ImageService();
      final imagePath = await imageService.pickEditAndSaveImage(
        context: context,
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );

      if (imagePath != null && context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        onBarcodeImageChanged(imagePath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.barcodeImageUploaded),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _generateImage(BuildContext context) async {
    if (!context.mounted) return;

    final generatedImagePath = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const ImageGeneratorScreen()),
    );

    if (generatedImagePath != null && context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      onBarcodeImageChanged(generatedImagePath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.barcodeImageUploaded),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  Future<void> _searchLogo(BuildContext context) async {
    if (!context.mounted) return;

    final selectedImagePath = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => LogoSearchScreen(
          onLogoSelected: (imagePath) {
            Navigator.pop(context, imagePath);
          },
        ),
      ),
    );

    if (selectedImagePath != null && context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      onBarcodeImageChanged(selectedImagePath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.barcodeImageUploaded),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  Future<void> _pickGlobalImage(BuildContext context) async {
    if (!context.mounted) return;

    final selectedImage = await showDialog<String>(
      context: context,
      builder: (context) => const GlobalImagePicker(),
    );

    if (selectedImage != null && context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      onBarcodeImageChanged(selectedImage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.barcodeImageUploaded),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }
}
