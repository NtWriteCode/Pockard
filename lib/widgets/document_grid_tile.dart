import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/document_model.dart';

class DocumentGridTile extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool showName;

  const DocumentGridTile({
    super.key,
    required this.document,
    required this.onTap,
    this.onLongPress,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview Section (1:1 aspect ratio)
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: ClipRRect(
                  borderRadius: showName ? const BorderRadius.vertical(top: Radius.circular(12)) : BorderRadius.circular(12),
                  child: _buildPreview(context),
                ),
              ),
            ),

            // Document Name Section
            if (showName)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (document.isPinned)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(Icons.push_pin, size: 12, color: Theme.of(context).colorScheme.primary),
                        ),
                      Flexible(
                        child: Text(
                          document.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 11),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
  }

  Widget _buildPreview(BuildContext context) {
    if (document.previewBase64 != null && document.previewBase64!.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(document.previewBase64!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
        );
      } catch (e) {
        return _buildPlaceholder(context);
      }
    }
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Icon(
        Icons.description_outlined,
        size: 32,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
      ),
    );
  }
}
