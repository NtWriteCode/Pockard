import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/card_model.dart';
import '../l10n/app_localizations.dart';

class FullscreenCoverImageScreen extends StatefulWidget {
  final CardModel card;

  const FullscreenCoverImageScreen({super.key, required this.card});

  @override
  State<FullscreenCoverImageScreen> createState() => _FullscreenCoverImageScreenState();
}

class _FullscreenCoverImageScreenState extends State<FullscreenCoverImageScreen> {
  bool _showAppBar = true;
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    // Hide app bar after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showAppBar = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getAvailableImages(AppLocalizations? l10n) {
    if (l10n == null) return [];
    final isIdentity = widget.card.category == CardCategory.identity;

    final available = <Map<String, String>>[];

    if (widget.card.barcodeImagePath != null && File(widget.card.barcodeImagePath!).existsSync()) {
      available.add({'path': widget.card.barcodeImagePath!, 'label': l10n.barcodeImageLabel});
    }
    if (widget.card.coverImagePath != null && File(widget.card.coverImagePath!).existsSync()) {
      available.add({'path': widget.card.coverImagePath!, 'label': isIdentity ? l10n.frontImageLabel : l10n.coverImageLabel});
    }
    if (widget.card.backImagePath != null && File(widget.card.backImagePath!).existsSync()) {
      available.add({'path': widget.card.backImagePath!, 'label': l10n.backImageLabel});
    }

    return available;
  }

  void _toggleAppBarVisibility() {
    setState(() {
      _showAppBar = !_showAppBar;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final images = _getAvailableImages(l10n);

    if (images.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.white, elevation: 0),
        body: _buildNoImageWidget(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showAppBar
          ? AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.card.name, style: const TextStyle(fontSize: 16)),
                  if (images.length > 1) Text(images[_currentIndex]['label']!, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    _showCardInfo();
                  },
                ),
              ],
            )
          : null,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: _toggleAppBarVisibility,
                child: InteractiveViewer(
                  // When at scale 1.0, allow PageView to handle the swipe
                  // When zoomed, pan takes priority
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.file(
                      File(images[index]['path']!),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildNoImageWidget();
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showAppBar ? 1.0 : 0.3, // Fade dots but keep them visible
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: _currentIndex == index ? Colors.white : Colors.white38),
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoImageWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 80, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noCoverImage,
            style: TextStyle(color: Colors.grey[400], fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)!.addCoverImageToCard, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 24),
          Text('Tap anywhere to ${_showAppBar ? 'hide' : 'show'} controls', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        ],
      ),
    );
  }

  void _showCardInfo() {
    final dialogL10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.card.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(dialogL10n.type, dialogL10n.noBarcodeOnly),
            const SizedBox(height: 8),
            _buildInfoRow('Usage Count', '${widget.card.usageCount}'),
            const SizedBox(height: 8),
            _buildInfoRow('Tags', widget.card.tags.join(', ')),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.close))],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Text(value.isEmpty ? 'N/A' : value, style: TextStyle(color: value.isEmpty ? Colors.grey : null)),
        ),
      ],
    );
  }
}
