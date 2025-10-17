import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/card_model.dart';
import '../providers/card_provider.dart';
import '../providers/tag_provider.dart';
import '../services/barcode_service.dart';
import '../services/database_service.dart';
import '../services/global_data_service.dart';
import '../services/image_service.dart';
import '../services/sync_settings_service.dart';
import '../widgets/barcode_type_selector.dart';
import '../widgets/barcode_preview_widget.dart';
import '../widgets/card_image_section.dart';
import '../widgets/dynamic_tag_input.dart';
import '../constants/barcode_types.dart';
import '../l10n/app_localizations.dart';

/// Unified screen for adding and editing loyalty cards
class CardFormScreen extends StatefulWidget {
  final CardModel? card; // null for adding, non-null for editing
  final bool autoStartCamera;

  const CardFormScreen({super.key, this.card, this.autoStartCamera = false});

  bool get isEditing => card != null;

  @override
  State<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends State<CardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _barcodeDataController;
  List<String> _tags = [];
  List<String> _availableTags = [];

  final BarcodeService _barcodeService = BarcodeService();
  final DatabaseService _databaseService = DatabaseService();
  final ImageService _imageService = ImageService();

  String? _coverImagePath;
  String? _barcodeImagePath;
  String _barcodeType = 'QR';
  bool _isLoading = false;
  bool _isPinned = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadAvailableTags();

