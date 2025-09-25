import 'dart:io';
import 'package:flutter/material.dart';
import '../models/card_model.dart';
import 'cover_image_widget.dart';

/// Ultra-compact card tile showing only name and tiny preview image
/// Designed to pack maximum cards in minimal space
class CardMinimalTile extends StatelessWidget {
  final CardModel card;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const CardMinimalTile({
    super.key,
    required this.card,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              // Tiny preview image (same height as text)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: card.coverImagePath != null
                      ? _buildImage(card.coverImagePath!)
                      : _buildPlaceholder(context),
                ),
              ),
              const SizedBox(width: 12),
              
              // Card name with pin indicator
              Expanded(
                child: Row(
                  children: [
                    if (card.isPinned)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.push_pin,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        card.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildImage(String imagePath) {
    final file = File(imagePath);
    if (!file.existsSync()) {
      return Container(color: Colors.grey[300]);
    }

    return CoverImageWidget(
      imagePath: imagePath,
      fit: BoxFit.cover,
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.credit_card,
        size: 16,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

