import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_service.dart';
import '../screens/image_generator_screen.dart';
import '../screens/logo_search_screen.dart';
import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import 'global_image_picker.dart';
import 'cover_image_widget.dart';

/// A reusable widget for handling card cover images
class CardImageSection extends StatelessWidget {
  final String? coverImagePath;
  final ValueChanged<String>? onImagePicked;
  final VoidCallback? onImageRemoved;
  final VoidCallback? onImageSharedGlobally;
  final bool showGlobalOptions;

  const CardImageSection({super.key, this.coverImagePath, this.onImagePicked, this.onImageRemoved, this.onImageSharedGlobally, this.showGlobalOptions = true});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.coverImageLabel, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Center(child: coverImagePath != null ? _buildDynamicImagePreview(context) : _buildStaticPlaceholder(context)),
        const SizedBox(height: 8),
        _buildImageActions(context),
      ],
    );
  }

  Widget _buildDynamicImagePreview(BuildContext context) {
    return FutureBuilder<Size>(
      future: _getImageSize(coverImagePath!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // While loading, show fixed size container
          return _buildStaticPlaceholder(context);
        }

        final imageSize = snapshot.data!;
        final aspectRatio = imageSize.width / imageSize.height;

        // Max height is 200, min width is 200
        const double maxHeight = 200;
        const double minWidth = 200;
        const double maxWidth = 300; // Don't go too wide

        double width;
        double height;

        if (aspectRatio > 1) {
          // Wider than tall - constrain height, expand width
          height = maxHeight;
          width = height * aspectRatio;
          width = width.clamp(minWidth, maxWidth);
        } else {
          // Taller than wide or square - constrain to square or make narrower
          height = maxHeight;
          width = height * aspectRatio;
          width = width.clamp(minWidth * 0.7, minWidth); // Allow narrower for portrait
        }

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _buildImagePreview(context),
        );
      },
    );
  }

  Widget _buildStaticPlaceholder(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _buildImagePlaceholder(context),
      ),
    );
  }

  Future<Size> _getImageSize(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final image = await decodeImageFromList(bytes);
      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      // If we can't get size, return square default
      return const Size(200, 200);
    }
  }

  Widget _buildImagePreview(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullscreenPreview(context),
      child: Stack(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(7), child: _buildImageWidget(context, coverImagePath!)),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(color: AppColors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(4)),
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.white, size: 18),
                onPressed: onImageRemoved,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullscreenPreview(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => _FullscreenImagePreview(imagePath: coverImagePath!)));
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return InkWell(
      onTap: () => _showImagePickerOptions(context),
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 48, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.tapToAddCoverImage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageActions(BuildContext context) {
    if (coverImagePath == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 8,
      children: [
        TextButton.icon(onPressed: () => _showImagePickerOptions(context), icon: const Icon(Icons.edit, size: 16), label: Text(l10n.changeImage)),
        if (showGlobalOptions) TextButton.icon(onPressed: onImageSharedGlobally, icon: const Icon(Icons.cloud_upload, size: 16), label: Text(l10n.shareGlobally)),
        TextButton.icon(
          onPressed: onImageRemoved,
          icon: const Icon(Icons.delete, size: 16),
          label: Text(l10n.removeImage),
          style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
        ),
      ],
    );
  }

  void _showImagePickerOptions(BuildContext context) {
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
              if (showGlobalOptions)
                ListTile(
                  leading: const Icon(Icons.cloud),
                  title: Text(dialogL10n.globalImages),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _pickGlobalImage(context);
                  },
                ),
              if (coverImagePath != null)
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text(dialogL10n.editCard),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _editCurrentImage(context);
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
      final ImageService imageService = ImageService();
      final imagePath = await imageService.pickEditAndSaveImage(context: context, source: fromCamera ? ImageSource.camera : ImageSource.gallery);

      if (imagePath != null && onImagePicked != null) {
        onImagePicked!(imagePath);
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorPickingImage(e.toString()))));
      }
    }
  }

  Future<void> _editCurrentImage(BuildContext context) async {
    if (coverImagePath == null) return;

    try {
      final ImageService imageService = ImageService();
      final editedPath = await imageService.editExistingImage(coverImagePath!, context);

      if (editedPath != null && onImagePicked != null) {
        onImagePicked!(editedPath);
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorEditingImage(e.toString()))));
      }
    }
  }

  Future<void> _pickGlobalImage(BuildContext context) async {
    if (!context.mounted) return;

    final selectedImage = await showDialog<String>(context: context, builder: (context) => const GlobalImagePicker());

    if (selectedImage != null && onImagePicked != null) {
      onImagePicked!(selectedImage);
    }
  }

  Future<void> _generateImage(BuildContext context) async {
    if (!context.mounted) return;

    final generatedImagePath = await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => const ImageGeneratorScreen()));

    if (generatedImagePath != null && onImagePicked != null) {
      onImagePicked!(generatedImagePath);
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

    if (selectedImagePath != null && onImagePicked != null) {
      onImagePicked!(selectedImagePath);
    }
  }

  Widget _buildImageWidget(BuildContext context, String imagePath) {
    return CoverImageWidget(
      imagePath: imagePath,
      fit: BoxFit.contain,
      borderRadius: 7,
      placeholderBuilder: (context) => Container(
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorBuilder: (context) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.error, color: Colors.red),
      ),
    );
  }
}

// Simple fullscreen image preview
class _FullscreenImagePreview extends StatelessWidget {
  final String imagePath;

  const _FullscreenImagePreview({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black.withValues(alpha: 0.7), foregroundColor: Colors.white, elevation: 0),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: CoverImageWidget(imagePath: imagePath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
