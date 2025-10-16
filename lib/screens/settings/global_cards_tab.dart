import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/card_provider.dart';
import '../../services/global_data_service.dart';
import '../../services/sync_settings_service.dart';
import '../../models/card_model.dart';
import '../../widgets/card_tile.dart';
import '../../l10n/app_localizations.dart';

class GlobalCardsTab extends StatefulWidget {
  const GlobalCardsTab({super.key});

  @override
  State<GlobalCardsTab> createState() => _GlobalCardsTabState();
}

class _GlobalCardsTabState extends State<GlobalCardsTab> {
  final GlobalDataService _globalService = GlobalDataService();
  final SyncSettingsService _syncService = SyncSettingsService();
  List<CardModel> _globalCards = [];
  bool _isLoading = false;
  bool _globalFolderAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkGlobalFolderAndLoad();
  }

  Future<void> _checkGlobalFolderAndLoad() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if connected and has credentials
      final settings = await _syncService.loadSettings();
      if (settings == null || !settings.hasCredentials) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        throw Exception(l10n.configureWebdavFirst);
      }

      // Initialize WebDAV client
      await _syncService.initializeFromSettings();

      // Check if global folder is available
      _globalFolderAvailable = await _globalService.isGlobalFolderAvailable();

      if (_globalFolderAvailable) {
        await _loadGlobalCards();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadGlobalCards() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cards = await _globalService.getGlobalCards();
      if (mounted) {
        setState(() {
          _globalCards = cards;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorDownloadingCard(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _importCard(CardModel card) async {
    try {
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      final existingCard = cardProvider.getCardById(card.uuid);

      if (existingCard != null) {
        await cardProvider.updateCard(card);
      } else {
        await cardProvider.addCard(card);
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cardImportedSuccess),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorImportingCards(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteGlobalCard(CardModel card) async {
    try {
      await _globalService.deleteGlobalCard(card.uuid);
      setState(() {
        _globalCards.removeWhere((c) => c.uuid == card.uuid);
      });

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cardDeletedSuccess),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorDeletingGlobalCard(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show warning if global folder is not available
    if (!_globalFolderAvailable) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.folder_off, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                l10n.globalFolderNotAvailable,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.globalFolderRequired,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.createGlobalFolderManually,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _checkGlobalFolderAndLoad,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_globalCards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.public, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Column(
                  children: [
                    Text(
                      l10n.noGlobalCards,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.noCardsSharedYet,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return ElevatedButton(
                  onPressed: _loadGlobalCards,
                  child: Text(l10n.refresh),
                );
              },
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(
                    context,
                  )!.globalCardsCount(_globalCards.length),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: _loadGlobalCards,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _globalCards.length,
            itemBuilder: (context, index) {
              final card = _globalCards[index];
              return CardTile(
                card: card,
                onTap: () => _showCardActions(card),
                onLongPress: () => _showCardActions(card),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCardActions(CardModel card) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                card.name,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final dialogL10n = AppLocalizations.of(context)!;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.download,
                          color: Colors.green,
                        ),
                        title: Text(dialogL10n.importCard),
                        subtitle: Text(dialogL10n.importCardDescription),
                        onTap: () {
                          Navigator.pop(context);
                          _importCard(card);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete, color: Colors.red),
                        title: Text(dialogL10n.deleteFromGlobalPool),
                        subtitle: Text(
                          dialogL10n.deleteFromGlobalPoolDescription,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteConfirmation(card);
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(CardModel card) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final dialogL10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(dialogL10n.deleteGlobalCard),
          content: Text(dialogL10n.deleteGlobalCardConfirm(card.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(dialogL10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteGlobalCard(card);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              child: Text(dialogL10n.delete),
            ),
          ],
        );
      },
    );
  }
}
