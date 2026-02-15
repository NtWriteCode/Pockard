import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/webdav_service.dart';
import '../models/card_model.dart';
import '../models/sync_analysis_model.dart';
import '../services/database_service.dart';
import '../services/sync_settings_service.dart';

// Separate service to handle detailed analysis logic
class SyncManagementService {
  final _webdavService = WebDavService();
  final _dbService = DatabaseService();
  final _syncService = SyncSettingsService();

  // Downloads *all* card JSONs from server, ignoring manifest
  Future<List<CardSyncStatus>> analyzeSyncState() async {
    final results = <CardSyncStatus>[];
    
    // Init WebDAV
    final success = await _syncService.initializeFromSettings();
    if (!success) throw Exception('Failed to connect to WebDAV');

    // Load necessary local/remote data
    final settings = await _syncService.loadSettings();
    final pockardPath = settings?.pockardFolderPath ?? '/pockard';
    final cardsPath = '$pockardPath/cards';
    
    // 1. Get ALL Local Cards
    final localCards = await _dbService.getAllCards();
    final localMap = {for (var c in localCards) c.uuid: c};

    // 2. Download Manifest (to check for missing entries)
    Map<String, DateTime> manifestTimestamps = {};
    try {
      final manifestBytes = await _webdavService.downloadFile('$pockardPath/manifest.json');
      final manifestJson = json.decode(utf8.decode(manifestBytes));
      if (manifestJson['card_timestamps'] != null) {
        (manifestJson['card_timestamps'] as Map<String, dynamic>).forEach((k, v) {
          manifestTimestamps[k] = DateTime.parse(v);
        });
      }
    } catch (e) {
      debugPrint('Manifest missing or corrupt (expected during repair): $e');
    }

    // 3. List ALL Files in 'cards/' directory
    final remoteFilenames = await _webdavService.listFiles(cardsPath);
    final remoteMap = <String, CardModel>{};

    for (final filename in remoteFilenames) {
      if (!filename.endsWith('.json')) continue;
      
      final fullPath = '$cardsPath/$filename';
      try {
        final content = await _webdavService.downloadFile(fullPath); // Small JSON, fast to dl
        final jsonMap = json.decode(utf8.decode(content));
        final card = CardModel.fromMap(jsonMap);
        remoteMap[card.uuid] = card;
      } catch (e) {
        debugPrint('Failed to parse card file $fullPath: $e');
        // Add as "Corrupt" so user can delete it
        final uuid = filename.replaceAll('.json', '');
        final corruptCard = CardModel(
          uuid: uuid,
          name: '(Corrupt) $filename',
          isDeleted: true, // Mark as deleted so it can be cleaned up
        );
        remoteMap[uuid] = corruptCard;
      }
    }

    // 4. Correlate and Build Status
    final allUuids = Set<String>.from(localMap.keys)..addAll(remoteMap.keys);
    
    for (final uuid in allUuids) {
      final local = localMap[uuid];
      final remote = remoteMap[uuid];
      final inManifest = manifestTimestamps.containsKey(uuid);
      
      final status = CardSyncStatus(
        uuid: uuid,
        name: local?.name ?? remote?.name ?? 'Unknown Card',
        updateDate: local?.updateDate ?? remote?.updateDate ?? DateTime.now(),
        localCard: local,
        remoteCard: remote,
        isInManifest: inManifest,
      );
      
      // Auto-Select "Recommended" Actions
      if (remote != null && !inManifest && !remote.isDeleted) {
        // Issue: Orphaned (on server, missing from manifest) -> Fix by adding
        status.selectedAction = SyncAction.addToManifest;
      } else if (remote != null && remote.isDeleted) {
        // Issue: Tombstone -> Usually ignore, unless user wants to restore
        status.selectedAction = SyncAction.none; 
      } else if (local != null && remote == null) {
        // Local only -> Upload
        status.selectedAction = SyncAction.uploadLocal;
      } else if (local == null && remote != null && !remote.isDeleted) {
        // Server only -> Download
        status.selectedAction = SyncAction.downloadRemote;
      } else if (local != null && local.isDeleted && (remote == null || !remote.isDeleted)) {
        // Pending Deletion (Local deleted, Remote active) -> Fix by uploading deletion (Sync)
        status.selectedAction = SyncAction.uploadLocal;
      } else if (remote != null && remote.name.startsWith('(Corrupt)')) {
        // Corrupt file -> Delete from server
        status.selectedAction = SyncAction.deletePermanently;
      }

      results.add(status);
    }
    
    // Sort logic: Orphans first, then Active Conflicts, then Synced/Deleted
    results.sort((a, b) {
      final scoreA = _getPriorityScore(a);
      final scoreB = _getPriorityScore(b);
      return scoreB.compareTo(scoreA); // Descending priority
    });

    return results;
  }
  
