import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../providers/card_provider.dart';
import '../providers/tag_provider.dart';
import '../models/card_model.dart';
import '../widgets/card_tile.dart';
import '../widgets/tag_chip.dart';
import 'card_form_screen.dart';
import 'settings/settings_screen.dart';
import 'fullscreen_barcode_screen.dart';
import 'fullscreen_cover_image_screen.dart';
import 'global_screen.dart';
import '../services/connection_manager.dart';
import '../providers/display_provider.dart';
import '../widgets/card_grid_tile.dart';
import '../widgets/card_minimal_tile.dart';

class MainScreen extends StatefulWidget {
  final CardCategory category;
  
  const MainScreen({
    super.key, 
    this.category = CardCategory.loyalty,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final ConnectionManager _connectionManager = ConnectionManager();
  bool _isSearchVisible = false;
  String _localSearchQuery = '';
  String _localSelectedTag = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      cardProvider.loadCards();
      Provider.of<TagProvider>(context, listen: false).loadTags(category: widget.category);
      // Trigger a rebuild when connection status changes
      _connectionManager.syncStatus.listen((_) {
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildConnectionStatusIndicator() {
    // Check if sync is configured (has credentials)
    final settings = _connectionManager.syncSettings;
    final isSyncConfigured = settings != null && settings.hasCredentials;

    // Hide indicator if sync is not configured
    if (!isSyncConfigured) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<bool>(
      stream: _connectionManager.syncStatus,
      initialData: _connectionManager.lastSyncSuccess,
      builder: (context, snapshot) {
        final syncSuccess = snapshot.data ?? true;
        final isConnected = _connectionManager.isConnected;

        Color dotColor;
        if (!isConnected) {
          dotColor = const Color(0xFFFF9800); // Orange = not connected
        } else if (syncSuccess) {
          dotColor = const Color(0xFF81C784); // Light green = last sync succeeded
        } else {
          dotColor = const Color(0xFFEF5350); // Light red = last sync failed
        }

        return InkWell(
          onTap: () => _showSyncStatusDialog(context),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Icon(Icons.circle, size: 8, color: dotColor),
          ),
        );
      },
    );
  }

  void _showSyncStatusDialog(BuildContext context) async {
    final settings = _connectionManager.syncSettings;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_connectionManager.lastSyncSuccess ? Icons.check_circle : Icons.error, color: _connectionManager.lastSyncSuccess ? Colors.green : Colors.red),
            const SizedBox(width: 8),
            Text(l10n.syncStatusDialogTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (settings == null || !settings.hasCredentials) ...[
              Text(l10n.syncNotConfigured),
              const SizedBox(height: 8),
              Text(l10n.syncNotConfiguredHint),
            ] else ...[
              _buildStatusRow(
                l10n.connectionStatus,
                _connectionManager.isConnected ? l10n.connected : l10n.notConnected,
                textColor: _connectionManager.isConnected ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 8),
              _buildStatusRow(l10n.syncStatusLastAttempt, settings.lastSyncAttempt != null ? _formatDateTime(settings.lastSyncAttempt!, context) : l10n.syncStatusNever),
              const SizedBox(height: 8),
              _buildStatusRow(l10n.syncStatusLastSuccess, settings.lastSyncDate != null ? _formatDateTime(settings.lastSyncDate!, context) : l10n.syncStatusNever),
              const SizedBox(height: 8),
              _buildStatusRow(
                l10n.status,
                _connectionManager.lastSyncSuccess ? '${l10n.success} ✓' : '${l10n.error} ✗',
                textColor: _connectionManager.lastSyncSuccess ? Colors.green : Colors.red,
              ),
              if (!_connectionManager.lastSyncSuccess && settings.lastSyncError != null) ...[
                const SizedBox(height: 12),
                Text(l10n.syncStatusError, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                SelectableText(
                  settings.lastSyncError!,
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                  textAlign: TextAlign.justify,
                ),
              ],
            ],
          ],
        ),
        actions: [
          Row(
            children: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.close)),
              const Spacer(),
              if (settings != null && settings.hasCredentials)
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    // Show loading indicator
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(l10n.syncing),
                        duration: const Duration(days: 1), // Keep it up indefinitely
                      ),
                    );

                    try {
                      // Trigger sync
                      final cardProvider = Provider.of<CardProvider>(context, listen: false);
                      await cardProvider.triggerSync();
                      // Show result
                      if (context.mounted) {
                        final updatedSettings = _connectionManager.syncSettings;
                        final success = updatedSettings?.lastSyncSuccess ?? false;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(success ? l10n.syncCompletedSuccess : l10n.syncFailed),
                            backgroundColor: success ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                    } finally {
                      // ALWAYS hide loading indicator, even if an exception occurs
                      messenger.hideCurrentSnackBar();
                    }
                  },
                  icon: const Icon(Icons.sync),
                  label: Text(l10n.syncNow),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, {Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
        Flexible(
          child: Text(
            value,
            style: TextStyle(color: textColor),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inMinutes < 60) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return DateFormat('MMM dd').format(dateTime);
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: _buildConnectionStatusIndicator(),
        title: _isSearchVisible
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.search,
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.6)),
                ),
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                onChanged: (query) {
                  setState(() {
                    _localSearchQuery = query;
                  });
                },
              )
            : Text(l10n.appName),
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearchVisible) {
                  _searchController.clear();
                  _localSearchQuery = '';
                }
                _isSearchVisible = !_isSearchVisible;
              });
            },
          ),
          Consumer<CardProvider>(
            builder: (context, cardProvider, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                onSelected: (value) {
                  cardProvider.setSortBy(value);
                },
                itemBuilder: (context) {
                  final currentSort = cardProvider.sortBy;
                  return [
                    PopupMenuItem(
                      value: 'recent',
                      child: Row(
                        children: [
                          Icon(Icons.access_time, size: 18, color: Theme.of(context).colorScheme.onSurface),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(l10n.sortRecent, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                          ),
                          if (currentSort == 'recent') Icon(Icons.check, size: 20, color: Theme.of(context).colorScheme.primary),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'usage',
                      child: Row(
                        children: [
                          Icon(Icons.trending_up, size: 18, color: Theme.of(context).colorScheme.onSurface),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(l10n.sortUsage, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                          ),
                          if (currentSort == 'usage') Icon(Icons.check, size: 20, color: Theme.of(context).colorScheme.primary),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'name',
                      child: Row(
                        children: [
                          Icon(Icons.sort_by_alpha, size: 18, color: Theme.of(context).colorScheme.onSurface),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(l10n.sortName, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                          ),
                          if (currentSort == 'name') Icon(Icons.check, size: 20, color: Theme.of(context).colorScheme.primary),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'date_added',
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 18, color: Theme.of(context).colorScheme.onSurface),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(l10n.sortDateAdded, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                          ),
                          if (currentSort == 'date_added') Icon(Icons.check, size: 20, color: Theme.of(context).colorScheme.primary),
                        ],
                      ),
                    ),
                  ];
                },
              );
            },
          ),
          if (widget.category != CardCategory.identity)
            IconButton(
              icon: const Icon(Icons.public),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const GlobalScreen()));
                if (!context.mounted) return;
                Provider.of<TagProvider>(context, listen: false).loadTags(category: widget.category);
              },
              tooltip: l10n.globalPool,
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              if (!context.mounted) return;
              Provider.of<TagProvider>(context, listen: false).loadTags(category: widget.category);
            },
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: Consumer3<CardProvider, TagProvider, DisplayProvider>(
        builder: (context, cardProvider, tagProvider, displayProvider, child) {
          // 1. Get all cards for this category
          final cardsForCategory = cardProvider.allCards.where((c) => !c.isDeleted && c.category == widget.category).toList();

          // 2. Extract tags for this category from the cards
          final categoryTags = <String>{};
          for (final card in cardsForCategory) {
            categoryTags.addAll(card.tags);
          }

          // 3. Match with ordered tags from TagProvider
          final displayTags = tagProvider.orderedTags.where((t) => categoryTags.contains(t)).toList();

          // 4. Apply local filters to cards
          List<CardModel> filteredCards = List.from(cardsForCategory);

          // Apply tag filter
          if (_localSelectedTag.isNotEmpty) {
            filteredCards = filteredCards.where((card) => card.tags.contains(_localSelectedTag)).toList();
          }

          // Apply search filter
          if (_localSearchQuery.isNotEmpty) {
            filteredCards = filteredCards.where((card) => card.name.toLowerCase().contains(_localSearchQuery.toLowerCase())).toList();
          }

          // Apply sorting (mimic Provider logic)
          _applySorting(filteredCards, cardProvider.sortBy);

          return Column(
            children: [
              // Tags section
              if (displayTags.isNotEmpty)
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: displayTags.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: TagChip(
                            tag: l10n.filterAll,
                            isSelected: _localSelectedTag.isEmpty,
                            onTap: () => setState(() => _localSelectedTag = ''),
                          ),
                        );
                      }

                      final tag = displayTags[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: TagChip(
                          tag: tag,
                          isSelected: _localSelectedTag == tag,
                          onTap: () => setState(() => _localSelectedTag = tag),
                        ),
                      );
                    },
                  ),
                ),

              // Cards list/grid
              Expanded(child: filteredCards.isEmpty ? _buildEmptyState(context) : _buildCardsLayout(context, filteredCards, displayProvider)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'main_fab_${widget.category.name}',
        onPressed: () => _navigateToAddCard(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCardsLayout(BuildContext context, List<CardModel> filteredCards, DisplayProvider displayProvider) {

    switch (displayProvider.layoutMode) {
      case LayoutMode.rows:
        // Standard row layout with full details
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: filteredCards.length,
          itemBuilder: (context, index) {
            final card = filteredCards[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: CardTile(card: card, onTap: () => _navigateToFullscreenBarcode(context, card), onLongPress: () => _navigateToCardDetail(context, card)),
            );
          },
        );

      case LayoutMode.minimal:
        // Ultra-compact minimal layout
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: filteredCards.length,
          itemBuilder: (context, index) {
            final card = filteredCards[index];
            return CardMinimalTile(card: card, onTap: () => _navigateToFullscreenBarcode(context, card), onLongPress: () => _navigateToCardDetail(context, card));
          },
        );

      case LayoutMode.grid:
        // Grid layout with image tiles
        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: displayProvider.gridColumns,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            // Use 1.0 (square) when names are hidden, 0.85 when names are shown
            childAspectRatio: displayProvider.showGridNames ? 0.85 : 1.0,
          ),
          itemCount: filteredCards.length,
          itemBuilder: (context, index) {
            final card = filteredCards[index];
            return CardGridTile(
              card: card,
              onTap: () => _navigateToFullscreenBarcode(context, card),
              onLongPress: () => _navigateToCardDetail(context, card),
              showName: displayProvider.showGridNames,
            );
          },
        );
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final isLoyalty = widget.category == CardCategory.loyalty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isLoyalty ? Icons.credit_card : Icons.badge_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            isLoyalty ? l10n.emptyCardsTitle : l10n.emptyIdentityTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            isLoyalty ? l10n.emptyCardsMessage : l10n.emptyIdentityMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddCard(context),
            icon: const Icon(Icons.add),
            label: Text(isLoyalty ? l10n.addCard : l10n.addIdentityCard),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          ),
        ],
      ),
    );
  }

  void _navigateToFullscreenBarcode(BuildContext context, CardModel card) async {
    // Check if card has "Image Only" type - show cover image instead
    if (card.barcodeType == 'IMAGE_ONLY') {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => FullscreenCoverImageScreen(card: card)));
    } else {
      // Show barcode screen as usual
      await Navigator.push(context, MaterialPageRoute(builder: (context) => FullscreenBarcodeScreen(card: card)));
    }

    // Increment usage count when viewing card
    if (context.mounted) {
      Provider.of<CardProvider>(context, listen: false).incrementCardUsage(card.uuid);
    }
  }

  void _navigateToCardDetail(BuildContext context, CardModel card) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => CardFormScreen(card: card, category: widget.category)));

    if (!context.mounted) return;
    Provider.of<TagProvider>(context, listen: false).loadTags(category: widget.category);
    // Don't increment usage count when editing - only when viewing/using the card
  }

  void _navigateToAddCard(BuildContext context) async {
    final displayProvider = Provider.of<DisplayProvider>(context, listen: false);
    await Navigator.push(context, MaterialPageRoute(builder: (context) => CardFormScreen(autoStartCamera: displayProvider.autoOpenCamera, category: widget.category)));

    if (!context.mounted) return;
    Provider.of<TagProvider>(context, listen: false).loadTags(category: widget.category);
  }

  void _applySorting(List<CardModel> cards, String sortBy) {
    switch (sortBy) {
      case 'usage':
        cards.sort((a, b) => b.usageCount.compareTo(a.usageCount));
        break;
      case 'recent':
        cards.sort((a, b) => b.updateDate.compareTo(a.updateDate));
        break;
      case 'name':
        cards.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'date_added':
        cards.sort((a, b) => b.creationDate.compareTo(a.creationDate));
        break;
      default:
        cards.sort((a, b) => b.updateDate.compareTo(a.updateDate));
    }
  }
}
