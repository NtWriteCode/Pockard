import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_model.dart';
import '../services/database_service.dart';
import '../services/image_service.dart';
import '../services/sync_settings_service.dart';
import '../services/preferences_sync_service.dart';
import '../services/connection_manager.dart';

class CardProvider with ChangeNotifier {
  static const String _sortByKey = 'card_sort_by';

  final DatabaseService _databaseService = DatabaseService();
  final ImageService _imageService = ImageService();
  final SyncSettingsService _syncService = SyncSettingsService();
  final ConnectionManager _connectionManager = ConnectionManager();

  List<CardModel> _cards = [];
  List<String> _allTags = [];
  String _selectedTag = '';
  String _searchQuery = '';
  String _sortBy = 'recent'; // recent, usage, name, date_added
  CardCategory _filterCategory = CardCategory.loyalty;

  List<CardModel> get cards {
    List<CardModel> filteredCards = _cards.where((card) => !card.isDeleted && card.category == _filterCategory).toList();

    // Apply tag filter
    if (_selectedTag.isNotEmpty) {
      filteredCards = filteredCards.where((card) => card.tags.contains(_selectedTag)).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredCards = filteredCards.where((card) => card.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'usage':
        filteredCards.sort((a, b) {
          // Pinned cards always come first
          if (a.isPinned != b.isPinned) {
            return b.isPinned ? 1 : -1;
          }
          return b.usageCount.compareTo(a.usageCount);
        });
        break;
      case 'recent':
        filteredCards.sort((a, b) {
          // Pinned cards always come first
          if (a.isPinned != b.isPinned) {
            return b.isPinned ? 1 : -1;
          }
          return b.updateDate.compareTo(a.updateDate);
        });
        break;
      case 'name':
        filteredCards.sort((a, b) {
          // Pinned cards always come first
          if (a.isPinned != b.isPinned) {
            return b.isPinned ? 1 : -1;
          }
          // Case-insensitive alphabetical sorting
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case 'date_added':
        filteredCards.sort((a, b) {
          // Pinned cards always come first
          if (a.isPinned != b.isPinned) {
            return b.isPinned ? 1 : -1;
          }
          return b.creationDate.compareTo(a.creationDate);
        });
        break;
    }

    return filteredCards;
  }

  List<String> get allTags => _allTags;
  String get selectedTag => _selectedTag;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;

  List<CardModel> get allCards => _cards;
  List<CardModel> get deletedCards => _cards.where((card) => card.isDeleted).toList();

  Future<void> loadCards() async {
    try {
      _cards = await _databaseService.getAllCards();
      await _loadTags();
      await _loadSortPreference();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cards: $e');
    }
  }

  Future<void> _loadSortPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _sortBy = prefs.getString(_sortByKey) ?? 'recent';
    } catch (e) {
      debugPrint('Error loading sort preference: $e');
    }
  }

  Future<void> _loadTags() async {
    try {
      _allTags = await _databaseService.getAllTags(category: _filterCategory);
    } catch (e) {
      debugPrint('Error loading tags: $e');
    }
  }

  Future<bool> addCard(CardModel card) async {
    try {
      await _databaseService.insertCard(card);
      _cards.add(card);
      await _loadTags();
      notifyListeners();

      // Auto-sync to WebDAV (silently fail if unavailable)
      _autoSync();

      return true;
    } catch (e) {
      debugPrint('Error adding card: $e');
      return false;
    }
  }

  Future<bool> updateCard(CardModel card) async {
    try {
      await _databaseService.updateCard(card);
      final index = _cards.indexWhere((c) => c.uuid == card.uuid);
      if (index != -1) {
        _cards[index] = card;
      }
      await _loadTags();
      notifyListeners();

      // Auto-sync to WebDAV (silently fail if unavailable)
      _autoSync();

      return true;
    } catch (e) {
      debugPrint('Error updating card: $e');
      return false;
    }
  }

  Future<bool> permanentlyDeleteCard(String uuid) async {
    try {
      final card = _cards.firstWhere((c) => c.uuid == uuid);

      // Delete associated images if they exist
      if (card.coverImagePath != null) {
        await _imageService.deleteImage(card.coverImagePath!);
      }
      if (card.barcodeImagePath != null) {
        await _imageService.deleteImage(card.barcodeImagePath!);
      }
      if (card.backImagePath != null) {
        await _imageService.deleteImage(card.backImagePath!);
      }

      await _databaseService.deleteCard(uuid);
      _cards.removeWhere((c) => c.uuid == uuid);
      await _loadTags();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error permanently deleting card: $e');
      return false;
    }
  }

  Future<bool> deleteCard(String uuid) async {
    try {
      final cardIndex = _cards.indexWhere((c) => c.uuid == uuid);
      if (cardIndex == -1) return false;

      final card = _cards[cardIndex];

      // Soft delete: mark as deleted instead of removing
      final deletedCard = card.copyWith(isDeleted: true);
      _cards[cardIndex] = deletedCard;

      // Update in database
      await _databaseService.updateCard(deletedCard);

      await _loadTags();
      notifyListeners();

      // Auto-sync to WebDAV (silently fail if unavailable)
      _autoSync();

      return true;
    } catch (e) {
      debugPrint('Error deleting card: $e');
      return false;
    }
  }

  Future<void> incrementCardUsage(String uuid) async {
    try {
      await _databaseService.incrementCardUsage(uuid);
      final index = _cards.indexWhere((c) => c.uuid == uuid);
      if (index != -1) {
        final newUsageCount = _cards[index].usageCount + 1;
        _cards[index] = _cards[index].copyWith(usageCount: newUsageCount, updateDate: DateTime.now());
        notifyListeners();

        // Auto-sync every 5 usages to save on network requests
        if (newUsageCount % 5 == 0) {
          _autoSync();
        }
      }
    } catch (e) {
      debugPrint('Error incrementing card usage: $e');
    }
  }

  Future<void> resetAllStatistics() async {
    try {
      await _databaseService.resetAllStatistics();
      // Reload cards to reflect the reset statistics
      for (int i = 0; i < _cards.length; i++) {
        _cards[i] = _cards[i].copyWith(usageCount: 0);
      }
      notifyListeners();

      // Auto-sync to WebDAV (silently fail if unavailable)
      _autoSync();
    } catch (e) {
      debugPrint('Error resetting statistics: $e');
      rethrow;
    }
  }

  Future<void> toggleCardPin(String uuid) async {
    try {
      final index = _cards.indexWhere((c) => c.uuid == uuid);
      if (index != -1) {
        final newPinState = !_cards[index].isPinned;
        await _databaseService.toggleCardPin(uuid, newPinState);
        _cards[index] = _cards[index].copyWith(isPinned: newPinState);
        notifyListeners();

        // Auto-sync to WebDAV (silently fail if unavailable)
        _autoSync();
      }
    } catch (e) {
      debugPrint('Error toggling pin: $e');
      rethrow;
    }
  }

  void setSelectedTag(String tag) {
    _selectedTag = tag;
    notifyListeners();
  }

  void clearTagFilter() {
    _selectedTag = '';
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterCategory(CardCategory category) {
    _filterCategory = category;
    notifyListeners();
  }

  CardCategory get filterCategory => _filterCategory;

  Future<void> setSortBy(String sortBy) async {
    _sortBy = sortBy;
    notifyListeners();

    // Save the preference
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sortByKey, sortBy);
    } catch (e) {
      debugPrint('Error saving sort preference: $e');
    }
  }

