import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

/// Displays a document/PDF preview with an option to pick or change the file.
///
/// This is a pure presentation widget – it renders the preview image and
/// "pick" / "change" affordances, but delegates the actual PDF picking to
/// the parent via [onPickPDF].
class DocumentPreviewSection extends StatelessWidget {
  /// Base-64 encoded preview image of the first PDF page, if available.
  final String? previewBase64;

  /// Local file-system path of the currently associated PDF, if available.
  final String? localFilePath;

  /// Called when the user taps the placeholder or the "Change Document" button.
  final VoidCallback onPickPDF;

  const DocumentPreviewSection({
    super.key,
    this.previewBase64,
    this.localFilePath,
    required this.onPickPDF,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (previewBase64 != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1.414, // Standard A4 ratio
                child: Image.memory(
                  base64Decode(previewBase64!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        else
          GestureDetector(
            onTap: onPickPDF,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap to pick PDF document'),
                ],
              ),
            ),
          ),
        if (localFilePath != null) ...[
          const SizedBox(height: 8),
          Text(
            'File: ${p.basename(localFilePath!)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          TextButton.icon(
            onPressed: onPickPDF,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Change Document'),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
