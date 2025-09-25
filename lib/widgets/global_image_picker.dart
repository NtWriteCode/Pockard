import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/global_image_model.dart';
import '../services/global_data_service.dart';
import '../services/sync_settings_service.dart';
import '../l10n/app_localizations.dart';

class GlobalImagePicker extends StatefulWidget {
  const GlobalImagePicker({super.key});

  @override
  State<GlobalImagePicker> createState() => _GlobalImagePickerState();
}

class _GlobalImagePickerState extends State<GlobalImagePicker> {
  final GlobalDataService _globalService = GlobalDataService();
  final SyncSettingsService _syncService = SyncSettingsService();
  List<GlobalImageModel> _globalImages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGlobalImages();
  }

  Future<void> _loadGlobalImages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize WebDAV client if needed
      await _syncService.initializeFromSettings();
      
      final images = await _globalService.getGlobalImages();
      setState(() {
        _globalImages = images;
      });
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.failedToLoadGlobalImages2}: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectImage(GlobalImageModel imageModel) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Download and duplicate the image locally
      final localPath = await _globalService.downloadGlobalImage(imageModel);
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.pop(context, localPath); // Return local path
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.failedToDownloadImage}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.chooseFromGlobalImages,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_globalImages.isEmpty)
              Expanded(
                child: Center(
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noGlobalImages,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _globalImages.length,
                  itemBuilder: (context, index) {
                    final image = _globalImages[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _selectImage(image),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: FutureBuilder<String>(
                                future: _globalService.downloadGlobalImage(image),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                                        errorBuilder: (context, error, stackTrace) => Container(
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
                            Expanded(
                              flex: 2,
                              child: Padding(
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
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      DateFormat('MMM dd').format(image.uploadDate),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
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
                  },
                ),
              ),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _loadGlobalImages,
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.refresh),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