    // Auto-start camera if requested and we're adding a new card
    if (widget.autoStartCamera && !widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scanBarcode();
      });
    }
  }

  void _initializeControllers() {
    if (widget.isEditing) {
      // Initialize with existing card data
      _nameController = TextEditingController(text: widget.card!.name);
      _barcodeDataController = TextEditingController(text: widget.card!.barcodeData ?? '');
      _tags = List.from(widget.card!.tags);
      _coverImagePath = widget.card!.coverImagePath;
      _barcodeImagePath = widget.card!.barcodeImagePath;
      _barcodeType = widget.card!.barcodeType ?? 'QR';
      _isPinned = widget.card!.isPinned;
    } else {
      // Initialize empty for new card
      _nameController = TextEditingController();
      _barcodeDataController = TextEditingController();
      _tags = [];
    }
  }

  Future<void> _loadAvailableTags() async {
    final tags = await _databaseService.getAllTags();
    setState(() {
      _availableTags = tags;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeDataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? l10n.editCard : l10n.addCard),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Show pin, share and delete buttons only when editing an existing card
          if (widget.isEditing) ...[
            IconButton(
              icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
              onPressed: _isLoading ? null : _togglePin,
              tooltip: _isPinned ? l10n.unpinCard : l10n.pinCard,
            ),
            IconButton(icon: const Icon(Icons.public), onPressed: _isLoading ? null : _shareCardGlobally, tooltip: l10n.shareGlobally),
            IconButton(icon: const Icon(Icons.delete), onPressed: _isLoading ? null : _deleteCard, tooltip: l10n.deleteCard),
          ],
          IconButton(
            icon: Icon(Icons.save, color: _isLoading ? Colors.white54 : Colors.white),
            onPressed: _isLoading ? null : _saveCard,
            tooltip: l10n.saveCard,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover image section
                    CardImageSection(
                      coverImagePath: _coverImagePath,
                      onImagePicked: (imagePath) => _setImagePath(imagePath),
                      onImageRemoved: () => _removeImage(),
                      onImageSharedGlobally: () => _shareImageGlobally(),
                    ),
                    const SizedBox(height: 24),

                    // Card name
                    Text(l10n.cardName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(hintText: l10n.cardNameHint, border: const OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.cardNameRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Barcode section
                    Text(l10n.barcodeLabel, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (_barcodeType == 'IMAGE_ONLY' || _barcodeType == 'TEXT') ? null : _scanBarcode,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: Text(l10n.scanBarcode),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Barcode preview or image upload for IMAGE_ONLY mode
                    if (_barcodeType == 'IMAGE_ONLY')
                      _buildBarcodeImageUploadWidget(l10n)
                    else
                      BarcodePreviewWidget(barcodeData: _barcodeDataController.text, barcodeType: _barcodeType),
                    const SizedBox(height: 16),

                    // Only show barcode data field if not in IMAGE_ONLY mode
                    if (_barcodeType != 'IMAGE_ONLY') ...[
                      TextFormField(
                        controller: _barcodeDataController,
                        decoration: InputDecoration(hintText: l10n.barcodeDataHint, border: const OutlineInputBorder(), suffixText: _barcodeType),
                        maxLines: 2,
                        onChanged: (_) => setState(() {}), // Refresh preview
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Barcode type selector
                    BarcodeTypeSelector(
                      selectedType: _barcodeType,
                      onTypeChanged: (type) {
                        setState(() {
                          _barcodeType = type;
                          // Auto-clear barcode data when "Image Only" is selected
                          if (type == 'IMAGE_ONLY') {
                            _barcodeDataController.text = '';
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Tags section
                    Text(l10n.tagsLabel, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    DynamicTagInput(
                      initialTags: _tags,
                      availableTags: _availableTags,
                      hintText: l10n.tagsHint,
                      onTagsChanged: (tags) {
                        setState(() {
                          _tags = tags;
                          // Add any new tags to available tags for better autocomplete
                          for (final tag in tags) {
                            if (!_availableTags.contains(tag)) {
                              _availableTags.add(tag);
                            }
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _togglePin() async {
    if (!widget.isEditing) return;

    try {
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      await cardProvider.toggleCardPin(widget.card!.uuid);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _isPinned = !_isPinned;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_isPinned ? l10n.cardPinned : l10n.cardUnpinned), backgroundColor: Theme.of(context).colorScheme.primary));
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pinError(e.toString())), backgroundColor: Theme.of(context).colorScheme.error));
      }
    }
  }

  Future<void> _scanBarcode() async {
    try {
      final result = await _barcodeService.scanFromCamera(context);
      if (result != null && mounted) {
        final mappedType = BarcodeTypes.mapBarcodeType(result.type);

        setState(() {
          _barcodeDataController.text = result.data;
          _barcodeType = mappedType;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.barcodeError(e.toString())), backgroundColor: Theme.of(context).colorScheme.error));
      }
    }
  }

  Future<void> _pickBarcodeImage() async {
    try {
      final imagePath = await _imageService.pickEditAndSaveImage(context: context);

      if (imagePath != null && mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _barcodeImagePath = imagePath;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.barcodeImageUploaded), backgroundColor: Theme.of(context).colorScheme.primary));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading image: $e'), backgroundColor: Theme.of(context).colorScheme.error));
      }
    }
  }

  void _removeBarcodeImage() {
    setState(() {
      _barcodeImagePath = null;
    });
  }

  Widget _buildBarcodeImageUploadWidget(AppLocalizations l10n) {
    // If image exists (either uploaded or cover image), show it
    final displayImagePath = _barcodeImagePath ?? _coverImagePath;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.barcodePreview, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickBarcodeImage,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: displayImagePath != null ? Colors.transparent : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
            ),
            child: displayImagePath != null
                ? Stack(
                    children: [
                      // Display the image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(displayImagePath), width: double.infinity, height: double.infinity, fit: BoxFit.contain),
                      ),
                      // Show a badge if using barcode image vs cover image
                      if (_barcodeImagePath != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              l10n.selectBarcodeImage,
                              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      // Remove button
                      if (_barcodeImagePath != null)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: _removeBarcodeImage,
                            style: IconButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error, foregroundColor: Theme.of(context).colorScheme.onError),
                          ),
                        ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(height: 8),
                        Text(
                          l10n.tapToUploadBarcodeImage,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        if (_coverImagePath != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '(Cover image will be used)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7), fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      final tagProvider = Provider.of<TagProvider>(context, listen: false);

      if (widget.isEditing) {
        // Update existing card
        final updatedCard = widget.card!.copyWith(
          name: _nameController.text.trim(),
          barcodeData: _barcodeDataController.text.trim(),
          barcodeType: _barcodeType,
          barcodeImagePath: _barcodeImagePath,
          tags: _tags,
          coverImagePath: _coverImagePath,
          updateDate: DateTime.now(),
        );
        await cardProvider.updateCard(updatedCard);
      } else {
        // Create new card
        final newCard = CardModel(
          uuid: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          barcodeData: _barcodeDataController.text.trim(),
          barcodeType: _barcodeType,
          barcodeImagePath: _barcodeImagePath,
          tags: _tags,
          coverImagePath: _coverImagePath,
          creationDate: DateTime.now(),
          updateDate: DateTime.now(),
          usageCount: 0,
        );
        await cardProvider.addCard(newCard);
      }

      // Refresh tag provider so main screen filter updates
      await tagProvider.loadTags();

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(widget.isEditing ? l10n.cardUpdatedSuccess : l10n.cardAddedSuccess), backgroundColor: Theme.of(context).colorScheme.primary));
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cardSaveError(e.toString())), backgroundColor: Theme.of(context).colorScheme.error));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _setImagePath(String imagePath) {
    setState(() {
      _coverImagePath = imagePath;
    });
  }

  void _removeImage() {
    setState(() {
      if (_coverImagePath != null) {
        // Delete the old image file
        try {
          File(_coverImagePath!).deleteSync();
        } catch (e) {
          debugPrint('Error deleting image: $e');
        }
        _coverImagePath = null;
      }
    });
  }

  Future<void> _deleteCard() async {
    if (!widget.isEditing) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final dialogL10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(dialogL10n.deleteCard),
          content: Text(dialogL10n.deleteCardMessage(widget.card!.name)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(dialogL10n.cancel)),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text(dialogL10n.delete)),
          ],
        );
      },
    );

    if (confirmed != true) return;
    if (!mounted) return;

    try {
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      await cardProvider.deleteCard(widget.card!.uuid);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        Navigator.pop(context); // Go back to main screen
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cardDeletedSuccess), backgroundColor: Theme.of(context).colorScheme.primary));
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cardDeleteError(e.toString())), backgroundColor: Theme.of(context).colorScheme.error));
      }
    }
  }

  Future<void> _shareCardGlobally() async {
    if (!widget.isEditing) return;

    try {
      final globalService = GlobalDataService();
      final syncService = SyncSettingsService();

      // Initialize WebDAV client if needed
      await syncService.initializeFromSettings();

      final settings = await syncService.loadSettings();
      if (settings?.username == null) {
        if (!mounted) return;
        throw Exception(AppLocalizations.of(context)!.exceptionUserNotConfigured);
      }

      // Check if card already exists globally
      bool cardExists = false;
      try {
        final globalCards = await globalService.getGlobalCards();
        cardExists = globalCards.any((globalCard) => globalCard.uuid == widget.card!.uuid);
      } catch (e) {
        debugPrint('Error checking global cards: $e');
        // Continue with sharing even if check fails
      }

      if (!mounted) return;

      // Show appropriate confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          final dialogL10n = AppLocalizations.of(context)!;
          return AlertDialog(
            title: Text(cardExists ? dialogL10n.updateGlobalCard : dialogL10n.shareCardGlobally),
            content: Text(
              cardExists
                  ? '${dialogL10n.cardExistsInGlobalPool}\n\n'
                        '${dialogL10n.updateGlobalCardConfirm} "${widget.card!.name}"?\n\n'
                        '${dialogL10n.overwriteGlobalCard}'
                  : '${dialogL10n.shareCardGloballyConfirm} "${widget.card!.name}" ${dialogL10n.shareCardGloballyConfirm2}\n\n'
                        '${dialogL10n.cardVisibleToAllUsers}',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(dialogL10n.cancel)),
              TextButton(onPressed: () => Navigator.pop(context, true), child: Text(cardExists ? dialogL10n.update : dialogL10n.share)),
            ],
          );
        },
      );

      if (confirmed != true) return;

      if (!mounted) return;
      // Share/update the card
      final l10nBeforeShare = AppLocalizations.of(context)!;
      await globalService.shareCardGlobally(widget.card!, settings!.username!, l10nBeforeShare.coverImageSuffix);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(cardExists ? l10n.globalCardUpdatedSuccess : l10n.cardSharedGloballySuccess), backgroundColor: Theme.of(context).colorScheme.primary),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.shareCardGloballyError}: $e'), backgroundColor: Theme.of(context).colorScheme.error));
      }
    }
  }

  Future<void> _shareImageGlobally() async {
    if (_coverImagePath == null) return;

    final imageName = await showDialog<String>(context: context, builder: (context) => _ImageNameDialog());

    if (imageName != null && imageName.isNotEmpty) {
      try {
        final globalService = GlobalDataService();
        final syncService = SyncSettingsService();

        // Initialize WebDAV client if needed
        await syncService.initializeFromSettings();

        final settings = await syncService.loadSettings();
        if (settings?.username != null) {
          await globalService.shareImageGlobally(_coverImagePath!, imageName, settings!.username!);

          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.imageSharedGloballySuccess), backgroundColor: Theme.of(context).colorScheme.primary));
          }
        } else {
          if (!mounted) return;
          throw Exception(AppLocalizations.of(context)!.exceptionUserNotConfigured);
        }
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.shareImageGloballyError}: $e'), backgroundColor: Theme.of(context).colorScheme.error));
        }
      }
    }
  }
}

/// Dialog for entering image name when sharing globally
class _ImageNameDialog extends StatefulWidget {
  @override
  State<_ImageNameDialog> createState() => _ImageNameDialogState();
}

class _ImageNameDialogState extends State<_ImageNameDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.shareImageGlobally),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.enterImageName),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: l10n.imageNameHint, border: const OutlineInputBorder()),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        TextButton(onPressed: () => Navigator.pop(context, _controller.text.trim()), child: Text(l10n.share)),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
