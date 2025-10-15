import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sync_settings_model.dart';
import '../../services/sync_settings_service.dart';
import '../../services/preferences_sync_service.dart';
import '../../services/connection_manager.dart';
import '../../providers/card_provider.dart';
import '../../providers/display_provider.dart';
import '../../providers/tag_provider.dart';
import '../../l10n/app_localizations.dart';

class SyncSettingsTab extends StatefulWidget {
  const SyncSettingsTab({super.key});

  @override
  State<SyncSettingsTab> createState() => _SyncSettingsTabState();
}

class _SyncSettingsTabState extends State<SyncSettingsTab> {
  final SyncSettingsService _syncService = SyncSettingsService();
  final ConnectionManager _connectionManager = ConnectionManager();
  final _serverController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isConnected = false;
  bool _globalFolderAvailable = false;
  bool _useParallelSync = true; // Default to parallel (faster)
  DateTime? _lastSyncDate;
  String? _loadingOperation; // Track which operation is loading

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _serverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = await _syncService.loadSettings();
    if (settings != null) {
      setState(() {
        _serverController.text = settings.serverAddress ?? '';
        _usernameController.text = settings.username ?? '';
        _passwordController.text = settings.password ?? '';
        _lastSyncDate = settings.lastSyncDate;
        _globalFolderAvailable = settings.globalFolderAvailable;
        _useParallelSync = settings.useParallelSync;
        // Use connection manager's status instead of stored status
        _isConnected = _connectionManager.isConnected;
      });
    } else {
      setState(() {
        _isConnected = _connectionManager.isConnected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show configuration summary if everything is set up
          if (_canSync()) ...[
            _buildConfigurationSummaryCard(),
            const SizedBox(height: 24),
            _buildSyncActionsSection(),
          ] else ...[
            // Show setup forms if not fully configured
            _buildConnectionStatusCard(),
            const SizedBox(height: 24),
            _buildConnectionSettingsSection(),
          ],
        ],
      ),
    );
  }

  bool _canSync() {
    return _isConnected;
  }

  Future<void> _testConnection() async {
    if (_serverController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fillAllConnectionFields)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final settings = SyncSettingsModel(
        serverAddress: _serverController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        useParallelSync: _useParallelSync,
      );

      final success = await _syncService.testConnection(settings);
      
      // Reload settings to get updated global folder status
      final updatedSettings = await _syncService.loadSettings();
      
      setState(() {
        _isConnected = success;
        _globalFolderAvailable = updatedSettings?.globalFolderAvailable ?? false;
      });

      // Update connection manager with new settings and status
      if (success && updatedSettings != null) {
        await _connectionManager.updateSettings(updatedSettings);
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final messageText = success ? l10n.connectionSuccessful.toString() : l10n.connectionFailed.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(messageText),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        
        // Show global folder status
        if (success) {
          if (_globalFolderAvailable) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.globalFolderDetected),
                backgroundColor: Colors.blue,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.globalFolderNotFound),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
      });
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.connectionError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatLastSync(DateTime date, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return l10n.daysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return l10n.minutesAgo(difference.inMinutes);
    } else {
      return l10n.justNow;
    }
  }

  Widget _buildConfigurationSummaryCard() {
    return Card(
      // Let theme handle elevation
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_done, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.serverConfiguration,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.readyForSync,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Column(
                  children: [
                    _buildInfoRow(l10n.server, _serverController.text, Icons.dns),
                    const SizedBox(height: 8),
                    _buildInfoRow(l10n.username, _usernameController.text, Icons.person),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      l10n.globalFeatures,
                      _globalFolderAvailable ? l10n.enabled : l10n.disabled,
              _globalFolderAvailable ? Icons.check_circle : Icons.warning,
                    ),
                  ],
                );
              },
            ),
            if (_lastSyncDate != null) ...[
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return _buildInfoRow(
                    l10n.lastSync,
                    _formatLastSync(_lastSyncDate!, context),
                    Icons.sync,
                  );
                },
              ),
            ],
            if (!_globalFolderAvailable) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return Text(
                            l10n.createGlobalFolderHint,
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Divider(height: 24),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.parallelSync),
                  subtitle: Text(l10n.parallelSyncDescription),
                  value: _useParallelSync,
                  onChanged: (value) async {
                    setState(() {
                      _useParallelSync = value;
                    });
                    // Save immediately
                    final currentSettings = await _syncService.loadSettings();
                    if (currentSettings != null) {
                      final updatedSettings = currentSettings.copyWith(
                        useParallelSync: value,
                      );
                      await _syncService.saveSettings(updatedSettings);
                    }
                  },
                  secondary: Icon(
                    _useParallelSync ? Icons.fast_forward : Icons.play_arrow,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon, 
          size: 20, 
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              _isConnected ? Icons.cloud_done : Icons.cloud_off,
              color: _isConnected ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Text(
                        _isConnected ? l10n.connected : l10n.notConnected,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _isConnected ? Colors.green : Colors.red,
                        ),
                      );
                    },
                  ),
                  if (_lastSyncDate != null)
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return Text(
                          l10n.lastSyncLabel(_formatLastSync(_lastSyncDate!, context)),
                          style: Theme.of(context).textTheme.bodySmall,
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

  Widget _buildConnectionSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)!.webdavConnection,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Column(
              children: [
                TextField(
                  controller: _serverController,
                  decoration: InputDecoration(
                    labelText: l10n.serverAddress,
                    hintText: l10n.serverAddressHint,
                    helperText: 'Include protocol (https://) and port if needed',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: l10n.username,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _testConnection,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isConnected ? Colors.green : null,
              foregroundColor: _isConnected ? Colors.white : null,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isConnected ? AppLocalizations.of(context)!.connectedCheck : AppLocalizations.of(context)!.testConnection),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)!.syncActions,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _canSync() && !_isLoading ? _exportCards : null,
                icon: _isLoading && _loadingOperation == 'export'
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Text(_isLoading && _loadingOperation == 'export' 
                        ? l10n.exporting
                        : l10n.exportCards);
                  },
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _canSync() && !_isLoading ? _importCards : null,
                icon: _isLoading && _loadingOperation == 'import'
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.cloud_download),
                label: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Text(_isLoading && _loadingOperation == 'import' 
                        ? l10n.importing
                        : l10n.importCards);
                  },
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Disconnect button
        Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _isLoading ? null : _disconnect,
                icon: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.error,
                ),
                label: Text(l10n.disconnectAndChangeServer),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _disconnect() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final dialogL10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(dialogL10n.disconnectFromServer),
          content: Text(dialogL10n.disconnectConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(dialogL10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: Text(dialogL10n.disconnectFromServer),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Handle disconnection using connection manager
      setState(() {
        _isConnected = false;
      });
      
      // Disconnect through connection manager
      await _connectionManager.disconnect();
      
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.disconnectedSuccessfully),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _exportCards() async {
    setState(() {
      _isLoading = true;
      _loadingOperation = 'export';
    });

    try {
      // Initialize WebDAV client if needed
      await _syncService.initializeFromSettings();
      
      if (!mounted) return;
      
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      final cards = cardProvider.cards;
      final deletedCards = cardProvider.deletedCards;
      
      if (cards.isEmpty && deletedCards.isEmpty) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.noCardsToSync),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Handle deleted cards first
      if (deletedCards.isNotEmpty) {
        await _syncService.handleDeletedCards(deletedCards);
        
        // Permanently delete cards locally after successful server deletion
        for (final card in deletedCards) {
          await cardProvider.permanentlyDeleteCard(card.uuid);
        }
      }

      // Export active cards
      if (cards.isNotEmpty) {
        await _syncService.exportCards(cards);
      }
      
      // Update sync status (success)
      final now = DateTime.now();
      final currentSettings = await _syncService.loadSettings();
      if (currentSettings != null) {
        final updatedSettings = currentSettings.copyWith(
          lastSyncDate: now,
          lastSyncAttempt: now,
          lastSyncSuccess: true,
          lastSyncError: null,
        );
        await _syncService.saveSettings(updatedSettings);
        await _connectionManager.refreshSyncStatus();
        setState(() {
          _lastSyncDate = now;
        });
      }

      // Also sync preferences
      if (mounted) {
        final displayProvider = Provider.of<DisplayProvider>(context, listen: false);
        final tagProvider = Provider.of<TagProvider>(context, listen: false);
        final cardProvider = Provider.of<CardProvider>(context, listen: false);
        
        await cardProvider.syncPreferences(
          displaySettings: displayProvider.exportSettings(),
          tagOrder: tagProvider.exportTagOrder(),
        );
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final message = deletedCards.isNotEmpty 
          ? l10n.syncSuccessWithCleanup(cards.length, deletedCards.length)
          : l10n.syncSuccessExport(cards.length);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Update sync status (failure)
      final now = DateTime.now();
      final currentSettings = await _syncService.loadSettings();
      if (currentSettings != null) {
        final updatedSettings = currentSettings.copyWith(
          lastSyncAttempt: now,
          lastSyncSuccess: false,
          lastSyncError: e.toString(),
        );
        await _syncService.saveSettings(updatedSettings);
        await _connectionManager.refreshSyncStatus();
      }
      
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.syncFailed}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingOperation = null;
        });
      }
    }
  }

  Future<void> _importCards() async {
    setState(() {
      _isLoading = true;
      _loadingOperation = 'import';
    });

    try {
      // Initialize WebDAV client if needed
      await _syncService.initializeFromSettings();
      
      final importedCards = await _syncService.importCards();
      
      if (importedCards.isEmpty) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.noCardsToImport),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      if (!mounted) return;
      
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      
      // Ensure cards are loaded before checking for duplicates
      await cardProvider.loadCards();
      
      int imported = 0;
      int updated = 0;

      for (final card in importedCards) {
        final existingCard = cardProvider.allCards.where((c) => c.uuid == card.uuid).firstOrNull;
        debugPrint('Checking card ${card.uuid}: existing=${existingCard != null}');
        if (existingCard != null) {
          debugPrint('Updating existing card: ${card.name}');
          await cardProvider.updateCard(card);
          updated++;
        } else {
          debugPrint('Adding new card: ${card.name}');
          await cardProvider.addCard(card);
          imported++;
        }
      }

      // Also import preferences
      final prefsSync = PreferencesSyncService();
      final preferences = await prefsSync.downloadPreferences();
      
      if (!mounted) return;
      
      if (preferences != null) {
        final displayProvider = Provider.of<DisplayProvider>(context, listen: false);
        final tagProvider = Provider.of<TagProvider>(context, listen: false);
        
        // Import display settings
        final displaySettings = preferences['display_settings'] as Map<String, dynamic>?;
        if (displaySettings != null) {
          await displayProvider.importSettings(displaySettings);
        }
        
        // Import tag order
        final tagOrder = (preferences['tag_order'] as List?)?.cast<String>();
        if (tagOrder != null) {
          await tagProvider.importTagOrder(tagOrder);
        }
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.importComplete}: $imported ${l10n.newCards}, $updated ${l10n.updated}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.importFailed}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingOperation = null;
        });
      }
    }
  }
}
