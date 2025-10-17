import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/card_model.dart';
import '../providers/card_provider.dart';
import '../services/global_data_service.dart';
import '../services/sync_settings_service.dart';
import '../l10n/app_localizations.dart';
import 'card_form_screen.dart';

class CardDetailScreen extends StatelessWidget {
  final CardModel card;

  const CardDetailScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(card.name),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () => _navigateToEdit(context)),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation(context);
              } else if (value == 'share_global') {
                _shareCardGlobally(context);
              }
            },
            itemBuilder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return [
                PopupMenuItem(
                  value: 'share_global',
                  child: Row(
                    children: [
                      const Icon(Icons.public, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(l10n.shareGlobally),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(l10n.deleteCard),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image section (1:1 aspect ratio)
            if (card.coverImagePath != null)
              AspectRatio(
                aspectRatio: 1.0, // Enforce square 1:1 ratio
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: Image.file(
                    File(card.coverImagePath!),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.credit_card, size: 80, color: Colors.grey[400]),
                      );
                    },
                  ),
                ),
              )
            else
              AspectRatio(
                aspectRatio: 1.0, // Enforce square 1:1 ratio
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Icon(Icons.credit_card, size: 80, color: Colors.grey[400]),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card name
                  Text(card.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Tags section
                  if (card.tags.isNotEmpty) ...[
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return Text(l10n.tags, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600));
                      },
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: card.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Barcode data section
                  if (card.barcodeData != null) ...[
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return Text(l10n.barcodeInformation, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600));
                      },
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.qr_code, color: Colors.grey[600]),
                                    const SizedBox(width: 8),
                                    Text('${l10n.type}: ${card.barcodeType ?? l10n.unknown}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('${l10n.data}: ${card.barcodeData}', style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Statistics section
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.statistics, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  _buildStatRow(context, Icons.visibility, l10n.timesUsed, '${card.usageCount}'),
                                  const Divider(),
                                  _buildStatRow(context, Icons.add_circle_outline, l10n.created, DateFormat('MMM dd, yyyy').format(card.creationDate)),
                                  const Divider(),
                                  _buildStatRow(context, Icons.update, l10n.lastUpdated, DateFormat('MMM dd, yyyy').format(card.updateDate)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CardFormScreen(card: card)));
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final dialogL10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(dialogL10n.deleteCard),
          content: Text(dialogL10n.deleteCardMessage(card.name)),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(dialogL10n.cancel)),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog

                final success = await Provider.of<CardProvider>(context, listen: false).deleteCard(card.uuid);

                if (context.mounted) {
                  final l10n = AppLocalizations.of(context)!;
                  if (success) {
                    Navigator.of(context).pop(); // Go back to main screen
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cardDeletedSuccess), backgroundColor: Theme.of(context).colorScheme.primary));
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.cardDeleteError(l10n.unknownError)), backgroundColor: Theme.of(context).colorScheme.error));
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(dialogL10n.delete),
            ),
          ],
        );
      },
    );
  }

  Future<void> _shareCardGlobally(BuildContext context) async {
    try {
      final globalService = GlobalDataService();
      final syncService = SyncSettingsService();

      // Initialize WebDAV client if needed
      await syncService.initializeFromSettings();

      final settings = await syncService.loadSettings();
      if (settings?.username != null) {
        if (!context.mounted) return;
        final l10n = AppLocalizations.of(context)!;
        await globalService.shareCardGlobally(card, settings!.username!, l10n.coverImageSuffix);
      } else {
        if (!context.mounted) return;
        throw Exception(AppLocalizations.of(context)!.exceptionUserNotConfigured);
      }

      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cardSharedGloballySuccess), backgroundColor: Theme.of(context).colorScheme.primary));
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.shareCardGloballyError}: $e'), backgroundColor: Theme.of(context).colorScheme.error));
      }
    }
  }
}
