import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/document_model.dart';

/// Ultra-compact document tile showing only name and tiny preview image.
/// Designed to pack maximum documents in minimal space, mirroring CardMinimalTile.
class DocumentMinimalTile extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const DocumentMinimalTile({
    super.key,
    required this.document,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              // Tiny preview image
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: document.previewBase64 != null && document.previewBase64!.isNotEmpty
                      ? Image.memory(base64Decode(document.previewBase64!), fit: BoxFit.cover)
                      : _buildPlaceholder(context),
                ),
              ),
              const SizedBox(width: 12),

              // Document name with pin indicator
              Expanded(
                child: Row(
                  children: [
                    if (document.isPinned)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(Icons.push_pin, size: 14, color: Theme.of(context).colorScheme.primary),
                      ),
                    Expanded(
                      child: Text(
                        document.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Chevron indicator
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(Icons.description_outlined, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}
