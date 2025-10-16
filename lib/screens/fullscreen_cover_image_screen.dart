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

  @override
  void initState() {
    super.initState();

    // Hide app bar after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showAppBar = false;
        });
      }
    });
  }

  void _toggleAppBarVisibility() {
    setState(() {
      _showAppBar = !_showAppBar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showAppBar
          ? AppBar(
              title: Text(widget.card.name),
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
      body: GestureDetector(
        onTap: _toggleAppBarVisibility,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: () {
            // Priority: barcode image > cover image
            final imagePath = widget.card.barcodeImagePath ?? widget.card.coverImagePath;
            return imagePath != null
                ? Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.file(
                        File(imagePath),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildNoImageWidget();
                        },
                      ),
                    ),
                  )
                : _buildNoImageWidget();
          }(),
        ),
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
