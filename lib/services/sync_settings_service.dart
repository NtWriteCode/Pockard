import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_model.dart';
import '../models/sync_settings_model.dart';
import 'webdav_service.dart';

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
      final useParallelSync = prefs.getBool('use_parallel_sync') ?? true;
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

  /// Import cards from WebDAV server
  Future<List<CardModel>> importCards() async {
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

  /// Export cards to WebDAV server
  Future<void> exportCards(List<CardModel> cards) async {
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
        // Parallel upload (faster)
        await Future.wait(
          cards.map((card) => _uploadCard(card, pockardPath)),
          eagerError: false, // Continue even if some uploads fail
        );
        debugPrint('Cards exported successfully (parallel mode)');
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
      // Don't rethrow - let other cards continue uploading
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
}
