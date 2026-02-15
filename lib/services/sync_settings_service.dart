import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_model.dart';
import '../models/sync_settings_model.dart';
import '../models/sync_manifest_model.dart';
import 'webdav_service.dart';
import 'database_service.dart';

class SyncResult {
  final List<CardModel> importedCards;
  final List<CardModel> deletionCandidates;

  SyncResult({required this.importedCards, required this.deletionCandidates});
}

/// Service responsible for sync settings and card synchronization via WebDAV
class SyncSettingsService {
  static final SyncSettingsService _instance = SyncSettingsService._internal();
  factory SyncSettingsService() => _instance;
  SyncSettingsService._internal();

  final WebDavService _webdavService = WebDavService();

  /// Load WebDAV settings from SharedPreferences
  Future<SyncSettingsModel?> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serverAddress = prefs.getString('webdav_server');
      final username = prefs.getString('webdav_username');
      final password = prefs.getString('webdav_password');
      final lastSyncTimestamp = prefs.getInt('last_sync_timestamp');
      final globalFolderAvailable = prefs.getBool('global_folder_available') ?? false;

      // Load new sync status fields
      final lastSyncAttemptTimestamp = prefs.getInt('last_sync_attempt_timestamp');
      final lastSyncSuccess = prefs.getBool('last_sync_success') ?? true;
      final lastSyncError = prefs.getString('last_sync_error');
      final useParallelSync = prefs.getBool('use_parallel_sync') ?? false;
      final pockardFolderPath = prefs.getString('pockard_folder_path') ?? '/pockard';
      final globalFolderPath = prefs.getString('global_folder_path') ?? '/pockard_global';

