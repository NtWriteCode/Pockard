import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../models/card_model.dart';
import '../l10n/app_localizations.dart';
import '../widgets/cover_image_widget.dart';

class FullscreenBarcodeScreen extends StatefulWidget {
  final CardModel card;

  const FullscreenBarcodeScreen({
    super.key,
    required this.card,
  });

  @override
  State<FullscreenBarcodeScreen> createState() => _FullscreenBarcodeScreenState();
}

class _FullscreenBarcodeScreenState extends State<FullscreenBarcodeScreen> {
  double? _originalBrightness;
  bool _showAppBar = true;
  bool _showCoverImage = false;

  @override
  void initState() {
    super.initState();
    _setMaxBrightness();
    
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
    _restoreOriginalBrightness();
    super.dispose();
  }

  Future<void> _setMaxBrightness() async {
    try {
      // Get current system brightness to restore later
      _originalBrightness = await ScreenBrightness().system;
      
      // Set to maximum brightness
      await ScreenBrightness().setApplicationScreenBrightness(1.0);
    } catch (e) {
      debugPrint('Error setting brightness: $e');
    }
  }

  Future<void> _restoreOriginalBrightness() async {
    try {
      if (_originalBrightness != null && _originalBrightness! >= 0.1) {
        // Only restore if we have a valid value and it's not too dim (>= 10%)
        await ScreenBrightness().setApplicationScreenBrightness(_originalBrightness!);
      } else {
        // Reset to system default if value is missing or too low
        await ScreenBrightness().resetApplicationScreenBrightness();
      }
    } catch (e) {
      debugPrint('Error restoring brightness: $e');
      // Fallback: reset to system default
      try {
        await ScreenBrightness().resetApplicationScreenBrightness();
      } catch (_) {
        // Silently fail - brightness will remain at current level
      }
    }
  }

  void _toggleAppBarVisibility() {
    setState(() {
      _showAppBar = !_showAppBar;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.white,
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
          color: Colors.white,
          child: widget.card.barcodeData?.isNotEmpty == true
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Card name (always visible)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.card.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Barcode/QR Code, Text, or Cover Image
                        Flexible(
                          child: _showCoverImage && widget.card.coverImagePath != null
                              ? _buildCoverImageView()
                              : widget.card.barcodeType == 'TEXT'
                                  ? _buildTextOnlyView()
                                  : Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: 350,
                                        maxHeight: 350,
                                      ),
                                      child: AspectRatio(
                                        aspectRatio: 1.0,
                                        child: BarcodeWidget(
                                          barcode: _getBarcodeType(widget.card.barcodeType ?? ''),
                                          data: widget.card.barcodeData ?? '',
                                          width: double.infinity,
                                          height: double.infinity,
                                          drawText: false,
                                          color: Colors.black,
                                          backgroundColor: Colors.white,
                                          errorBuilder: (context, error) => _buildErrorWidget(),
                                        ),
                                      ),
                                    ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Barcode data text
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: SelectableText(
                            widget.card.barcodeData ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'monospace',
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Tap hint
                        Text(
                          _showAppBar ? l10n.tapToHideControls : l10n.tapToShowControls,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildNoDataWidget(),
        ),
      ),
      floatingActionButton: widget.card.coverImagePath != null
          ? _buildToggleButton(l10n)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildErrorWidget() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.unableToGenerateBarcode,
            style: TextStyle(
              color: Colors.red[700],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.invalidBarcodeData,
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget() {
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_2,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noBarcodeDataAvailable,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noBarcodeDataMessage,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCardInfo() {
    showDialog(
      context: context,
      builder: (context) {
        final dialogL10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(widget.card.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(dialogL10n.type, widget.card.barcodeType ?? ''),
              const SizedBox(height: 8),
              _buildInfoRow(dialogL10n.data, widget.card.barcodeData ?? ''),
              const SizedBox(height: 8),
              _buildInfoRow(dialogL10n.usageCountLabel, '${widget.card.usageCount}'),
              const SizedBox(height: 8),
              _buildInfoRow(dialogL10n.tags, widget.card.tags.join(', ')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(dialogL10n.close),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? 'N/A' : value,
            style: TextStyle(
              color: value.isEmpty ? Colors.grey : null,
            ),
          ),
        ),
      ],
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

  Widget _buildCoverImageView() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 500,
        maxHeight: 500,
      ),
      child: CoverImageWidget(
        imagePath: widget.card.coverImagePath!,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTextOnlyView() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 500,
        maxHeight: 500,
      ),
      padding: const EdgeInsets.all(32),
      child: Center(
        child: SelectableText(
          widget.card.barcodeData ?? '',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildToggleButton(AppLocalizations l10n) {
    return TextButton.icon(
      onPressed: () {
        setState(() {
          _showCoverImage = !_showCoverImage;
        });
      },
      icon: Icon(
        _showCoverImage ? Icons.qr_code_2 : Icons.image,
        size: 16,
        color: Colors.grey[600],
      ),
      label: Text(
        _showCoverImage ? l10n.showBarcode : l10n.showCoverImage,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
}
