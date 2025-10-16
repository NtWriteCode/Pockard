import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/global_data_service.dart';
import '../../services/sync_settings_service.dart';
import '../../services/image_service.dart';
import '../../models/global_image_model.dart';
import '../../l10n/app_localizations.dart';

class GlobalImagesTab extends StatefulWidget {
  const GlobalImagesTab({super.key});

  @override
  State<GlobalImagesTab> createState() => _GlobalImagesTabState();
}

class _GlobalImagesTabState extends State<GlobalImagesTab> {
  final GlobalDataService _globalService = GlobalDataService();
  final SyncSettingsService _syncService = SyncSettingsService();
  final ImageService _imageService = ImageService();
  List<GlobalImageModel> _globalImages = [];
  bool _isLoading = false;
  bool _globalFolderAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkGlobalFolderAndLoad();
  }

  Future<void> _checkGlobalFolderAndLoad() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if connected and has credentials
      final settings = await _syncService.loadSettings();
      if (settings == null || !settings.hasCredentials) {
        if (!mounted) return;
        throw Exception(AppLocalizations.of(context)!.exceptionConfigureWebdav);
      }

      // Initialize WebDAV client
      await _syncService.initializeFromSettings();

      // Check if global folder is available
      _globalFolderAvailable = await _globalService.isGlobalFolderAvailable();

      if (_globalFolderAvailable) {
        await _loadGlobalImages();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadGlobalImages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final images = await _globalService.getGlobalImages();
      if (mounted) {
        setState(() {
          _globalImages = images;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorDownloadingImage(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteGlobalImage(GlobalImageModel image) async {
    try {
      await _globalService.deleteGlobalImage(image.uuid);
      if (mounted) {
        setState(() {
          _globalImages.removeWhere((img) => img.uuid == image.uuid);
        });

        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.imageDeletedSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorDeletingGlobalImage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(GlobalImageModel image) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final dialogL10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(dialogL10n.deleteGlobalImage),
          content: Text(
            '${dialogL10n.deleteGlobalImageConfirm(image.name)}\n\n'
            '${dialogL10n.actionCannotBeUndone}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(dialogL10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteGlobalImage(image);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(dialogL10n.delete),
            ),
          ],
        );
      },
    );
  }

  void _showImageUploadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext dialogContext) {
        final dialogL10n = AppLocalizations.of(dialogContext)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(dialogL10n.camera),
                subtitle: Text(dialogL10n.takePhotoAndEdit),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(dialogL10n.gallery),
                subtitle: Text(dialogL10n.choosePhotoAndEdit),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final imagePath = await _imageService.pickEditAndSaveImage(
        context: context,
        source: source,
      );
      if (imagePath != null) {
        await _showImageNameDialog(imagePath);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorPickingImage(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showImageNameDialog(String imagePath) async {
    final nameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final dialogL10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(dialogL10n.uploadToGlobalImages),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image preview
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: dialogL10n.imageName,
                  hintText: dialogL10n.imageNameHint,
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(dialogL10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(dialogContext).pop(name);
                }
              },
              child: Text(dialogL10n.upload),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      await _uploadImageToGlobal(imagePath, result);
    }
  }

  Future<void> _uploadImageToGlobal(String imagePath, String imageName) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get current settings
      final settings = await _syncService.loadSettings();
      if (settings == null || !settings.hasCredentials) {
        if (!mounted) return;
        throw Exception(AppLocalizations.of(context)!.exceptionConfigureWebdav);
      }

      // Use username as uploader identifier (no more pseudoUser)
      await _globalService.shareImageGlobally(
        imagePath,
        imageName,
        settings.username!,
      );

      // Refresh the global images list
      await _loadGlobalImages();

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.imageUploadedSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorUploadingImage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showImagePreview(GlobalImageModel image) async {
    try {
      final imagePath = await _globalService.downloadGlobalImage(image);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.broken_image,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(l10n.unknownError),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        image.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'By ${image.uploaderPseudoUser} • ${DateFormat('MMM dd, yyyy').format(image.uploadDate)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorDownloadingImage(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show warning if global folder is not available
    if (!_globalFolderAvailable) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.folder_off, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Column(
                    children: [
                      Text(
                        l10n.globalFolderNotAvailable,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Column(
                          children: [
                            Text(
                              l10n.globalFolderRequired,
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.createGlobalFolderManually,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return ElevatedButton.icon(
                    onPressed: _checkGlobalFolderAndLoad,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    if (_globalImages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Column(
                  children: [
                    Text(
                      l10n.noGlobalImages,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.noImagesSharedYet,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _showImageUploadOptions,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: Text(l10n.uploadImage),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _loadGlobalImages,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.refresh),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(
                    context,
                  )!.globalImagesCount(_globalImages.length),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: _showImageUploadOptions,
                icon: const Icon(Icons.add_photo_alternate),
                tooltip: 'Upload Image',
              ),
              IconButton(
                onPressed: _loadGlobalImages,
                icon: const Icon(Icons.refresh),
                tooltip: AppLocalizations.of(context)!.tooltipRefresh,
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.8,
            ),
            itemCount: _globalImages.length,
            itemBuilder: (context, index) {
              final image = _globalImages[index];
              return GestureDetector(
                onTap: () => _showImagePreview(image),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: FutureBuilder<String>(
                          future: _globalService.downloadGlobalImage(image),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (snapshot.hasData) {
                              return ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.file(
                                  File(snapshot.data!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                              );
                            }

                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image,
                                size: 48,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              image.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'By ${image.uploaderPseudoUser}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'MMM dd, yyyy',
                              ).format(image.uploadDate),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Builder(
                                    builder: (context) {
                                      final l10n = AppLocalizations.of(
                                        context,
                                      )!;
                                      return TextButton.icon(
                                        onPressed: () =>
                                            _showDeleteConfirmation(image),
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 16,
                                        ),
                                        label: Text(l10n.delete),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
