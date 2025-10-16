import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';

class ImageGeneratorScreen extends StatefulWidget {
  const ImageGeneratorScreen({super.key});

  @override
  State<ImageGeneratorScreen> createState() => _ImageGeneratorScreenState();
}

class _ImageGeneratorScreenState extends State<ImageGeneratorScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final TextEditingController _textController = TextEditingController();

  Color _selectedColor = AppColors.imageGeneratorColors[1]; // Default to blue
  Color _textColor = AppColors.white;
  String _customText = '';

  // Predefined colors for quick selection
  static const List<Color> _predefinedColors = AppColors.imageGeneratorColors;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {
        _customText = _textController.text;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.generateImage),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [TextButton(onPressed: _customText.isNotEmpty ? _generateAndSaveImage : null, child: Text(l10n.save))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Section
            _buildPreviewSection(),
            const SizedBox(height: 24),

            // Background Color Selection
            _buildColorSelectionSection(),
            const SizedBox(height: 24),

            // Text Input Section
            _buildTextInputSection(),
            const SizedBox(height: 24),

            // Text Color Selection
            _buildTextColorSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.preview,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 12),
        Center(
          child: RepaintBoundary(
            key: _repaintBoundaryKey,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2), width: 2),
              ),
              child: _customText.isNotEmpty
                  ? Center(
                      child: Text(
                        _customText,
                        style: TextStyle(color: _textColor, fontSize: _calculateOptimalFontSize(_customText), fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: _calculateOptimalLines(_customText),
                        overflow: TextOverflow.visible,
                      ),
                    )
                  : Center(child: Icon(Icons.image, size: 48, color: _textColor.withValues(alpha: 0.5))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelectionSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.backgroundColor,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 12),

        // Predefined Colors Grid
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _predefinedColors.map((color) {
            final isSelected = _selectedColor == color;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected ? Icon(Icons.check, color: AppColors.getContrastColor(color), size: 20) : null,
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // Custom Color Picker Button
        Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showCustomColorPicker,
                icon: const Icon(Icons.palette),
                label: Text(l10n.customColor),
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.text,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 12),
        Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: l10n.enterTextHint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.text_fields),
              ),
              maxLines: 4,
              maxLength: 100,
              textCapitalization: TextCapitalization.sentences,
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.textColor,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 12),
        Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Row(children: [_buildTextColorOption(AppColors.white, l10n.white), const SizedBox(width: 16), _buildTextColorOption(AppColors.black, l10n.black)]);
          },
        ),
      ],
    );
  }

  Widget _buildTextColorOption(Color color, String label) {
    final isSelected = _textColor == color;
    return GestureDetector(
      onTap: () => setState(() => _textColor = color),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomColorPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          final dialogL10n = AppLocalizations.of(context)!;
          return Scaffold(
            appBar: AppBar(
              title: Text(dialogL10n.chooseCustomColor),
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(dialogL10n.done))],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ColorPicker(
                pickerColor: _selectedColor,
                onColorChanged: (color) {
                  setState(() => _selectedColor = color);
                },
                pickerAreaHeightPercent: 0.8,
              ),
            ),
          );
        },
      ),
    );
  }

  double _calculateOptimalFontSize(String text) {
    if (text.isEmpty) return 70.0;

    // Start with 70px and decrease if text doesn't fit
    double fontSize = 70.0;
    final availableWidth = 200 * 0.8; // 80% of container width (160px)
    final availableHeight = 200 * 0.8; // 80% of container height (160px)

    // Calculate how many lines the text will have
    final lines = text.split('\n');

    // Decrease font size until ALL lines fit without overflow
    while (fontSize > 10) {
      bool allLinesFit = true;

      // Check each line individually using TextPainter for accurate measurement
      for (final line in lines) {
        if (line.isEmpty) continue;

        // Use TextPainter for accurate text measurement
        final textPainter = TextPainter(
          text: TextSpan(
            text: line,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        // If any line would overflow, reduce font size
        if (textPainter.width > availableWidth) {
          allLinesFit = false;
          break;
        }
      }

      // Also check if total height fits using TextPainter
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
        maxLines: lines.length,
      );
      textPainter.layout();

      if (textPainter.height > availableHeight) {
        allLinesFit = false;
      }

      // If all lines fit, return this font size
      if (allLinesFit) {
        return fontSize;
      }

      fontSize -= 2; // Decrease by 2px each iteration
    }

    return 10.0; // Minimum font size
  }

  int _calculateOptimalLines(String text) {
    if (text.isEmpty) return 1;

    // Use actual lines from user input (split by \n)
    final lines = text.split('\n');
    return lines.length;
  }

  Future<void> _generateAndSaveImage() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Capture the RepaintBoundary as an image
      final RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        // Save to app's documents directory
        final directory = await getApplicationDocumentsDirectory();
        final imagesDir = Directory(path.join(directory.path, 'images'));
        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }

        final fileName = 'generated_${DateTime.now().millisecondsSinceEpoch}.png';
        final filePath = path.join(imagesDir.path, fileName);
        final file = File(filePath);
        await file.writeAsBytes(byteData.buffer.asUint8List());

        // Close loading dialog
        if (mounted) Navigator.pop(context);

        // Return the generated image path
        if (mounted) {
          Navigator.pop(context, filePath);
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneratingImage(e.toString())), backgroundColor: Theme.of(context).colorScheme.error));
      }
    }
  }
}