  CardModel? getCardById(String uuid) {
    try {
      return _cards.firstWhere((card) => card.uuid == uuid);
    } catch (e) {
      return null;
    }
  }

  List<CardModel> getCardsByTag(String tag) {
    return _cards.where((card) => card.tags.contains(tag)).toList();
  }

  Future<void> cleanupUnusedImages() async {
    final usedImagePaths = <String>[];

    // Collect all used image paths (cover + barcode)
    for (final card in _cards) {
      if (card.coverImagePath != null) {
        usedImagePaths.add(card.coverImagePath!);
      }
      if (card.barcodeImagePath != null) {
        usedImagePaths.add(card.barcodeImagePath!);
      }
    }

    await _imageService.cleanupUnusedImages(usedImagePaths);
  }

  /// Manual sync triggered by user (reuses auto-sync logic)
  Future<void> triggerSync() async {
    await _autoSync();
  }

  /// Sync user preferences (display settings and tag order) to server
  /// This should be called by the UI when preferences change
  Future<void> syncPreferences({required Map<String, dynamic> displaySettings, required dynamic tagOrder}) async {
    debugPrint('CardProvider: Starting preferences sync...');
    final attemptTime = DateTime.now();

    try {
      // Check if sync is configured
      final settings = await _syncService.loadSettings();
      if (settings == null || !settings.hasCredentials) {
        debugPrint('CardProvider: Preferences sync skipped: No WebDAV credentials configured');
        return;
      }
      debugPrint('CardProvider: WebDAV credentials found, proceeding with sync');

      // Initialize WebDAV client
      final initialized = await _syncService.initializeFromSettings();
      if (!initialized) {
        debugPrint('CardProvider: Preferences sync failed: Could not initialize WebDAV client');

        // Record failed attempt
        final updatedSettings = settings.copyWith(lastSyncAttempt: attemptTime, lastSyncSuccess: false, lastSyncError: 'Failed to initialize WebDAV client for preferences sync');
        await _syncService.saveSettings(updatedSettings);
        await _connectionManager.refreshSyncStatus();
        return;
      }
      debugPrint('CardProvider: WebDAV client initialized successfully');

      final prefsSync = PreferencesSyncService();
      await prefsSync.uploadPreferences(displaySettings: displaySettings, tagOrder: tagOrder);

      // Record successful preferences sync
      final updatedSettings = settings.copyWith(lastSyncAttempt: attemptTime, lastSyncSuccess: true, lastSyncError: null);
      await _syncService.saveSettings(updatedSettings);
      await _connectionManager.refreshSyncStatus();

      debugPrint('CardProvider: Preferences synced successfully');
    } catch (e) {
      debugPrint('CardProvider: Error syncing preferences: $e');

      // Record failed preferences sync
      try {
        final settings = await _syncService.loadSettings();
        if (settings != null) {
          final updatedSettings = settings.copyWith(lastSyncAttempt: attemptTime, lastSyncSuccess: false, lastSyncError: 'Preferences sync failed: $e');
          await _syncService.saveSettings(updatedSettings);
          await _connectionManager.refreshSyncStatus();
        }
      } catch (saveError) {
        debugPrint('CardProvider: Failed to save preferences sync error: $saveError');
      }
      // Don't rethrow - preferences sync is non-critical
    }
  }

