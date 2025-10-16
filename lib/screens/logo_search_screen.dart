import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import '../services/logo_search_service.dart';
import '../services/logo_processing_service.dart';
import '../l10n/app_localizations.dart';

class LogoSearchScreen extends StatefulWidget {
  final Function(String) onLogoSelected;

  const LogoSearchScreen({super.key, required this.onLogoSelected});

  @override
  State<LogoSearchScreen> createState() => _LogoSearchScreenState();
}

class _LogoSearchScreenState extends State<LogoSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<LogoResult> _allResults = [];
  List<LogoResult> _displayedResults = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 0;
  static const int _resultsPerPage = 8;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLogos() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 0;
    });

    try {
      final results = await LogoSearchService.searchLogos(query);
      setState(() {
        _allResults = results;
        _displayedResults = results.take(_resultsPerPage).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '${AppLocalizations.of(context)!.exceptionFailedSearchLogos}: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreResults() async {
    if (_isLoadingMore || _displayedResults.length >= _allResults.length) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate loading delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _currentPage++;
      final startIndex = _currentPage * _resultsPerPage;
      final endIndex = (startIndex + _resultsPerPage).clamp(0, _allResults.length);
      _displayedResults = _allResults.take(endIndex).toList();
      _isLoadingMore = false;
    });
  }

  Future<void> _selectLogo(LogoResult logo) async {
    try {
      final l10n = AppLocalizations.of(context)!;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(content: Row(children: [const CircularProgressIndicator(), const SizedBox(width: 16), Text(l10n.processingLogo)])),
      );

      // Step 1: Download the logo SVG
      final fileName = '${logo.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_logo.svg';
      final downloadedPath = await LogoSearchService.downloadLogo(logo.imageUrl, fileName);

      if (downloadedPath == null) {
        if (!mounted) return;
        throw Exception(AppLocalizations.of(context)!.exceptionFailedDownloadLogo);
      }

      // Step 2: Convert SVG to high-res padded PNG (2000px with smart padding)
      final logoService = LogoProcessingService();
      final paddedPngPath = await logoService.convertSvgToHighResPaddedPng(downloadedPath);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (paddedPngPath == null) {
        if (!mounted) return;
        throw Exception(AppLocalizations.of(context)!.exceptionFailedProcessLogo);
      }

      // Step 3: Show cropper with the high-res padded image
      if (!mounted) {
        throw Exception(AppLocalizations.of(context)!.exceptionContextNotAvailable);
      }

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: paddedPngPath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: AppLocalizations.of(context)!.adjustLogo,
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
          IOSUiSettings(
            title: AppLocalizations.of(context)!.adjustLogo,
            doneButtonTitle: AppLocalizations.of(context)!.done,
            cancelButtonTitle: AppLocalizations.of(context)!.cancel,
            aspectRatioLockEnabled: true,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
        ],
      );

      if (croppedFile == null) {
        // User cancelled cropping - clean up temp files
        final File tempFile = File(paddedPngPath);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
        throw Exception(AppLocalizations.of(context)!.exceptionLogoSelectionCancelled);
      }

      // Step 4: Downscale the cropped image to 500x500
      final finalPath = await logoService.downscaleImage(croppedFile.path, 500);

      if (finalPath == null) {
        if (!mounted) return;
        throw Exception(AppLocalizations.of(context)!.exceptionFailedFinalizeLogo);
      }

      // Step 5: Clean up temporary files
      try {
        final File paddedFile = File(paddedPngPath);
        if (await paddedFile.exists()) {
          await paddedFile.delete();
        }
        final File croppedTempFile = File(croppedFile.path);
        if (await croppedTempFile.exists()) {
          await croppedTempFile.delete();
        }
      } catch (e) {
        debugPrint('⚠️ Error cleaning up temp files: $e');
      }

      // Step 6: Return the final logo path
      widget.onLogoSelected(finalPath);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.logoAddedSuccess), backgroundColor: Theme.of(context).colorScheme.primary));
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context);
        }
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorProcessingLogo(e.toString())), backgroundColor: Theme.of(context).colorScheme.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.searchLogo),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: _searchLogos)],
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.shopNameHint,
                    suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _searchLogos),
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _searchLogos(),
                );
              },
            ),
          ),

          // Results
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [const CircularProgressIndicator(), const SizedBox(height: 16), Text(AppLocalizations.of(context)!.searchingForLogos)],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _searchLogos, child: Text(AppLocalizations.of(context)!.tryAgain)),
          ],
        ),
      );
    }

    if (_displayedResults.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Column(
                  children: [
                    Text(l10n.noLogosFound, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(l10n.tryDifferentSearch, style: const TextStyle(color: Colors.grey)),
                  ],
                );
              },
            ),
          ],
        ),
      );
    }

    if (_displayedResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_search, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Column(
                  children: [
                    Text(l10n.searchForLogos, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(l10n.enterShopName, style: const TextStyle(color: Colors.grey)),
                  ],
                );
              },
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Results info
        if (_allResults.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(l10n.showingLogosCount(_displayedResults.length, _allResults.length), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]));
              },
            ),
          ),

        // Grid view
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.2, crossAxisSpacing: 16, mainAxisSpacing: 16),
            itemCount: _displayedResults.length,
            itemBuilder: (context, index) {
              final logo = _displayedResults[index];
              return _buildLogoCard(logo);
            },
          ),
        ),

        // Load more button
        if (_displayedResults.length < _allResults.length)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoadingMore ? null : _loadMoreResults,
                icon: _isLoadingMore ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.expand_more),
                label: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Text(_isLoadingMore ? l10n.loading : l10n.loadMore(_allResults.length - _displayedResults.length));
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLogoCard(LogoResult logo) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _selectLogo(logo),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo preview
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SvgPicture.network(
                      logo.imageUrl,
                      fit: BoxFit.contain,
                      placeholderBuilder: (context) => const Center(child: CircularProgressIndicator()),
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported, size: 48, color: Colors.grey);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Logo name
              Text(
                logo.name,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