  int _getPriorityScore(CardSyncStatus item) {
    if (item.status == SyncStatusType.orphaned) return 100; // Critical fix
    if (item.status == SyncStatusType.localOnly) return 50;
    if (item.status == SyncStatusType.serverOnly) return 50;
    if (item.status == SyncStatusType.corrupt) return 90; // High priority fix
    if (item.status == SyncStatusType.pendingDeletion) return 40; // Normal sync
    if (item.status == SyncStatusType.remoteDeleted) return -10; // Usually hidden
    return 0; // Synced
  }

  // Apply Changes: Actually execute the user's choices
  Future<void> executeActions(List<CardSyncStatus> actions) async {
    final settings = await _syncService.loadSettings();
    final pockardPath = settings?.pockardFolderPath ?? '/pockard';

    // Batch Operations
    List<CardModel> toUpload = [];
    List<CardModel> toInsertLocal = [];
    List<String> toDeleteRemote = [];

    for (final item in actions) {
      switch (item.selectedAction) {
        case SyncAction.restore:
          // Un-delete remote tombstone: modify isDeleted=false and upload
          if (item.remoteCard != null) {
            final restored = item.remoteCard!.copyWith(isDeleted: false, updateDate: DateTime.now());
            toUpload.add(restored);
            toInsertLocal.add(restored); // Also ensure local has it
          }
          break;
          
        case SyncAction.addToManifest:
          // Just needs to be in next export/import cycle.
          // Simplest is to ensure it's in Local DB, then run standard export
          if (item.remoteCard != null) {
             // If local has it, use local version (newer?), else use remote
             final card = item.localCard ?? item.remoteCard!;
             toInsertLocal.add(card);
             toUpload.add(card); // Will update manifest
          }
          break;
          
        case SyncAction.uploadLocal:
          if (item.localCard != null) toUpload.add(item.localCard!);
          break;
          
        case SyncAction.downloadRemote:
          if (item.remoteCard != null) {
            toInsertLocal.add(item.remoteCard!);
            // If we download, we should also ensure its in manifest next time
            toUpload.add(item.remoteCard!); 
          }
          break;
          
        case SyncAction.deletePermanently:
          if (item.remoteCard != null) {
            toDeleteRemote.add(item.remoteCard!.uuid);
          }
          // ALSO delete local to prevent the re-sync loop
          if (item.localCard != null || item.uuid.isNotEmpty) {
            await _dbService.deleteCard(item.localCard?.uuid ?? item.uuid);
          }
          break;
          
        case SyncAction.none:
          break;
      }
    }

    // 1. Database Modifications
    for (final card in toInsertLocal) {
      final existing = await _dbService.getCard(card.uuid);
      if (existing != null) {
        await _dbService.updateCard(card);
      } else {
        await _dbService.insertCard(card);
      }
    }

    // 2. Uploads (Batch export handles manifest generation)
    if (toUpload.isNotEmpty) {
      // We must combine "toUpload" with EXISTING server cards to recreate a full manifest
      // Actually, exportCardsWithManifest calculates manifest based on ALL local cards
      // So if we inserted orphaned cards into DB in step 1, a standard export will fix the manifest!
      
      // Let's grab ALL active cards from DB now to be safe
      final allLocal = await _dbService.getAllCards();
      // Filter out deleted? No, keep deleted for tombstones.
      // Use forceAll: true to ensure repairs are actually pushed/forced to server
      await _syncService.exportCardsWithManifest(allLocal, DateTime.now(), forceAll: true);
    }
    
    // 3. Deletes - NOW ENABLED for cleanup
    for (final uuid in toDeleteRemote) {
      try {
        final remotePath = '$pockardPath/cards/$uuid.json';
        await _webdavService.deleteFile(remotePath);
        
        // Also try to delete associated images
        await _webdavService.deleteFile('$pockardPath/images/${uuid}_cover.jpg');
        await _webdavService.deleteFile('$pockardPath/images/${uuid}_barcode.jpg');
        
        debugPrint('Permanently deleted remote card: $uuid');
      } catch (e) {
        debugPrint('Failed to delete remote card $uuid: $e');
      }
    }
  }
}