      if (serverAddress != null && username != null && password != null) {
        final settings = SyncSettingsModel(
          serverAddress: serverAddress,
          username: username,
          password: password,
          isConnected: false,
          lastSyncDate: lastSyncTimestamp != null ? DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp) : null,
          globalFolderAvailable: globalFolderAvailable,
          lastSyncAttempt: lastSyncAttemptTimestamp != null ? DateTime.fromMillisecondsSinceEpoch(lastSyncAttemptTimestamp) : null,
          lastSyncSuccess: lastSyncSuccess,
          lastSyncError: lastSyncError,
          useParallelSync: useParallelSync,
          pockardFolderPath: pockardFolderPath,
          globalFolderPath: globalFolderPath,
        );
        return settings;
      }
    } catch (e) {
      debugPrint('Error loading WebDAV settings: $e');
    }
    return null;
  }

  /// Save WebDAV settings to SharedPreferences
  Future<void> saveSettings(SyncSettingsModel settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('webdav_server', settings.serverAddress!);
      await prefs.setString('webdav_username', settings.username!);
      await prefs.setString('webdav_password', settings.password!);

      if (settings.lastSyncDate != null) {
        await prefs.setInt('last_sync_timestamp', settings.lastSyncDate!.millisecondsSinceEpoch);
      }

      await prefs.setBool('webdav_is_connected', settings.isConnected);
      await prefs.setBool('global_folder_available', settings.globalFolderAvailable);

      // Save new sync status fields
      if (settings.lastSyncAttempt != null) {
        await prefs.setInt('last_sync_attempt_timestamp', settings.lastSyncAttempt!.millisecondsSinceEpoch);
      }
      await prefs.setBool('last_sync_success', settings.lastSyncSuccess);
      if (settings.lastSyncError != null) {
        await prefs.setString('last_sync_error', settings.lastSyncError!);
      } else {
        await prefs.remove('last_sync_error'); // Clear error if null
      }
      await prefs.setBool('use_parallel_sync', settings.useParallelSync);
      await prefs.setString('pockard_folder_path', settings.pockardFolderPath);
      await prefs.setString('global_folder_path', settings.globalFolderPath);
    } catch (e) {
      debugPrint('Error saving WebDAV settings: $e');
    }
  }

  /// Test connection and initialize WebDAV client
  Future<bool> testConnection(SyncSettingsModel settings) async {
    try {
      _webdavService.initialize(settings.serverAddress!, settings.username!, settings.password!);

      final connected = await _webdavService.testConnection();

      if (connected) {
        // Create app directories
        await _webdavService.createAppDirectories(pockardPath: settings.pockardFolderPath);

        // Check if global folder is available
        final globalAvailable = await _webdavService.isGlobalFolderAvailable(globalPath: settings.globalFolderPath);

        // Update settings with global folder status
        final updatedSettings = settings.copyWith(isConnected: true, globalFolderAvailable: globalAvailable);
        await saveSettings(updatedSettings);

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error testing WebDAV connection: $e');
      return false;
    }
  }

  /// Import cards from WebDAV server (legacy method - use importCardsWithManifest instead)
  Future<List<CardModel>> _importCardsLegacy() async {
    if (!_webdavService.isInitialized) {
      throw Exception('WebDAV client not initialized');
    }

    final cards = <CardModel>[];
    final settings = await loadSettings();
    final pockardPath = settings?.pockardFolderPath ?? '/pockard';

    try {
      // List all JSON files in the cards directory
      final files = await _webdavService.listFiles('$pockardPath/cards');
      final jsonFiles = files.where((file) => file.endsWith('.json')).toList();

      for (final file in jsonFiles) {
        try {
          final remotePath = '$pockardPath/cards/$file';
          final bytes = await _webdavService.downloadFile(remotePath);

          final jsonString = utf8.decode(bytes);
          final cardData = json.decode(jsonString);

          var card = CardModel.fromMap(cardData);

          // Import cover image if the card indicates it has one
          if (card.coverImagePath == 'HAS_IMAGE') {
            try {
              final imageFileName = '${card.uuid}_cover.jpg';
              final imageRemotePath = '$pockardPath/images/$imageFileName';

              // Check if image exists on server
              final imageExists = await _webdavService.fileExists(imageRemotePath);
              if (imageExists) {
                // Download image to local storage
                final appDir = await getApplicationDocumentsDirectory();
                final imagesDir = Directory('${appDir.path}/images');
                if (!await imagesDir.exists()) {
                  await imagesDir.create(recursive: true);
                }

                final localImagePath = '${imagesDir.path}/${card.uuid}_cover.jpg';
                final imageBytes = await _webdavService.downloadFile(imageRemotePath);

                // Save image locally
                await File(localImagePath).writeAsBytes(imageBytes);

                // Update card with local image path
                card = card.copyWith(coverImagePath: localImagePath);
                debugPrint('Imported cover image for card ${card.uuid}: $localImagePath');
              } else {
                debugPrint('No cover image found for card ${card.uuid}');
                card = card.copyWith(coverImagePath: null);
              }
            } catch (e) {
              debugPrint('Error importing cover image for card ${card.uuid}: $e');
              card = card.copyWith(coverImagePath: null);
            }
          } else if (card.coverImagePath != null && card.coverImagePath != 'HAS_IMAGE') {
            // Handle legacy cards that might have absolute paths
            debugPrint('Found legacy absolute path for card ${card.uuid}, checking for image on server');
            try {
              final imageFileName = '${card.uuid}_cover.jpg';
              final imageRemotePath = '$pockardPath/images/$imageFileName';

              final imageExists = await _webdavService.fileExists(imageRemotePath);
              if (imageExists) {
                final appDir = await getApplicationDocumentsDirectory();
                final imagesDir = Directory('${appDir.path}/images');
                if (!await imagesDir.exists()) {
                  await imagesDir.create(recursive: true);
                }

                final localImagePath = '${imagesDir.path}/${card.uuid}_cover.jpg';
                final imageBytes = await _webdavService.downloadFile(imageRemotePath);

                await File(localImagePath).writeAsBytes(imageBytes);

                card = card.copyWith(coverImagePath: localImagePath);
                debugPrint('Imported legacy cover image for card ${card.uuid}: $localImagePath');
              } else {
                debugPrint('No cover image found for legacy card ${card.uuid}');
                card = card.copyWith(coverImagePath: null);
              }
            } catch (e) {
              debugPrint('Error importing legacy cover image for card ${card.uuid}: $e');
              card = card.copyWith(coverImagePath: null);
            }
          }

          // Import barcode image if the card indicates it has one
          if (card.barcodeImagePath == 'HAS_BARCODE_IMAGE') {
            try {
              final barcodeImageFileName = '${card.uuid}_barcode.jpg';
              final barcodeImageRemotePath = '$pockardPath/images/$barcodeImageFileName';

              // Check if barcode image exists on server
              final barcodeImageExists = await _webdavService.fileExists(barcodeImageRemotePath);
              if (barcodeImageExists) {
                // Download barcode image to local storage
                final appDir = await getApplicationDocumentsDirectory();
                final imagesDir = Directory('${appDir.path}/images');
                if (!await imagesDir.exists()) {
                  await imagesDir.create(recursive: true);
                }

                final localBarcodeImagePath = '${imagesDir.path}/${card.uuid}_barcode.jpg';
                final barcodeImageBytes = await _webdavService.downloadFile(barcodeImageRemotePath);

                // Save barcode image locally
                await File(localBarcodeImagePath).writeAsBytes(barcodeImageBytes);

                // Update card with local barcode image path
                card = card.copyWith(barcodeImagePath: localBarcodeImagePath);
                debugPrint('Imported barcode image for card ${card.uuid}: $localBarcodeImagePath');
              } else {
                debugPrint('No barcode image found for card ${card.uuid}');
                card = card.copyWith(barcodeImagePath: null);
              }
            } catch (e) {
              debugPrint('Error importing barcode image for card ${card.uuid}: $e');
              card = card.copyWith(barcodeImagePath: null);
            }
          }

          cards.add(card);
        } catch (e) {
          debugPrint('Error loading card $file: $e');
        }
      }
    } catch (e) {
      debugPrint('Error importing cards: $e');
    }

    return cards;
  }

  /// Handle deleted cards during sync - delete from server and clean up locally
  Future<void> handleDeletedCards(List<CardModel> deletedCards) async {
    if (!_webdavService.isInitialized) {
      throw Exception('WebDAV client not initialized');
    }

    final settings = await loadSettings();
    final pockardPath = settings?.pockardFolderPath ?? '/pockard';

    for (final card in deletedCards) {
      try {
        // Delete card JSON from server
        final remotePath = '$pockardPath/cards/${card.uuid}.json';
        final exists = await _webdavService.fileExists(remotePath);
        if (exists) {
          await _webdavService.deleteFile(remotePath);
          debugPrint('Deleted card from server: ${card.uuid}');
        } else {
          debugPrint('Card not found on server: ${card.uuid}');
        }

        // Delete cover image if it exists on server
        final imageFileName = '${card.uuid}_cover.jpg';
        final imageRemotePath = '$pockardPath/images/$imageFileName';
        final imageExists = await _webdavService.fileExists(imageRemotePath);
        if (imageExists) {
          await _webdavService.deleteFile(imageRemotePath);
          debugPrint('Deleted image from server: $imageFileName');
        } else {
          debugPrint('Image not found on server: $imageFileName');
        }

        // Delete barcode image if it exists on server
        final barcodeImageFileName = '${card.uuid}_barcode.jpg';
        final barcodeImageRemotePath = '$pockardPath/images/$barcodeImageFileName';
        final barcodeImageExists = await _webdavService.fileExists(barcodeImageRemotePath);
        if (barcodeImageExists) {
          await _webdavService.deleteFile(barcodeImageRemotePath);
          debugPrint('Deleted barcode image from server: $barcodeImageFileName');
        } else {
          debugPrint('Barcode image not found on server: $barcodeImageFileName');
        }
      } catch (e) {
        debugPrint('Error handling deleted card ${card.uuid}: $e');
      }
    }
  }

  /// Export cards to WebDAV server (legacy method - use exportCardsWithManifest instead)
  Future<void> _exportCardsLegacy(List<CardModel> cards) async {
    if (!_webdavService.isInitialized) {
      throw Exception('WebDAV client not initialized');
    }

    final settings = await loadSettings();
    final pockardPath = settings?.pockardFolderPath ?? '/pockard';

    try {
      // Ensure app directories exist
      await _webdavService.createAppDirectories(pockardPath: pockardPath);

      // Check if parallel sync is enabled
      final useParallel = settings?.useParallelSync ?? true;

      if (useParallel) {
        // Parallel upload with rate limiting to prevent overwhelming the server
        const maxConcurrent = 3; // Limit concurrent uploads
        const delayBetweenBatches = Duration(milliseconds: 200); // Small delay between batches

        final List<String> failedCards = [];

        // Process cards in batches to avoid overwhelming the server
        for (int i = 0; i < cards.length; i += maxConcurrent) {
          final batch = cards.skip(i).take(maxConcurrent).toList();
          final uploadFutures = batch.map((card) => _uploadCard(card, pockardPath)).toList();

          // Wait for all futures in this batch to complete
          for (int j = 0; j < uploadFutures.length; j++) {
            try {
              await uploadFutures[j];
            } catch (e) {
              failedCards.add('${batch[j].name} (${batch[j].uuid}): $e');
            }
          }

          // Add small delay between batches to reduce server load
          if (i + maxConcurrent < cards.length) {
            await Future.delayed(delayBetweenBatches);
          }
        }

        if (failedCards.isNotEmpty) {
          throw Exception('Failed to upload ${failedCards.length} card(s):\n${failedCards.join('\n')}');
        }

        debugPrint('Cards exported successfully (parallel mode with rate limiting)');
      } else {
        // Sequential upload (more conservative)
        for (final card in cards) {
          await _uploadCard(card, pockardPath);
        }
        debugPrint('Cards exported successfully (sequential mode)');
      }

      // Update last sync date
      final currentSettings = await loadSettings();
      if (currentSettings != null) {
        final updatedSettings = currentSettings.copyWith(lastSyncDate: DateTime.now());
        await saveSettings(updatedSettings);
      }
    } catch (e) {
      debugPrint('Error exporting cards: $e');
      rethrow;
    }
  }

  /// Export cards to WebDAV server using a manifest file
  Future<void> exportCardsWithManifest(List<CardModel> cards, DateTime preferencesTimestamp, {bool forceAll = false}) async {
    if (!_webdavService.isInitialized) {
      throw Exception('WebDAV client not initialized');
    }

    final settings = await loadSettings();
    final pockardPath = settings?.pockardFolderPath ?? '/pockard';

    try {
      // Ensure app directories exist
      await _webdavService.createAppDirectories(pockardPath: pockardPath);

      // 1. Try to get existing remote manifest to compare
      SyncManifest? remoteManifest;
      if (!forceAll) {
        try {
          final manifestBytes = await _webdavService.downloadFile('$pockardPath/manifest.json');
          final manifestJson = json.decode(utf8.decode(manifestBytes));
          remoteManifest = SyncManifest.fromJson(manifestJson);
        } catch (e) {
          debugPrint('No existing manifest found, will upload all cards: $e');
        }
      }

      // 2. Determine which cards need to be uploaded
      final cardsToUpload = <CardModel>[];
      if (forceAll || remoteManifest == null) {
        cardsToUpload.addAll(cards);
      } else {
        // Compare with remote manifest to find changed cards
        for (final card in cards) {
          final remoteTimestamp = remoteManifest.cardTimestamps[card.uuid];
          if (remoteTimestamp == null || card.updateDate.isAfter(remoteTimestamp)) {
            cardsToUpload.add(card);
          }
        }
      }

      // 3. Upload only the changed cards
      if (cardsToUpload.isNotEmpty) {
        await _exportCardsLegacy(cardsToUpload);
      }

      // 4. Create and upload the new manifest
      final manifest = SyncManifest(preferencesLastModified: preferencesTimestamp, cardTimestamps: {for (var card in cards) card.uuid: card.updateDate});

      final manifestJson = json.encode(manifest.toJson());
      final tempDir = await getTemporaryDirectory();
      final tempManifestFile = File('${tempDir.path}/manifest.json');
      await tempManifestFile.writeAsString(manifestJson);

      // Ensure file is fully written before attempting upload
      if (!await tempManifestFile.exists()) {
        throw Exception('Failed to create temporary manifest file');
      }

      await _webdavService.uploadFile(tempManifestFile.path, '$pockardPath/manifest.json');
      await tempManifestFile.delete();

      debugPrint('Exported ${cardsToUpload.length} changed cards out of ${cards.length} total cards');

      // Update last sync date
      final currentSettings = await loadSettings();
      if (currentSettings != null) {
        final updatedSettings = currentSettings.copyWith(lastSyncDate: DateTime.now());
        await saveSettings(updatedSettings);
      }
    } catch (e) {
      debugPrint('Error exporting cards with manifest: $e');
      rethrow;
    }
  }

  /// Upload a single card (JSON + image)
  Future<void> _uploadCard(CardModel card, String pockardPath) async {
    try {
      // Create a portable version of the card for export
      // Replace absolute image paths with flags indicating images exist
      final exportCard = card.copyWith(
        coverImagePath: card.coverImagePath != null ? 'HAS_IMAGE' : null,
        barcodeImagePath: card.barcodeImagePath != null ? 'HAS_BARCODE_IMAGE' : null,
      );

      // Upload card JSON with portable path
      final cardJson = json.encode(exportCard.toMap());
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_card_${card.uuid}.json');
      await tempFile.writeAsString(cardJson);

      // Ensure file is fully written before attempting upload
      if (!await tempFile.exists()) {
        throw Exception('Failed to create temporary file for card ${card.uuid}');
      }

      final remotePath = '$pockardPath/cards/${card.uuid}.json';
      await _webdavService.uploadFile(tempFile.path, remotePath);

      // Clean up temp file
      await tempFile.delete();

      // Upload cover image if it exists
      if (card.coverImagePath != null && await File(card.coverImagePath!).exists()) {
        final imageFileName = '${card.uuid}_cover.jpg';
        final imageRemotePath = '$pockardPath/images/$imageFileName';
        await _webdavService.uploadFile(card.coverImagePath!, imageRemotePath);
      }

      // Upload barcode image if it exists
      if (card.barcodeImagePath != null && await File(card.barcodeImagePath!).exists()) {
        final barcodeImageFileName = '${card.uuid}_barcode.jpg';
        final barcodeImageRemotePath = '$pockardPath/images/$barcodeImageFileName';
        await _webdavService.uploadFile(card.barcodeImagePath!, barcodeImageRemotePath);
      }
    } catch (e) {
      debugPrint('Error exporting card ${card.uuid}: $e');
      // Rethrow the error so it can be properly handled by the caller
      rethrow;
    }
  }

  /// Import cards from WebDAV server using a manifest file
  Future<SyncResult> importCardsWithManifest() async {
    if (!_webdavService.isInitialized) {
      throw Exception('WebDAV client not initialized');
    }

    final settings = await loadSettings();
    final pockardPath = settings?.pockardFolderPath ?? '/pockard';

    try {
      // 1. Download the manifest file
      final manifestBytes = await _webdavService.downloadFile('$pockardPath/manifest.json');
      final manifestJson = json.decode(utf8.decode(manifestBytes));
      final remoteManifest = SyncManifest.fromJson(manifestJson);

      // 2. Get local card data for comparison
      final localCards = await DatabaseService().getAllCards();
      final localCardMap = {for (var card in localCards) card.uuid: card};

      final cardsToImport = <CardModel>[];
      final deletionCandidates = <CardModel>[];

      // 3. Compare remote manifest with local data
      for (final remoteEntry in remoteManifest.cardTimestamps.entries) {
        final remoteUuid = remoteEntry.key;
        final remoteTimestamp = remoteEntry.value;
        final localCard = localCardMap[remoteUuid];

        // If card is new or updated on the server, download it
        if (localCard == null || remoteTimestamp.isAfter(localCard.updateDate)) {
          final card = await _downloadCard(remoteUuid, pockardPath);
          if (card != null) {
            // Check for Tombstone (server says it's deleted)
            if (card.isDeleted) {
               // If we have it locally and it's not already deleted, we should update it to match server
               // But if we don't have it, we don't need to import a deleted card
               if (localCard != null && !localCard.isDeleted) {
                 cardsToImport.add(card);
               }
            } else {
               cardsToImport.add(card);
            }
          }
        }
      }

      // 4. Identify Deletion Candidates: cards present locally but not in remote manifest
      // We do NOT auto-delete them anymore. We return them for user decision.
      for (final localCard in localCards) {
        // Only consider active cards as candidates for deletion
        if (!localCard.isDeleted && !remoteManifest.cardTimestamps.containsKey(localCard.uuid)) {
          deletionCandidates.add(localCard);
        }
      }

      return SyncResult(importedCards: cardsToImport, deletionCandidates: deletionCandidates);
    } catch (e) {
      // If manifest doesn't exist or is corrupted, fall back to legacy import (safest is to assumes no deletions)
      debugPrint('Manifest-based import failed, falling back to legacy import: $e');
      final legacyCards = await _importCardsLegacy();
      return SyncResult(importedCards: legacyCards, deletionCandidates: []);
    }
  }

  Future<CardModel?> _downloadCard(String uuid, String pockardPath) async {
    try {
      final remotePath = '$pockardPath/cards/$uuid.json';
      final bytes = await _webdavService.downloadFile(remotePath);
      final jsonString = utf8.decode(bytes);
      final cardData = json.decode(jsonString);
      var card = CardModel.fromMap(cardData);

      // Image import logic (simplified from original importCards)
      if (card.coverImagePath == 'HAS_IMAGE') {
        final imageRemotePath = '$pockardPath/images/${card.uuid}_cover.jpg';
        final appDir = await getApplicationDocumentsDirectory();
        final imagesDir = Directory('${appDir.path}/images');
        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }
        final localImagePath = '${imagesDir.path}/${card.uuid}_cover.jpg';
        final imageBytes = await _webdavService.downloadFile(imageRemotePath);
        await File(localImagePath).writeAsBytes(imageBytes);
        card = card.copyWith(coverImagePath: localImagePath);
      }

      if (card.barcodeImagePath == 'HAS_BARCODE_IMAGE') {
        final barcodeImageRemotePath = '$pockardPath/images/${card.uuid}_barcode.jpg';
        final appDir = await getApplicationDocumentsDirectory();
        final imagesDir = Directory('${appDir.path}/images');
        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }
        final localBarcodeImagePath = '${imagesDir.path}/${card.uuid}_barcode.jpg';
        final barcodeImageBytes = await _webdavService.downloadFile(barcodeImageRemotePath);
        await File(localBarcodeImagePath).writeAsBytes(barcodeImageBytes);
        card = card.copyWith(barcodeImagePath: localBarcodeImagePath);
      }

      return card;
    } catch (e) {
      debugPrint('Error downloading card $uuid: $e');
      return null;
    }
  }

  /// Initialize WebDAV client with stored settings
  Future<bool> initializeFromSettings() async {
    final settings = await loadSettings();
    if (settings != null && settings.hasCredentials) {
      _webdavService.initialize(settings.serverAddress!, settings.username!, settings.password!);
      return true;
    }
    return false;
  }

  /// Disconnect WebDAV client
  void disconnect() {
    _webdavService.disconnect();
  }


  /// Import cards from WebDAV server (public method - uses manifest-based approach)
  Future<SyncResult> importCards() async {
    return await importCardsWithManifest();
  }

  /// Export cards to WebDAV server (public method - uses manifest-based approach)
  Future<void> exportCards(List<CardModel> cards) async {
    // Use current time as preferences timestamp since we don't have access to actual preferences modification time here
    // The UI should call exportCardsWithManifest directly with the proper timestamp
    await exportCardsWithManifest(cards, DateTime.now());
  }
}