  /// Auto-sync cards to WebDAV (silently fail if unavailable)
  Future<void> _autoSync() async {
    final attemptTime = DateTime.now();

    try {
      // Check if sync is configured
      final settings = await _syncService.loadSettings();
      if (settings == null || !settings.hasCredentials) {
        debugPrint('Auto-sync skipped: No WebDAV credentials configured');
        // Don't record this as a failed attempt - sync is not configured
        return;
      }

      // Initialize WebDAV client
      final initialized = await _syncService.initializeFromSettings();
      if (!initialized) {
        final error = 'Failed to initialize WebDAV client'; // Internal error, not shown to user
        debugPrint('Auto-sync failed: $error');

        // Record failed attempt
        final updatedSettings = settings.copyWith(lastSyncAttempt: attemptTime, lastSyncSuccess: false, lastSyncError: error);
        await _syncService.saveSettings(updatedSettings);

        // Refresh connection manager to update UI
        await _connectionManager.refreshSyncStatus();
        return;
      }

      // Get all cards (active and deleted) for sync
      final allCardsToSync = List<CardModel>.from(_cards);

      // Handle deleted cards: We no longer hard delete them. 
      // Instead, they are included in 'allCardsToSync' and uploaded as Tombstones (isDeleted: true).
      // The Database Manager allows permanent deletion if desired.

      // Export active cards using manifest-based approach
      // Also perform import first as part of "two-way" sync logic
      final syncResult = await _syncService.importCardsWithManifest();
      
      // Auto-sync strategy:
      // 1. Import all updates from server
      for (final card in syncResult.importedCards) {
        final existingCard = _cards.indexWhere((c) => c.uuid == card.uuid);
        if (existingCard != -1) {
          await _databaseService.updateCard(card);
          _cards[existingCard] = card;
        } else {
          await _databaseService.insertCard(card);
          _cards.add(card);
        }
      }
      
      // 2. Ignore deletionCandidates (Keep local copies). They will be uploaded in the export step below.
      // This ensures auto-sync never deletes data silently.
      
      await _loadTags(); // Refresh tags after potential imports
      notifyListeners();

      if (allCardsToSync.isNotEmpty) {
        await _syncService.exportCards(allCardsToSync);
      }

      // Record successful sync
      final updatedSettings = settings.copyWith(lastSyncDate: attemptTime, lastSyncAttempt: attemptTime, lastSyncSuccess: true, lastSyncError: null);
      await _syncService.saveSettings(updatedSettings);

      // Refresh connection manager to update UI
      await _connectionManager.refreshSyncStatus();

      debugPrint('Auto-sync completed successfully');
    } catch (e) {
      // Record failed sync with error details
      debugPrint('Auto-sync failed: $e');

      try {
        final settings = await _syncService.loadSettings();
        if (settings != null) {
          final updatedSettings = settings.copyWith(lastSyncAttempt: attemptTime, lastSyncSuccess: false, lastSyncError: e.toString());
          await _syncService.saveSettings(updatedSettings);

          // Refresh connection manager to update UI
          await _connectionManager.refreshSyncStatus();
        }
      } catch (saveError) {
        debugPrint('Failed to save sync error status: $saveError');
      }
    }
  }
}
