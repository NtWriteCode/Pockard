import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/document_model.dart';
import '../l10n/app_localizations.dart';

class DocumentTile extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const DocumentTile({
    super.key,
    required this.document,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Preview image or placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: document.previewBase64 != null && document.previewBase64!.isNotEmpty
                      ? Image.memory(base64Decode(document.previewBase64!), fit: BoxFit.cover)
                      : _buildPlaceholder(context),
                ),
              ),
              const SizedBox(width: 16),

              // Document details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            document.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (document.isPinned)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(Icons.push_pin, size: 16, color: Theme.of(context).colorScheme.primary),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Tags
                    if (document.tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: document.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Theme.of(context).colorScheme.outline),
                            ),
                            child: Text(
                              tag,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 8),

                    // Size and date info
                    Row(
                      children: [
                        Icon(Icons.straighten, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${(document.fileSizeBytes / 1024 / 1024).toStringAsFixed(2)} MB',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(document.updateDate, context),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(Icons.description_outlined, size: 30, color: Theme.of(context).colorScheme.onSurface),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return l10n.justNow;
        }
        return l10n.minutesAgo(difference.inMinutes);
      }
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }
}
